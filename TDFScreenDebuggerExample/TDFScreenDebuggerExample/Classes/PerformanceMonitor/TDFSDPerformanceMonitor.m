//
//  TDFSDPerformanceMonitor.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/13.
//

#import "TDFSDPerformanceMonitor.h"
#import "TDFSDPersistenceSetting.h"
#import "TDFSDCallStackFetcher.h"
#import "TDFSDPMUILagComponentModel.h"
#import "TDFSDQueueDispatcher.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <mach/mach.h>
#import <mach/task.h>
#import <mach/task_info.h>
#import <mach/vm_map.h>
#import <mach/mach_init.h>
#import <mach/thread_act.h>
#import <mach/thread_info.h>

static const mach_vm_size_t  kSDBytePerMB               =  1024 * 1024;
static const uint64_t        kSDDispatchSourceInterval  =  1 * NSEC_PER_SEC;

@interface TDFSDPMWeakProxy : NSObject

@property (nonatomic, weak, readonly) id target;
+ (instancetype)proxyWithTarget:(id)target;

@end

@implementation TDFSDPMWeakProxy

+ (instancetype)proxyWithTarget:(id)target {
    TDFSDPMWeakProxy *wp = [[TDFSDPMWeakProxy alloc] init];
    wp->_target = target;
    return wp;
}

#pragma mark - override methods
- (id)forwardingTargetForSelector: (SEL)aSelector {
    return _target;
}

- (void)forwardInvocation: (NSInvocation *)anInvocation {
    void * null = NULL;
    [anInvocation setReturnValue: &null];
}

- (NSMethodSignature *)methodSignatureForSelector: (SEL)aSelector {
    return [_target methodSignatureForSelector: aSelector];
}

- (BOOL)isProxy {
    return YES;
}

- (Class)class {
    return [_target class];
}

- (Class)superclass {
    return [_target superclass];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

- (BOOL)isEqual:(id)object {
    return [_target isEqual: object];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass: aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass: aClass];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector: aSelector];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol: aProtocol];
}

@end

@interface TDFSDPMFPSComponent : NSObject <TDFSDFunctionIOControlProtocol> {
    @protected
    CADisplayLink *_displayLink;
    int _frameIdx;
    NSTimeInterval _lastFrameRenderTime;
}

@property (nonatomic, copy) void (^didMonitorNewFPSValueHandler)(int fps);

@end

@implementation TDFSDPMFPSComponent

- (void)thaw {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @weakify(self)
        [[[RACObserve([TDFSDPersistenceSetting sharedInstance], allowScreenFPSMonitoring) skip:1]
         distinctUntilChanged]
         subscribeNext:^(NSNumber * _Nullable x) {
             @strongify(self)
             [x boolValue] ? [self thaw] : [self freeze];
        }];
    });
    
    if (![TDFSDPersistenceSetting sharedInstance].allowScreenFPSMonitoring) return;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:[TDFSDPMWeakProxy proxyWithTarget:self] selector:@selector(frameRender:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _lastFrameRenderTime = _displayLink.timestamp;
}

- (void)freeze {
    [_displayLink invalidate];
    _displayLink = nil;
    _frameIdx = 0;
}

#pragma mark - private
- (void)frameRender:(CADisplayLink *)displayLink {
    _frameIdx ++;
    NSTimeInterval gap = displayLink.timestamp - _lastFrameRenderTime;
    if (gap < 1) return;
    
    _lastFrameRenderTime = displayLink.timestamp;
    int fps = (int)round(_frameIdx/gap);
    _frameIdx = 0;
    
    !self.didMonitorNewFPSValueHandler ?: self.didMonitorNewFPSValueHandler(fps);
}

@end

@interface TDFSDPMUILagsComponent : NSObject <TDFSDFunctionIOControlProtocol> {
    @protected
    dispatch_semaphore_t _semaphore;
}

@property (nonatomic, copy) void (^didMonitorNewUILagHandler)(TDFSDPMUILagComponentModel *lag);

@end

@implementation TDFSDPMUILagsComponent

- (void)dealloc {
    [self freeze];
}

