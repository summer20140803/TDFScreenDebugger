//
//  TDFSDCrashCaptor.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/13.
//

#import "TDFSDCrashCaptor.h"
#import "TDFSDPersistenceSetting.h"
#import "TDFScreenDebuggerDefine.h"
#import "TDFSDCCCrashModel.h"
#import "TDFSDCrashCapturePresentationController.h"
#import "TDFSDTransitionAnimator.h"
#import "TDFSDQueueDispatcher.h"
#import "UIViewController+ScreenDebugger.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <objc/runtime.h>
#import <signal.h>
#import <execinfo.h>

static BOOL _needApplyForKeepingLifeCycle = NO;
static void ocExceptionHandler(NSException *e);

@interface TDFSDCCKVOStub : NSObject

+ (instancetype)sharedInstance;

@end

@implementation TDFSDCCKVOStub

+ (instancetype)sharedInstance {
    static TDFSDCCKVOStub *sharedInstance = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end

@interface TDFSDCCKVORemoveHelper : NSObject

@property (nonatomic, unsafe_unretained) id observeObj;
@property (nonatomic, copy) NSString *keyPath;

@end

@implementation TDFSDCCKVORemoveHelper

- (void)dealloc {
    if (_observeObj) {
        [_observeObj removeObserver:[TDFSDCCKVOStub sharedInstance] forKeyPath:_keyPath];
    }
}

@end

@interface UIViewController (SDCrashCaptorAdditions)

@end

@implementation UIViewController (SDCrashCaptorAdditions)

#if DEBUG
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sd_cc_swizzleMethod([UIViewController class], @selector(init), @selector(sd_cc_init));
        // fix some unknown anomalies in iPhoneX.. 
//        sd_cc_swizzleMethod([UIViewController class], @selector(initWithCoder:), @selector(sd_cc_initWithCoder:));
//        sd_cc_swizzleMethod([UIViewController class], @selector(initWithNibName:bundle:), @selector(sd_cc_initWithNibName:bundle:));
    });
}
#endif

- (instancetype)sd_cc_init {
    [self sd_cc_injectCrashCaptorForViewControllerLifeCycle];
    return [self sd_cc_init];
}

- (instancetype)sd_cc_initWithCoder:(NSCoder *)aDecoder {
    [self sd_cc_injectCrashCaptorForViewControllerLifeCycle];
    return [self sd_cc_initWithCoder:aDecoder];
}

