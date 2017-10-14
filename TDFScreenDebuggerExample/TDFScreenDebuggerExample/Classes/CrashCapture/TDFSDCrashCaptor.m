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
#import <signal.h>
#import <execinfo.h>

@interface TDFSDCrashCaptor ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation TDFSDCrashCaptor

static const NSString *machSignalExceptionFlag = @"sd_mach_signal_exception";

#pragma mark - life cycle

#if DEBUG
SD_CONSTRUCTOR_METHOD_DECLARE \
(SD_CONSTRUCTOR_METHOD_PRIORITY_CRASH_CAPTURE, {
    if ([[TDFSDPersistenceSetting sharedInstance] allowCrashCaptureFlag]) {
        [[TDFSDCrashCaptor sharedInstance] thaw];
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
    NSSetUncaughtExceptionHandler(&ocExceptionHandler);
}

- (void)freeze {
    NSArray *machSignals = exSignals();
    for (int index = 0; index < machSignals.count; index ++) {
        signal([machSignals[index] intValue], SIG_DFL);
    }
    NSSetUncaughtExceptionHandler(NULL);
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
}

static void ocExceptionHandler(NSException *exception) {
    TDFSDCCCrashModel *crash = [[TDFSDCCCrashModel alloc] init];
    crash.exceptionType = SD_CRASH_EXCEPTION_TYPE_OC;
    crash.exceptionTime = [[TDFSDCrashCaptor sharedInstance].dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    crash.exceptionName = [exception name];
    crash.exceptionReason = [exception reason];
    crash.exceptionCallStack = [NSString stringWithFormat:@"\t%@", [[exception callStackSymbols] componentsJoinedByString:@"\n\t"]];
    
    if ([[TDFSDPersistenceSetting sharedInstance] needCacheCrashLogToSandBox]) {
        [[TDFSDCrashCaptor sharedInstance] performSelectorOnMainThread:@selector(cacheCrashLog:) withObject:crash waitUntilDone:YES];
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

- (void)cacheCrashLog:(TDFSDCCCrashModel *)model {
    
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