- (void)thaw {
    if (![TDFSDPersistenceSetting sharedInstance].allowUILagsMonitoring) return;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _semaphore = dispatch_semaphore_create(0);
        
        sd_dispatch_async_by_qos_user_initiated(^{
            while ([TDFSDPersistenceSetting sharedInstance].allowUILagsMonitoring) {
                
                // dispatch a transaction to UI thread..
                __block BOOL pm_timeout = YES;
                sd_dispatch_async_to_main_queue(^{
                    @synchronized(self) {
                        pm_timeout = NO;
                        dispatch_semaphore_signal(_semaphore);
                    }
                });
                [NSThread sleepForTimeInterval:[TDFSDPersistenceSetting sharedInstance].tolerableLagThreshold];
                if (pm_timeout) {
                    NSString *uiThreadCallStackDes = [TDFSDCallStackFetcher sd_callStackOfMainThread];
                    printf("\n\n[TDFScreenDebugger.PerformanceMonitor.UILagComponent]\n%s\n\n", [uiThreadCallStackDes UTF8String]);
                    
                    TDFSDPMUILagComponentModel *lag = [[TDFSDPMUILagComponentModel alloc] init];
                    lag.occurTime = [NSDate date];
                    lag.callStackInfo = uiThreadCallStackDes;
                    
                    sd_dispatch_async_to_main_queue(^{
                        !self.didMonitorNewUILagHandler ?: self.didMonitorNewUILagHandler(lag);
                    });
                }
                dispatch_wait(_semaphore, DISPATCH_TIME_FOREVER);
            }
        });
    });
}

- (void)freeze {}

@end

@interface TDFSDPMApplicationCPUComponent : NSObject

@property (nonatomic, copy) void (^didMonitorApplicationCPUHandler)(CGFloat cpuUsage);
- (void)takeApplicationCPUUsage;

@end

@implementation TDFSDPMApplicationCPUComponent

- (void)takeApplicationCPUUsage {
    
    CGFloat usageRatio = 0;
    thread_info_data_t thinfo;
    thread_act_array_t threads;
    thread_basic_info_t basic_info_t;
    mach_msg_type_number_t count = 0;
    mach_msg_type_number_t thread_info_count = THREAD_INFO_MAX;
    
    if (task_threads(mach_task_self(), &threads, &count) == KERN_SUCCESS) {
        for (int idx = 0; idx < count; idx++) {
            if (thread_info(threads[idx], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count) == KERN_SUCCESS) {
                basic_info_t = (thread_basic_info_t)thinfo;
                if (!(basic_info_t->flags & TH_FLAGS_IDLE)) {
                    usageRatio += basic_info_t->cpu_usage / (CGFloat)TH_USAGE_SCALE;
                }
            }
        }
        assert(vm_deallocate(mach_task_self(), (vm_address_t)threads, count * sizeof(thread_t)) == KERN_SUCCESS);
    }
    
    sd_dispatch_async_to_main_queue(^{
        !self.didMonitorApplicationCPUHandler ?: self.didMonitorApplicationCPUHandler(usageRatio * 100.);
    });
}

@end

@interface TDFSDPMApplicationMemoryComponent : NSObject

@property (nonatomic, copy) void (^didMonitorApplicationMemoryHandler)(CGFloat memoryUsage);
- (void)takeApplicationMemoryUsage;

@end

@implementation TDFSDPMApplicationMemoryComponent

- (void)takeApplicationMemoryUsage {
    
    struct mach_task_basic_info info;
    mach_msg_type_number_t count = sizeof(info) / sizeof(integer_t);
    
    if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &count) == KERN_SUCCESS) {
        CGFloat memoryUsage = (CGFloat)info.resident_size / kSDBytePerMB;
        
        sd_dispatch_async_to_main_queue(^{
            !self.didMonitorApplicationMemoryHandler ?: self.didMonitorApplicationMemoryHandler(memoryUsage);
        });
    }
}

@end

@interface TDFSDPerformanceMonitor ()

@property (nonatomic, strong) dispatch_source_t source_t;
@property (nonatomic, strong, readwrite) NSArray<TDFSDPMUILagComponentModel *> *uiLags;
@property (nonatomic, assign, readwrite) int     screenFps;
@property (nonatomic, assign, readwrite) CGFloat appCpuUsage;
@property (nonatomic, assign, readwrite) CGFloat appMemoryUsage;

