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
#import <ReactiveObjC/ReactiveObjC.h>
#import <signal.h>
#import <execinfo.h>

@interface TDFSDCrashCaptor () <UIViewControllerTransitioningDelegate>

@property (nonatomic, unsafe_unretained) NSUncaughtExceptionHandler *originHandler;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL  needKeepAlive;

@end

@implementation TDFSDCrashCaptor

static const NSString *machSignalExceptionFlag          = @"sd_mach_signal_exception";
static const CGFloat  keepAliveReloadRenderingInterval  = 1 / 120.0f;

#pragma mark - life cycle

#if DEBUG
SD_CONSTRUCTOR_METHOD_DECLARE \
(SD_CONSTRUCTOR_METHOD_PRIORITY_CRASH_CAPTURE, {
    if ([[TDFSDPersistenceSetting sharedInstance] allowCrashCaptureFlag]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[TDFSDCrashCaptor sharedInstance] thaw];
        });
    }
})
#endif

+ (instancetype)sharedInstance {
    static TDFSDCrashCaptor *sharedInstance = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc {
    [self freeze];
}

#pragma mark - interface methods
- (void)clearHistoryCrashLog {

}

#pragma mark - TDFSDFunctionIOControlProtocol
- (void)thaw {
    NSArray *machSignals = exSignals();
    for (int index = 0; index < machSignals.count; index ++) {
        signal([machSignals[index] intValue], &machSignalExceptionHandler);
    }
    // Avoid calling loops
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
    crash.exceptionCallStack = exceptionCallStackInfo();
    
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
    crash.exceptionCallStack = [NSString stringWithFormat:@"%@", [[exception callStackSymbols] componentsJoinedByString:@"\n"]];
    
    NSLog(@"%@", crash.debugDescription);

    if ([[TDFSDPersistenceSetting sharedInstance] needCacheCrashLogToSandBox]) {
        [[TDFSDCrashCaptor sharedInstance] performSelectorOnMainThread:@selector(cacheCrashLog:) withObject:crash waitUntilDone:YES];
    }

    showFriendlyCrashPresentation(crash, exception);
    applyForKeepingLifeCycle();
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
    [p.exportProxy subscribeNext:^(id  _Nullable x) {
        ////// export code //////
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            void(^done)() = x;
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
    [effectiveWindow.rootViewController presentViewController:p animated:YES completion:nil];
}

static void applyForKeepingLifeCycle(void) {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFArrayRef allModesRef = CFRunLoopCopyAllModes(runloop);
    
    TDFSDCrashCaptor *captor = [TDFSDCrashCaptor sharedInstance];
    
    @synchronized(captor) {
        captor.needKeepAlive = YES;
    }
    
    // let app continue to run
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
