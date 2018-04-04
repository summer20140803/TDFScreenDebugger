//
//  TDFSDPMWildPointerChecker.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/2.
//

#import "TDFSDPMWildPointerChecker.h"
#import "TDFSDPMZombieProxy.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <malloc/malloc.h>


@interface TDFSDPMWildPointerChecker ()

@property (nonatomic, strong) NSArray<Class> *rootSwizzledClasses;
@property (nonatomic, strong) NSDictionary<NSString *, NSValue *> *rootClassesOriginImps;
@property (nonatomic, strong) NSArray<NSString *> *allCustomizedClassNames;
@property (nonatomic, strong) NSMutableArray<NSValue *> *undeallocTargetPool;

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
        self.rootSwizzledClasses = @[[NSObject class], [NSProxy class]];
        self.maxZombiePoolCapacity = NSIntegerMax;
        self.undeallocTargetPool = [NSMutableArray array];
    }
    return self;
}

- (void)thaw {
    @synchronized(self) {
        [self injectZombieProxy];
    }
}

- (void)freeze {
    @synchronized(self) {
        [self restoreOriginDealloc];
    }
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
    
    SEL deallocSelector = sel_registerName("dealloc");
    
    __weak typeof(TDFSDPMWildPointerChecker) *checker = [TDFSDPMWildPointerChecker sharedInstance];
    
    id newDealloc = ^void(__unsafe_unretained id target) {
        Class currentClass = [target class];
        NSString *className = NSStringFromClass(currentClass);

//        if (![className hasPrefix:@"RAC"]) {
////            NSValue *objValue = [NSValue valueWithBytes:&target objCType:@encode(typeof(target))];
//            object_setClass(target, [TDFSDPMZombieProxy class]);
//            ((TDFSDPMZombieProxy *)target).originClass = currentClass;
//
//            // we use the establishment of a no-dealloc target pool to manage these targets' lifecycle
////            [checker addZombieProxyValueToPool:objValue];
//        } else {
//            [checker invokeOriginDealloc:target];
//        }
        
        object_setClass(target, [TDFSDPMZombieProxy class]);
        ((TDFSDPMZombieProxy *)target).originClass = currentClass;
    };
    
    IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
    
    NSMutableDictionary *deallocImpMaps = [NSMutableDictionary dictionary];
    for (Class rootClass in self.rootSwizzledClasses) {
        
        if (!class_addMethod(rootClass, deallocSelector, newDeallocIMP, "v@:")) {
            void (*originalDeallocIMP)(__unsafe_unretained id, SEL) = NULL;
        
            Method deallocMethod = class_getInstanceMethod(rootClass, deallocSelector);
            // we need to store original implementation before setting new implementation
            // in case method is called at the time of setting.
            originalDeallocIMP = (__typeof__(originalDeallocIMP))method_getImplementation(deallocMethod);
            // we need to store original implementation again, in case it just changed.
            originalDeallocIMP = (__typeof__(originalDeallocIMP))method_setImplementation(deallocMethod, newDeallocIMP);
            
            [deallocImpMaps setObject:[NSValue valueWithBytes:&originalDeallocIMP objCType:@encode(typeof(originalDeallocIMP))] forKey:NSStringFromClass(rootClass)];
        }
    }
    self.rootClassesOriginImps = [deallocImpMaps copy];
}

- (void)restoreOriginDealloc {
    [self killZombieProxiesInPool];
    
    SEL deallocSelector = sel_registerName("dealloc");
    [self.rootSwizzledClasses enumerateObjectsUsingBlock:^(Class rootClass, NSUInteger idx, BOOL *stop) {
        IMP originalDeallocImp = NULL;
        NSString *className = NSStringFromClass(rootClass);
        [[self.rootClassesOriginImps objectForKey:className] getValue:&originalDeallocImp];
        
        NSParameterAssert(originalDeallocImp);
        method_setImplementation(class_getInstanceMethod(rootClass, deallocSelector), originalDeallocImp);
    }];
    
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
    SEL deallocSelector = sel_registerName("dealloc");
    
    while (rootCls != [NSObject class] && rootCls != [NSProxy class]) {
        rootCls = class_getSuperclass(rootCls);
    }
    NSString *clsName = NSStringFromClass(rootCls);
    void (*originalDeallocIMP)(__unsafe_unretained id, SEL) = NULL;
    [[self.rootClassesOriginImps objectForKey:clsName] getValue:&originalDeallocIMP];
    
    if (originalDeallocIMP != NULL) {
        originalDeallocIMP(target, deallocSelector);
    }
}

- (void)addZombieProxyValueToPool:(NSValue *)proxyValue {
    size_t poolSize = sizeof((__bridge const void *)(self.undeallocTargetPool));
    NSLog(@"缓存池占用空间: %ld", poolSize);
    if (poolSize >= self.maxZombiePoolCapacity) {
        [self killZombieProxiesInPool];
    }
    [self.undeallocTargetPool addObject:proxyValue];
}

@end

