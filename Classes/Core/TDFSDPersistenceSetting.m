//
//  TDFSDPersistenceSetting.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/17.
//
//

#import "TDFSDPersistenceSetting.h"
#import "TDFSDFunctionModel.h"
#import "TDFScreenDebuggerDefine.h"

@implementation TDFSDPersistenceSetting

static  NSString * kSDOverallSettingPersistenceKeyMessageRemindType                      =  @"messageRemindType";
static  NSString * kSDOverallSettingPersistenceKeyAllowCatchAPIRecordFlag                =  @"allowCatchAPIRecordFlag";
static  NSString * kSDOverallSettingPersistenceKeyAllowMonitorSystemLogFlag              =  @"allowMonitorSystemLogFlag";
static  NSString * kSDOverallSettingPersistenceKeyLimitSizeOfSingleSystemLogMessageData  =  @"limitSizeOfSingleSystemLogMessageData";
static  NSString * kSDOverallSettingPersistenceKeyAllowCrashCaptureFlag                  =  @"allowCrashCaptureFlag";
static  NSString * kSDOverallSettingPersistenceKeyNeedCacheCrashLogToSandBox             =  @"needCacheCrashLogToSandBox";
static  NSString * kSDOverallSettingPersistenceKeyIsSafeModeForCrashCapture              =  @"isSafeModeForCrashCapture";
static  NSString * kSDOverallSettingPersistenceKeyAllowUILagsMonitoring                  =  @"allowUILagsMonitoring";
static  NSString * kSDOverallSettingPersistenceKeyTolerableLagThreshold                  =  @"tolerableLagThreshold";
static  NSString * kSDOverallSettingPersistenceKeyAllowApplicationCPUMonitoring          =  @"allowApplicationCPUMonitoring";
static  NSString * kSDOverallSettingPersistenceKeyAllowApplicationMemoryMonitoring       =  @"allowApplicationMemoryMonitoring";
static  NSString * kSDOverallSettingPersistenceKeyAllowScreenFPSMonitoring               =  @"allowScreenFPSMonitoring";
static  NSString * kSDOverallSettingPersistenceKeyFpsWarnningThreshold                   =  @"fpsWarnningThreshold";
static  NSString * kSDOverallSettingPersistenceKeyAllowWildPointerMonitoring             =  @"allowWildPointerMonitoring";
static  NSString * kSDOverallSettingPersistenceKeyMaxZombiePoolCapacity                  =  @"maxZombiePoolCapacity";
static  NSString * kSDOverallSettingPersistenceKeyAllowMemoryLeaksDetectionFlag          =  @"allowMemoryLeaksDetectionFlag";
static  NSString * kSDOverallSettingPersistenceKeyMemoryLeakingWarningType               =  @"memoryLeakingWarningType";


@synthesize functionList = _functionList;
@synthesize settingList = _settingList;

static TDFSDPersistenceSetting *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        id unarchiver = [NSKeyedUnarchiver unarchiveObjectWithFile:SD_OVERALL_SETTING_CACHE_FIFLE_PATH];
        if (unarchiver) {
            sharedInstance = unarchiver;
        } else {
            sharedInstance = [[self alloc] init];
        }
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
    if (self = [super init]) {
        _messageRemindType = SDMessageRemindTypeAPIRecord;
        _allowCatchAPIRecordFlag = YES;
        _allowCrashCaptureFlag = YES;
        _needCacheCrashLogToSandBox = YES;
        _isSafeModeForCrashCapture = NO;
        _allowMonitorSystemLogFlag = YES;
        _limitSizeOfSingleSystemLogMessageData = 1024 * 8;
        _allowUILagsMonitoring = YES;
        _tolerableLagThreshold = 0.20f;
        _allowApplicationCPUMonitoring = YES;
        _allowApplicationMemoryMonitoring = YES;
        _allowScreenFPSMonitoring = YES;
        _fpsWarnningThreshold = 30;
        _allowWildPointerMonitoring = NO;
        _maxZombiePoolCapacity = 8 * 1024 * 10;
        _allowMemoryLeaksDetectionFlag = YES;
        _memoryLeakingWarningType = SDMLDWarnningTypeAlert;
    }
    return self;
}

