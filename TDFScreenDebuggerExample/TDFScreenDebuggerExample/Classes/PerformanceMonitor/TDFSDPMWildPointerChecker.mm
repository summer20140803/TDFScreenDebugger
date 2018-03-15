//
//  TDFSDPMWildPointerChecker.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/2.
//

#import "TDFSDPMWildPointerChecker.h"
#import <objc/runtime.h>

@interface TDFSDPMZombieProxy : NSProxy

@property (nonatomic, assign) Class originClass;

@end

@implementation TDFSDPMZombieProxy

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    [self zombieProxyBoommmmm:sel];
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self zombieProxyBoommmmm:invocation.selector];
}

- (void)zombieProxyBoommmmm:(SEL)selector {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason: \
            [NSString stringWithFormat:@"[TDFScreenDebugger.PerformanceMonitor.WildPointerChecker] message(-[%@ %@]) was sent to a zombie object at address: %p", NSStringFromClass(self.originClass), NSStringFromSelector(selector), self] userInfo:nil];
}

@end

typedef void (*SDDeallocImpPointer)(id target);

@interface TDFSDPMWildPointerChecker ()

@property (nonatomic, strong) NSArray<Class> *rootSwizzledClasses;
@property (nonatomic, strong) NSDictionary<NSString *, NSValue *> *rootClassesOriginImps;
@property (nonatomic, strong) NSArray<NSString *> *allCustomizedClassNames;
@property (nonatomic, strong) NSMutableArray<NSValue *> *undeallocTargetPool;
@property (nonatomic,   copy) void (^swizzledDeallocImpBlock)(id target);

@end

@implementation TDFSDPMWildPointerChecker

+ (instancetype)sharedInstance {
    static TDFSDPMWildPointerChecker *sharedInstance = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rootSwizzledClasses = [@[[NSObject class], [NSProxy class]] retain];
        self.maxZombieProxyCount = 1000;
        self.undeallocTargetPool = [NSMutableArray array];
        
    }
    return self;
}

- (void)thaw {
    [self injectZombieProxy];
}

- (void)freeze {
    [self restoreOriginDealloc];
}

- (void)killZombieProxiesInPool {
    for (int i = 0; i < self.undeallocTargetPool.count; i ++) {
        NSValue *objValue = self.undeallocTargetPool[i];
        __unsafe_unretained id target = nil;
        [objValue getValue:&target];
        Class originClass = ((TDFSDPMZombieProxy *)target).originClass;
        object_setClass(target, originClass);
        
        [self.undeallocTargetPool removeObject:objValue];
        [self invokeOriginDealloc:target];
    }
}

#pragma mark - private
- (void)injectZombieProxy {
    if (self.allCustomizedClassNames == nil) {
        [self obtainAllCustomizedClassNames];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        TDFSDPMWildPointerChecker *checker = [TDFSDPMWildPointerChecker sharedInstance];
        self.swizzledDeallocImpBlock = ^void(id target) {
            Class currentClass = [target class];
            NSString *className = NSStringFromClass(currentClass);

            if ([checker.allCustomizedClassNames containsObject:className]) {
                NSValue *objValue = [NSValue valueWithBytes:&target objCType:@encode(typeof(target))];
                object_setClass(target, [TDFSDPMZombieProxy class]);
                ((TDFSDPMZombieProxy *)target).originClass = currentClass;
                
                // we use the establishment of a no-dealloc target pool to manage these targets' lifecycle
                [self addZombieProxyValueToPool:objValue];
            } else {
                [checker invokeOriginDealloc:target];
            }
        };
    });
    
    NSMutableDictionary *deallocImpMaps = [NSMutableDictionary dictionary];
    for (Class rootClass in self.rootSwizzledClasses) {
        IMP originalDeallocImp = [self swizzleDeallocMethod:class_getInstanceMethod(rootClass, @selector(dealloc)) IMPBlock:self.swizzledDeallocImpBlock];
        [deallocImpMaps setObject:[NSValue valueWithBytes:&originalDeallocImp objCType:@encode(typeof(IMP))] forKey:NSStringFromClass(rootClass)];
    }
    self.rootClassesOriginImps = [deallocImpMaps copy];
}

- (void)restoreOriginDealloc {
    [self killZombieProxiesInPool];
    
    [self.rootSwizzledClasses enumerateObjectsUsingBlock:^(Class rootClass, NSUInteger idx, BOOL *stop) {
        IMP originalDeallocImp = NULL;
        NSString *className = NSStringFromClass(rootClass);
        [[self.rootClassesOriginImps objectForKey:className] getValue:&originalDeallocImp];
        
        NSParameterAssert(originalDeallocImp);
        method_setImplementation(class_getInstanceMethod(rootClass, @selector(dealloc)), originalDeallocImp);
    }];
    [self.rootClassesOriginImps release];
    self.rootClassesOriginImps = nil;
}

- (void)obtainAllCustomizedClassNames {
    unsigned int registerClassCount;
    Class *classes = objc_copyClassList(&registerClassCount);
    
    NSMutableArray *vaildClassNames = [NSMutableArray array];
    
    for (int i = 0; i < registerClassCount; i++) {
        Class aClass = classes[i];
        NSBundle *bundle = [NSBundle bundleForClass:aClass];
        if ([bundle isEqual:[NSBundle mainBundle]]) {
            [vaildClassNames addObject:NSStringFromClass(aClass)];
        }
    }
    free(classes);
    self.allCustomizedClassNames = vaildClassNames;
}

- (void)invokeOriginDealloc:(__unsafe_unretained id)target {
    Class currentCls = [target class];
    Class rootCls = currentCls;
    
    while (rootCls != [NSObject class] && rootCls != [NSProxy class]) {
        rootCls = class_getSuperclass(rootCls);
    }
    NSString *clsName = NSStringFromClass(rootCls);
    SDDeallocImpPointer deallocImp = NULL;
    [[self.rootClassesOriginImps objectForKey:clsName] getValue:&deallocImp];
    
    if (deallocImp != NULL) {
        deallocImp(target);
    }
}

- (IMP)swizzleDeallocMethod:(Method)method IMPBlock:(id)IMPBlock {
    IMP injectZombieProxyIMP = imp_implementationWithBlock(IMPBlock);
    return method_setImplementation(method, injectZombieProxyIMP);
}

- (void)addZombieProxyValueToPool:(NSValue *)objValue {
    @synchronized(self) {
        if (self.undeallocTargetPool.count >= self.maxZombieProxyCount) {
            NSValue *firstProxyValue = self.undeallocTargetPool.firstObject;
            __unsafe_unretained id target = nil;
            [firstProxyValue getValue:&target];
            Class originClass = ((TDFSDPMZombieProxy *)target).originClass;
            object_setClass(target, originClass);
            
            [self.undeallocTargetPool removeObjectAtIndex:0];
            [self invokeOriginDealloc:target];
        }
        [self.undeallocTargetPool addObject:objValue];
    }
}

@end