- (instancetype)sd_cc_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [self sd_cc_injectCrashCaptorForViewControllerLifeCycle];
    return [self sd_cc_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)sd_cc_injectCrashCaptorForViewControllerLifeCycle {
    NSString *identifier = [NSString stringWithFormat:@"sd_cc_%@", [[NSProcessInfo processInfo] globallyUniqueString]];
    [self addObserver:[TDFSDCCKVOStub sharedInstance] forKeyPath:identifier options:NSKeyValueObservingOptionNew context:nil];
    
    TDFSDCCKVORemoveHelper *helper = [[TDFSDCCKVORemoveHelper alloc] init];
    helper.observeObj = self;
    helper.keyPath = identifier;
    
    objc_setAssociatedObject(self, _cmd, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    Class kvoCls = object_getClass(self);
    Class originCls = class_getSuperclass(kvoCls);
    
    SEL origin_selectors[] = {
        @selector(viewDidLoad),
        @selector(viewWillAppear:),
        @selector(viewDidAppear:),
        @selector(viewWillDisappear:),
        @selector(viewDidDisappear:),
        @selector(viewWillLayoutSubviews),
        @selector(viewDidLayoutSubviews)
    };
    
    IMP new_method_pointers[] = {
        (IMP)sd_cc_viewDidLoad,
        (IMP)sd_cc_viewWillAppear,
        (IMP)sd_cc_viewDidAppear,
        (IMP)sd_cc_viewWillDisappear,
        (IMP)sd_cc_viewDidDisappear,
        (IMP)sd_cc_viewWillLayoutSubviews,
        (IMP)sd_cc_viewDidLayoutSubviews
    };
    
    for (int index = 0; index < sizeof(origin_selectors)/sizeof(SEL); index ++) {
        SEL selector = origin_selectors[index];
        const char *originMethodEncoding = method_getTypeEncoding(class_getInstanceMethod(originCls, selector));
        class_addMethod(kvoCls, selector, new_method_pointers[index], originMethodEncoding);
    }
}

static void sd_cc_viewDidLoad(UIViewController *kvo_vc, SEL sel) { sd_cc_injectCrashCaptor(kvo_vc, sel); }
static void sd_cc_viewWillAppear(UIViewController *kvo_vc, SEL sel, BOOL animated) { sd_cc_injectCrashCaptor(kvo_vc, sel); }
static void sd_cc_viewDidAppear(UIViewController *kvo_vc, SEL sel, BOOL animated) { sd_cc_injectCrashCaptor(kvo_vc, sel); }
static void sd_cc_viewWillDisappear(UIViewController *kvo_vc, SEL sel, BOOL animated) { sd_cc_injectCrashCaptor(kvo_vc, sel); }
static void sd_cc_viewDidDisappear(UIViewController *kvo_vc, SEL sel, BOOL animated) { sd_cc_injectCrashCaptor(kvo_vc, sel); }
static void sd_cc_viewWillLayoutSubviews(UIViewController *kvo_vc, SEL sel) { sd_cc_injectCrashCaptor(kvo_vc, sel); }
static void sd_cc_viewDidLayoutSubviews(UIViewController *kvo_vc, SEL sel) { sd_cc_injectCrashCaptor(kvo_vc, sel); }


static void sd_cc_injectCrashCaptor(UIViewController *vc, SEL sel) {
    Class kvo_cls = object_getClass(vc);
    Class origin_cls = class_getSuperclass(kvo_cls);
    
    IMP origin_imp = method_getImplementation(class_getInstanceMethod(origin_cls, sel));
    assert(origin_imp != NULL);
    
    void(*func)(UIViewController *, SEL) =  (void(*)(UIViewController *, SEL))origin_imp;
    
    @try { func(vc, sel); }
    @catch (NSException *e) {
        if ([[TDFSDPersistenceSetting sharedInstance] allowCrashCaptureFlag]) {
            _needApplyForKeepingLifeCycle = NO;
            ocExceptionHandler(e);
        } else { @throw e; }
    }
}

static void sd_cc_swizzleMethod(Class class, SEL originSEL, SEL newSEL) {
    Method originMethod = class_getInstanceMethod(class, originSEL);
    Method newMethod = class_getInstanceMethod(class, newSEL);
    
    BOOL addMethodSuccess = class_addMethod(class, originSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (addMethodSuccess) {
        class_replaceMethod(class, newSEL, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, newMethod);
    }
}

@end

@interface TDFSDCrashCaptor () <UIViewControllerTransitioningDelegate>

@property (nonatomic, unsafe_unretained) NSUncaughtExceptionHandler *originHandler;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL  needKeepAlive;

@end

@implementation TDFSDCrashCaptor

static const NSString *crashCallStackSymbolLocalizationFailDescription = @"fuzzy localization fail";
static const CGFloat  keepAliveReloadRenderingInterval  = 1 / 60.0f;

#pragma mark - life cycle

#if DEBUG
SD_CONSTRUCTOR_METHOD_DECLARE \
(SD_CONSTRUCTOR_METHOD_PRIORITY_BUILD_CACHE_CRASH_CAPTOR, {
    // build exclusive crash folder in sdk's root folder
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *systemDicPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *crashFolderPath = [[systemDicPath stringByAppendingPathComponent:SD_LOCAL_CACHE_ROOT_FILE_FOLDER_NAME] stringByAppendingPathComponent:SD_CRASH_CAPTOR_CACHE_FILE_FOLDER_NAME];
    BOOL isDictonary;
    if ([fileManager fileExistsAtPath:crashFolderPath isDirectory:&isDictonary] && !isDictonary) {
        [fileManager removeItemAtPath:crashFolderPath error:nil];
    }
    if (![fileManager fileExistsAtPath:crashFolderPath]) {
        [fileManager createDirectoryAtPath:crashFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
})

SD_CONSTRUCTOR_METHOD_DECLARE \
(SD_CONSTRUCTOR_METHOD_PRIORITY_CRASH_CAPTURE, {

    if ([[TDFSDPersistenceSetting sharedInstance] allowCrashCaptureFlag]) {
        // some sdk will dispatch `NSSetUncaughtExceptionHandler` method after about one second when runtime lib had started up
        // if these sdk don't register last exception-handler after their handler, we cannot handle exception normally
        // so we decide to delay the crash captor registration, only that we can handle crashs
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            // here we invoke some unsafe-async api, but if the crash occurs during controller's loading, this may lead to some dead cycle
            // so according to the reason above, we should intercept the crash individually when controller is loaded
            // in `+ load` method, we use runtime to hook all classes which inherit UIViewController and filter out system classes
            [[TDFSDCrashCaptor sharedInstance] thaw];
        });
    }
})
#endif

static TDFSDCrashCaptor *sharedInstance = nil;

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
        _needApplyForKeepingLifeCycle = YES;
    }
    return self;
}