- (NSArray<TDFSDFunctionModel *> *)functionList {
    if (!_functionList) {
        NSMutableArray *functions = @[].mutableCopy;
        
        TDFSDFunctionModel *model = [[TDFSDFunctionModel alloc] init];
        model.index = 0;
        model.functionName = SD_STRING(@"API Recorder(disperse)");
        model.functionIcon = @"icon_screenDebugger_APIRecord_disperse";
        model.functionDescription = SD_STRING(@"“ This is a convenient developer's real-time view disperse API log tool, support for keyword searches. ”");
        model.quickLaunchDescrition = SD_STRING(@"< not specified >");
        [functions addObject:model];
        
        TDFSDFunctionModel *model2 = [[TDFSDFunctionModel alloc] init];
        model2.index = 1;
        model2.functionName = SD_STRING(@"API Recorder(binding)");
        model2.functionIcon = @"icon_screenDebugger_APIRecord_binding";
        model2.functionDescription = SD_STRING(@"“ This is a convenient developer's real-time view binding API log tool, support for keyword searches. ”");
        model2.quickLaunchDescrition = SD_STRING(@"< not specified >");
        [functions addObject:model2];
        
        TDFSDFunctionModel *model3 = [[TDFSDFunctionModel alloc] init];
        model3.index = 2;
        model3.functionName = SD_STRING(@"Log Viewer");
        model3.functionIcon = @"icon_screenDebugger_ASLView";
        model3.functionDescription = SD_STRING(@"“ This is a convenient developer's real-time view system log tool, content filtering can be configured. ”");
        model3.quickLaunchDescrition = SD_STRING(@"< not specified >");
        [functions addObject:model3];
        
        TDFSDFunctionModel *model4 = [[TDFSDFunctionModel alloc] init];
        model4.index = 3;
        model4.functionName = SD_STRING(@"Performance Monitor");
        model4.functionIcon = @"icon_screenDebugger_PerformanceMonitor";
        model4.functionDescription = SD_STRING(@"“ This is a tool which can monitor the main thread and find out some caton nodes will correspond to the stack trace feedback to the developers. ”");
        model4.quickLaunchDescrition = SD_STRING(@"< not specified >");
        [functions addObject:model4];
        
        TDFSDFunctionModel *model5 = [[TDFSDFunctionModel alloc] init];
        model5.index = 4;
        model5.functionName = SD_STRING(@"Crash Captor");
        model5.functionIcon = @"icon_screenDebugger_CrashCapture";
        model5.functionDescription = SD_STRING(@"“ This is a tool which can help device to capture the crash and simply locate the crash information. ”");
        model5.quickLaunchDescrition = SD_STRING(@"< not specified >");
        [functions addObject:model5];
        
        TDFSDFunctionModel *model6 = [[TDFSDFunctionModel alloc] init];
        model6.index = 5;
        model6.functionName = SD_STRING(@"MemoryLeak Detector");
        model6.functionIcon = @"icon_screenDebugger_MemoryLeak";
        model6.functionDescription = SD_STRING(@"“ This is a tool which can help developer to find out some suspicious memory leak points in project. ”");
        model6.quickLaunchDescrition = SD_STRING(@"< not specified >");
        [functions addObject:model6];
        
        TDFSDFunctionModel *model7 = [[TDFSDFunctionModel alloc] init];
        model7.index = 6;
        model7.functionName = SD_STRING(@"WildPointer Checker");
        model7.functionIcon = @"icon_screenDebugger_WildPointer";
        model7.functionDescription = SD_STRING(@"“ This is a tool which can help developer to find out some wild pointer errors in project. ”");
        model7.quickLaunchDescrition = SD_STRING(@"< not specified >");
        [functions addObject:model7];
        
        TDFSDFunctionModel *model8 = [[TDFSDFunctionModel alloc] init];
        model8.index = 7;
        model8.functionName = SD_STRING(@"RetainCycle Monitor");
        model8.functionIcon = @"icon_screenDebugger_RetainCycle";
        model8.functionDescription = SD_STRING(@"“ This is a tool which can help developer to find out retain-cycle nodes in project. ”");
        model8.quickLaunchDescrition = SD_STRING(@"< not specified >");
        [functions addObject:model8];
        
        TDFSDFunctionModel *model10 = [[TDFSDFunctionModel alloc] init];
        model10.index = 8;
        model10.functionName = SD_STRING(@"Help");
        model10.functionIcon = @"icon_screenDebugger_help";
        model10.functionDescription = SD_STRING(@"“ Introduce some basic operations and data options about how using the debugger. ”");
        model10.quickLaunchDescrition = SD_STRING(@"< no quick launch available >");
        [functions addObject:model10];
        
        _functionList = [functions copy];
    }
    return _functionList;
}

