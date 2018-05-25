//
//  TDFSDWildPointerChecker.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/2.
//

#import "TDFSDWildPointerChecker.h"
#import "TDFSDWPCZombieProxy.h"
#import "TDFSDPersistenceSetting.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <malloc/malloc.h>


@interface TDFSDWildPointerChecker ()

@property (nonatomic, strong) NSArray<Class> *rootSwizzledClasses;
@property (nonatomic, strong) NSDictionary<NSString *, NSValue *> *rootClassesOriginImps;
@property (nonatomic,   copy) void (^newDeallocBlock)(__unsafe_unretained id target);

@end

@implementation TDFSDWildPointerChecker

#pragma mark - life cycle
static TDFSDWildPointerChecker *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!sharedInstance) {
        sharedInstance = [super allocWithZone:zone];
    }
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rootSwizzledClasses = @[[NSObject class], [NSProxy class]];
    }
    return self;
}

#pragma mark - TDFSDFunctionIOControlProtocol
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

#pragma mark - private
- (void)injectZombieProxy {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreOriginDealloc) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    SEL deallocSelector = sel_registerName("dealloc");
    
    __weak typeof(self) weak_self = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        self.newDeallocBlock = ^void(__unsafe_unretained id target) {
            
            __weak typeof(weak_self) strong_self = weak_self;
            
            @synchronized(strong_self) {
                Class currentClass = [target class];
                
                object_setClass(target, [TDFSDWPCZombieProxy class]);
                ((TDFSDWPCZombieProxy *)target).originClass = currentClass;

//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    object_setClass(target, currentClass);
//                    [strong_self invokeOriginDealloc:target];
//                });
            }
        };
    });
    
    IMP newDeallocIMP = imp_implementationWithBlock(self.newDeallocBlock);
    
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
    
    SEL deallocSelector = sel_registerName("dealloc");
    [self.rootSwizzledClasses enumerateObjectsUsingBlock:^(Class rootClass, NSUInteger idx, BOOL *stop) {
        IMP originalDeallocImp = NULL;
        NSString *className = NSStringFromClass(rootClass);
        [[self.rootClassesOriginImps objectForKey:className] getValue:&originalDeallocImp];
        
        NSParameterAssert(originalDeallocImp);
        method_setImplementation(class_getInstanceMethod(rootClass, deallocSelector), originalDeallocImp);
    }];
    
    self.rootClassesOriginImps = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)invokeOriginDealloc:(__unsafe_unretained id)target {
    Class currentCls = [target class];
    Class rootCls = currentCls;
    SEL deallocSelector = sel_registerName("dealloc");
    
    rootCls = ([rootCls isSubclassOfClass:[NSProxy class]] ? [NSProxy class] : [NSObject class]);
    
    NSString *clsName = NSStringFromClass(rootCls);
    void (*originalDeallocIMP)(__unsafe_unretained id, SEL) = NULL;
    [[self.rootClassesOriginImps objectForKey:clsName] getValue:&originalDeallocIMP];
    
    if (originalDeallocIMP != NULL) {
        originalDeallocIMP(target, deallocSelector);
        target = nil;
    }
}

@end