@property (nonatomic, strong) TDFSDPMFPSComponent *fpsComponent;
@property (nonatomic, strong) TDFSDPMUILagsComponent *uiLagComponent;
@property (nonatomic, strong) TDFSDPMApplicationCPUComponent *appCpuComponent;
@property (nonatomic, strong) TDFSDPMApplicationMemoryComponent *appMemoryComponent;

@end

@implementation TDFSDPerformanceMonitor

#pragma mark - life cycle

#if DEBUG
SD_CONSTRUCTOR_METHOD_DECLARE(SD_CONSTRUCTOR_METHOD_PRIORITY_PERFORMANCE_MONITOR, {
    [[TDFSDPerformanceMonitor sharedInstance] thaw];
})
#endif

+ (instancetype)sharedInstance {
    static TDFSDPerformanceMonitor *sharedInstance = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)thaw {
    NSArray<id<TDFSDFunctionIOControlProtocol>> *thawableComponents = @[ self.uiLagComponent, self.fpsComponent ];
    [thawableComponents makeObjectsPerformSelector:@selector(thaw)];
    dispatch_resume(self.source_t);
}

- (void)freeze {
    NSArray<id<TDFSDFunctionIOControlProtocol>> *freezableComponents = @[ self.uiLagComponent, self.fpsComponent ];
    [freezableComponents makeObjectsPerformSelector:@selector(freeze)];
    dispatch_source_cancel(self.source_t);
}

- (void)clearAllCachedUILags {
    self.uiLags = @[];
}

#pragma mark - getter
- (dispatch_source_t)source_t {
    if (!_source_t) {
        _source_t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, sd_better_queue_by_qos(NSQualityOfServiceDefault));
        dispatch_source_set_timer(_source_t, DISPATCH_TIME_NOW, kSDDispatchSourceInterval, 0);
        dispatch_source_set_event_handler(_source_t, ^{
            
            if ([TDFSDPersistenceSetting sharedInstance].allowApplicationMemoryMonitoring) {
                [self.appMemoryComponent takeApplicationMemoryUsage];
            }
            if ([TDFSDPersistenceSetting sharedInstance].allowApplicationCPUMonitoring) {
                [self.appCpuComponent takeApplicationCPUUsage];
            }
        });
    }
    return _source_t;
}

- (TDFSDPMFPSComponent *)fpsComponent {
    if (!_fpsComponent) {
        _fpsComponent = [[TDFSDPMFPSComponent alloc] init];
        @weakify(self)
        _fpsComponent.didMonitorNewFPSValueHandler = ^(int fps) {
            @strongify(self)
            self.screenFps = fps;
        };
    }
    return _fpsComponent;
}

- (TDFSDPMUILagsComponent *)uiLagComponent {
    if (!_uiLagComponent) {
        _uiLagComponent = [[TDFSDPMUILagsComponent alloc] init];
        @weakify(self)
        _uiLagComponent.didMonitorNewUILagHandler = ^(TDFSDPMUILagComponentModel *lag) {
            @strongify(self)
            NSMutableArray *lags = self.uiLags.mutableCopy;
            [lags addObject:lag];
            self.uiLags = lags.copy;
        };
    }
    return _uiLagComponent;
}

- (TDFSDPMApplicationCPUComponent *)appCpuComponent {
    if (!_appCpuComponent) {
        _appCpuComponent = [[TDFSDPMApplicationCPUComponent alloc] init];
        @weakify(self)
        _appCpuComponent.didMonitorApplicationCPUHandler = ^(CGFloat cpuUsage) {
            @strongify(self)
            self.appCpuUsage = cpuUsage;
        };
    }
    return _appCpuComponent;
}

- (TDFSDPMApplicationMemoryComponent *)appMemoryComponent {
    if (!_appMemoryComponent) {
        _appMemoryComponent = [[TDFSDPMApplicationMemoryComponent alloc] init];
        @weakify(self)
        _appMemoryComponent.didMonitorApplicationMemoryHandler = ^(CGFloat memoryUsage) {
            @strongify(self)
            self.appMemoryUsage = memoryUsage;
        };
    }
    return _appMemoryComponent;
}

- (NSArray<TDFSDPMUILagComponentModel *> *)uiLags {
    if (!_uiLags) {
        _uiLags = @[];
    }
    return _uiLags;
}

@end