- (void)dealloc {
    [self freeze];
}

#pragma mark - interface methods
- (void)clearHistoryCrashLog {
    NSString *cachePath = SD_CRASH_CAPTOR_CACHE_MODEL_ARCHIVE_PATH;
    NSMutableArray *cacheCrashModels = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    if (!cacheCrashModels || cacheCrashModels.count == 0) {
        return;
    }
    [cacheCrashModels removeAllObjects];
    [NSKeyedArchiver archiveRootObject:cacheCrashModels toFile:cachePath];
}

#pragma mark - TDFSDFunctionIOControlProtocol
- (void)thaw {
    NSArray *machSignals = exSignals();
    for (int index = 0; index < machSignals.count; index ++) {
        signal([machSignals[index] intValue], &machSignalExceptionHandler);
    }
    // Avoid calling dead loops
    if (self.originHandler != &ocExceptionHandler) {
        self.originHandler = NSGetUncaughtExceptionHandler();
    }
    NSSetUncaughtExceptionHandler(&ocExceptionHandler);
}

- (void)freeze {
    NSArray *machSignals = exSignals();
    for (int index = 0; index < machSignals.count; index ++) {
        signal([machSignals[index] intValue], SIG_DFL);
    }
    // In order to prevent multiple SDK capture exception in the case of other SDK can not receive callback,
    // we will register this exception to the next handler
    // https://nianxi.net/ios/ios-crash-reporter.html
    NSSetUncaughtExceptionHandler(self.originHandler);
}

