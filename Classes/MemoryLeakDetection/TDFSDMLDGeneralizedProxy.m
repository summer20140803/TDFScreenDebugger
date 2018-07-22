//
//  TDFSDMLDGeneralizedProxy.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/16.
//

#import "TDFSDMLDGeneralizedProxy.h"
#import "TDFSDMLDGeneralizedProtocol.h"
#import "TDFSDMemoryLeakDetector.h"
#import "TDFSDQueueDispatcher.h"

@interface TDFSDMLDGeneralizedProxy ()

@property (nonatomic, weak, readwrite) id weakTarget;
@property (nonatomic, assign) BOOL isOnFollowObservation;

@end

@implementation TDFSDMLDGeneralizedProxy

const CGFloat kSDMLDMemoryLeakDetectionWarnningResetInterval   =  20.0f;
const CGFloat kSDMLDMemoryLeakDetectionLeakerConfirmingInterval =   1.0f;

#pragma mark - life cycle
+ (instancetype)proxyWithTarget:(id)target {
    TDFSDMLDGeneralizedProxy *proxy = [[TDFSDMLDGeneralizedProxy alloc] init];
    proxy.weakTarget = target;
    return proxy;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectTargetLeak) name:(NSString *)SDMLDMemoryLeakDetectionDidStartNotificationName object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString *)SDMLDMemoryLeakDetectionDidStartNotificationName object:nil];
}

#pragma mark - private
- (void)detectTargetLeak {
    if (self.weakTarget == nil)  return;
    if (self.isOnFollowObservation)  return;
    
    BOOL isSuspicious = [self.weakTarget isSuspiciousLeaker];
    if (isSuspicious) {
        self.isOnFollowObservation = YES;
        
        /*
        // filter out target who might be a singleton instance
        Class class = [self.weakTarget class];
        
        if ([[TDFSDMemoryLeakDetector sharedInstance].cacheSingletonClassNames containsObject:NSStringFromClass(class)]) {
            return;
        }
        
        // add @try..@catch to avoid some object's abnormal behavior
        @try {
            BOOL isSingleton = [self isSingletonClass:class];
            if (isSingleton) return;
        } @catch(NSException *e) {}
        */
      
        // check & confirm the suspicious leaker later
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSDMLDMemoryLeakDetectionLeakerConfirmingInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.weakTarget == nil)  return;
            
            BOOL isSuspicious = [self.weakTarget isSuspiciousLeaker];
            
            if (isSuspicious) {
                sd_dispatch_async_to_main_queue(^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)SDMLDMemoryLeakDetectionDidFindSuspiciousLeakerNotificationName object:self];
                });
            } else {
                self.isOnFollowObservation = NO;
            }
        });
    }
}
    
- (BOOL)isSingletonClass:(Class)class {
    @autoreleasepool {
        id obj1 = [[class alloc] init];
        id obj2 = [[class alloc] init];
        if (obj1 == obj2) {
            [[TDFSDMemoryLeakDetector sharedInstance] addSingletonClassNameToCache:NSStringFromClass(class)];
            return YES;
        }
        else return NO;
    }
}

@end