- (NSArray<NSDictionary<NSString *,id> *> *)settingList {
    if (!_settingList) {
        NSString *plistPath = [SD_BUNDLE pathForResource:@"TDFSDOverallSettingConfiguration" ofType:@"plist"];
        _settingList = [[NSArray alloc] initWithContentsOfFile:plistPath];
    }
    return _settingList;
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _messageRemindType = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyMessageRemindType] unsignedIntegerValue];
        _allowCatchAPIRecordFlag = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowCatchAPIRecordFlag] boolValue];
        _allowMonitorSystemLogFlag = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowMonitorSystemLogFlag] boolValue];
        _limitSizeOfSingleSystemLogMessageData = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyLimitSizeOfSingleSystemLogMessageData] integerValue];
        _allowCrashCaptureFlag = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowCrashCaptureFlag] boolValue];
        _needCacheCrashLogToSandBox = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyNeedCacheCrashLogToSandBox] boolValue];
        _isSafeModeForCrashCapture = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyIsSafeModeForCrashCapture] boolValue];
        _allowUILagsMonitoring = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowUILagsMonitoring] boolValue];
        _tolerableLagThreshold = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyTolerableLagThreshold] doubleValue];
        _allowApplicationCPUMonitoring = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowApplicationCPUMonitoring] boolValue];
        _allowApplicationMemoryMonitoring = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowApplicationMemoryMonitoring] boolValue];
        _allowScreenFPSMonitoring = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowScreenFPSMonitoring] boolValue];
        _fpsWarnningThreshold = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyFpsWarnningThreshold] unsignedIntegerValue];
//        _allowWildPointerMonitoring = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowWildPointerMonitoring] boolValue];
        _allowWildPointerMonitoring = NO;
        _maxZombiePoolCapacity = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyMaxZombiePoolCapacity] unsignedLongValue];
        _allowMemoryLeaksDetectionFlag = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowMemoryLeaksDetectionFlag] boolValue];
        _memoryLeakingWarningType = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyMemoryLeakingWarningType] unsignedIntegerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_messageRemindType) forKey:kSDOverallSettingPersistenceKeyMessageRemindType];
    [aCoder encodeObject:@(_allowCatchAPIRecordFlag) forKey:kSDOverallSettingPersistenceKeyAllowCatchAPIRecordFlag];
    [aCoder encodeObject:@(_allowMonitorSystemLogFlag) forKey:kSDOverallSettingPersistenceKeyAllowMonitorSystemLogFlag];
    [aCoder encodeObject:@(_limitSizeOfSingleSystemLogMessageData) forKey:kSDOverallSettingPersistenceKeyLimitSizeOfSingleSystemLogMessageData];
    [aCoder encodeObject:@(_allowCrashCaptureFlag) forKey:kSDOverallSettingPersistenceKeyAllowCrashCaptureFlag];
    [aCoder encodeObject:@(_needCacheCrashLogToSandBox) forKey:kSDOverallSettingPersistenceKeyNeedCacheCrashLogToSandBox];
    [aCoder encodeObject:@(_isSafeModeForCrashCapture) forKey:kSDOverallSettingPersistenceKeyIsSafeModeForCrashCapture];
    [aCoder encodeObject:@(_allowUILagsMonitoring) forKey:kSDOverallSettingPersistenceKeyAllowUILagsMonitoring];
    [aCoder encodeObject:@(_tolerableLagThreshold) forKey:kSDOverallSettingPersistenceKeyTolerableLagThreshold];
    [aCoder encodeObject:@(_allowApplicationCPUMonitoring) forKey:kSDOverallSettingPersistenceKeyAllowApplicationCPUMonitoring];
    [aCoder encodeObject:@(_allowApplicationMemoryMonitoring) forKey:kSDOverallSettingPersistenceKeyAllowApplicationMemoryMonitoring];
    [aCoder encodeObject:@(_allowScreenFPSMonitoring) forKey:kSDOverallSettingPersistenceKeyAllowScreenFPSMonitoring];
    [aCoder encodeObject:@(_fpsWarnningThreshold) forKey:kSDOverallSettingPersistenceKeyFpsWarnningThreshold];
//    [aCoder encodeObject:@(_allowWildPointerMonitoring) forKey:kSDOverallSettingPersistenceKeyAllowWildPointerMonitoring];
    [aCoder encodeObject:@(_maxZombiePoolCapacity) forKey:kSDOverallSettingPersistenceKeyMaxZombiePoolCapacity];
    [aCoder encodeObject:@(_allowMemoryLeaksDetectionFlag) forKey:kSDOverallSettingPersistenceKeyAllowMemoryLeaksDetectionFlag];
    [aCoder encodeObject:@(_memoryLeakingWarningType) forKey:kSDOverallSettingPersistenceKeyMemoryLeakingWarningType];
}

@end