#pragma mark - private
static void machSignalExceptionHandler(int signal) {
    const char* names[NSIG];
    names[SIGABRT] = "SIGABRT";
    names[SIGBUS] = "SIGBUS";
    names[SIGFPE] = "SIGFPE";
    names[SIGILL] = "SIGILL";
    names[SIGPIPE] = "SIGPIPE";
    names[SIGSEGV] = "SIGSEGV";
    
    const char* reasons[NSIG];
    reasons[SIGABRT] = "abort()";
    reasons[SIGBUS] = "bus error";
    reasons[SIGFPE] = "floating point exception";
    reasons[SIGILL] = "illegal instruction (not reset when caught)";
    reasons[SIGPIPE] = "write on a pipe with no one to read it";
    reasons[SIGSEGV] = "segmentation violation";
    
    TDFSDCCCrashModel *crash = [[TDFSDCCCrashModel alloc] init];
    crash.exceptionType = SD_CRASH_EXCEPTION_TYPE_SIGNAL;
    crash.exceptionTime = [[TDFSDCrashCaptor sharedInstance].dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    crash.exceptionName = [NSString stringWithUTF8String:names[signal]];
    crash.exceptionReason = [NSString stringWithUTF8String:reasons[signal]];
    crash.fuzzyLocalization = (NSString *)crashCallStackSymbolLocalizationFailDescription;
    crash.exceptionCallStack = exceptionCallStackInfo();
    
    NSLog(@"%@", crash.debugDescription);
    
    if ([[TDFSDPersistenceSetting sharedInstance] needCacheCrashLogToSandBox]) {
        [[TDFSDCrashCaptor sharedInstance] performSelectorOnMainThread:@selector(cacheCrashLog:) withObject:crash waitUntilDone:YES];
    }
    
    showFriendlyCrashPresentation(crash, @(signal));
    applyForKeepingLifeCycle();
}

static void ocExceptionHandler(NSException *exception) {
    TDFSDCCCrashModel *crash = [[TDFSDCCCrashModel alloc] init];
    crash.exceptionType = SD_CRASH_EXCEPTION_TYPE_OC;
    crash.exceptionTime = [[TDFSDCrashCaptor sharedInstance].dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    crash.exceptionName = [exception name];
    crash.exceptionReason = [exception reason];
    crash.fuzzyLocalization = crashFuzzyLocalization([exception callStackSymbols]);
    crash.exceptionCallStack = [NSString stringWithFormat:@"%@", [[exception callStackSymbols] componentsJoinedByString:@"\n"]];

    NSLog(@"%@", crash.debugDescription);

    if ([[TDFSDPersistenceSetting sharedInstance] needCacheCrashLogToSandBox]) {
        [[TDFSDCrashCaptor sharedInstance] performSelectorOnMainThread:@selector(cacheCrashLog:) withObject:crash waitUntilDone:YES];
    }

    showFriendlyCrashPresentation(crash, exception);
    if (_needApplyForKeepingLifeCycle) {
        applyForKeepingLifeCycle();
    } else {
        _needApplyForKeepingLifeCycle = YES;
    }
}

static NSArray<NSNumber *> * exSignals(void) {
    return @[
            @(SIGABRT),
            @(SIGBUS),
            @(SIGFPE),
            @(SIGILL),
            @(SIGPIPE),
            @(SIGSEGV)
           ];
}

static NSString * exceptionCallStackInfo(void) {
    void* callstack[128];
    const int frames = backtrace(callstack, 128);
    char **symbols = backtrace_symbols(callstack, frames);
    
    NSMutableString *callstackInfo = [NSMutableString string];
    
    for (int index = 0; index < frames; index ++) {
        [callstackInfo appendFormat:@"\t%@\n", [NSString stringWithUTF8String:symbols[index]]];
    }
    
    free(symbols);
    return callstackInfo;
}

static NSString *crashFuzzyLocalization(NSArray<NSString *> *callStackSymbols) {
    __block NSString *fuzzyLocalization = nil;
    NSString *regularExpressionFormatStr = @"[-\\+]\\[.+\\]";
    
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpressionFormatStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    for (int index = 2; index < callStackSymbols.count; index++) {
        NSString *callStackSymbol = callStackSymbols[index];
        
        [regularExp enumerateMatchesInString:callStackSymbol options:NSMatchingReportProgress range:NSMakeRange(0, callStackSymbol.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if (result) {
                NSString* callStackSymbolMsg = [callStackSymbol substringWithRange:result.range];
                NSString *className = [callStackSymbolMsg componentsSeparatedByString:@" "].firstObject;
                className = [className componentsSeparatedByString:@"["].lastObject;
                NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
                
                // filter out system class
                if ([bundle isEqual:[NSBundle mainBundle]]) {
                    fuzzyLocalization = callStackSymbolMsg;
                }
                *stop = YES;
            }
        }];
        
        if (fuzzyLocalization.length) break;
    }
    
    return fuzzyLocalization ?: crashCallStackSymbolLocalizationFailDescription;
}

static void showFriendlyCrashPresentation(TDFSDCCCrashModel *crash, id addition) {
    // find out the toppest and useable window
    NSArray<UIWindow *> *windows = [[UIApplication sharedApplication] windows];
    UIWindow *effectiveWindow = [[[[windows.rac_sequence
    filter:^BOOL(id  _Nullable value) {
        return ![(UIWindow *)value isHidden] && [(UIWindow *)value alpha] != 0;
    }]
    array]
    sortedArrayUsingComparator:^NSComparisonResult(UIWindow * _Nonnull obj1, UIWindow * _Nonnull obj2) {
        if (obj1.windowLevel > obj2.windowLevel) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }]
    firstObject];
    
    TDFSDCrashCapturePresentationController *p = [[TDFSDCrashCapturePresentationController alloc] init];
    p.crashInfo = crash;
    p.exportProxy = [RACSubject subject];
    p.terminateProxy = [RACSubject subject];

    __weak TDFSDCrashCaptor *captor = [TDFSDCrashCaptor sharedInstance];
    [p.exportProxy subscribeNext:^(id  _Nullable x) {
        !captor.sd_didReceiveCrashHandler ?: captor.sd_didReceiveCrashHandler(crash);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            void(^done)(void) = x;
            done();
        });
    }];
    [p.terminateProxy subscribeNext:^(TDFSDCCCrashModel * _Nullable x) {
        TDFSDCrashCaptor *captor = [TDFSDCrashCaptor sharedInstance];
        [captor freeze];
        captor.needKeepAlive = NO;
        if ([x.exceptionType isEqualToString:SD_CRASH_EXCEPTION_TYPE_OC]) {
            NSException *exc = addition;
            [exc raise];
        }
        else if ([x.exceptionType isEqualToString:SD_CRASH_EXCEPTION_TYPE_SIGNAL]) {
            int signal = [addition intValue];
            kill(getpid(), signal);
        }
    }];
    p.transitioningDelegate = [TDFSDCrashCaptor sharedInstance];
    UIViewController *topViewController = [effectiveWindow.rootViewController sd_obtainTopViewController];
    [topViewController presentViewController:p animated:YES completion:nil];
}

static void applyForKeepingLifeCycle(void) {
    
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFArrayRef allModesRef = CFRunLoopCopyAllModes(runloop);
    
    TDFSDCrashCaptor *captor = [TDFSDCrashCaptor sharedInstance];
    
    @synchronized(captor) {
        captor.needKeepAlive = YES;
    }
    
    // let app continue to run
    // gyl-tip:如果跳转到此处并没有成功展示崩溃汇报页，说明此时程序内存已处于不稳定状态，请直接移步Xcode控制台查看协助打印的崩溃日志
    while (captor.needKeepAlive) {
        for (NSString *mode in (__bridge NSArray *)allModesRef) {
            if ([mode isEqualToString:(NSString *)kCFRunLoopCommonModes]) {
                continue;
            }
            CFStringRef modeRef  = (__bridge CFStringRef)mode;
            CFRunLoopRunInMode(modeRef, keepAliveReloadRenderingInterval, false);
        }
    }
    
    CFRelease(allModesRef);
}

- (void)cacheCrashLog:(TDFSDCCCrashModel *)model {
    NSString *cachePath = SD_CRASH_CAPTOR_CACHE_MODEL_ARCHIVE_PATH;
    NSMutableArray *cacheCrashModels = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    if (!cacheCrashModels) {
        cacheCrashModels = @[].mutableCopy;
    }
    if (![cacheCrashModels containsObject:model]) {
        [cacheCrashModels insertObject:model atIndex:0];
    }
    BOOL isSuccess = [NSKeyedArchiver archiveRootObject:cacheCrashModels toFile:cachePath];
    NSLog(@"[TDFScreenDebugger.CrashCaptor.SaveCrashLog] %@", isSuccess ? @"success" : @"failure");
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [TDFSDTransitionAnimator new];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [TDFSDTransitionAnimator new];
}

#pragma mark - getter
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormatter;
}

@end
