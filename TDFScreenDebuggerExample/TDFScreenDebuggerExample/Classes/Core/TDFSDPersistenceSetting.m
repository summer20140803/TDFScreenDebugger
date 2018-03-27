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
static  NSString * kSDOverallSettingPersistenceKeyAllowUILagsMonitoring                  =  @"allowUILagsMonitoring";
static  NSString * kSDOverallSettingPersistenceKeyTolerableLagThreshold                  =  @"tolerableLagThreshold";
static  NSString * kSDOverallSettingPersistenceKeyAllowApplicationCPUMonitoring          =  @"allowApplicationCPUMonitoring";
static  NSString * kSDOverallSettingPersistenceKeyAllowApplicationMemoryMonitoring       =  @"allowApplicationMemoryMonitoring";
static  NSString * kSDOverallSettingPersistenceKeyAllowScreenFPSMonitoring               =  @"allowScreenFPSMonitoring";
static  NSString * kSDOverallSettingPersistenceKeyFpsWarnningThreshold                   =  @"fpsWarnningThreshold";
static  NSString * kSDOverallSettingPersistenceKeyAllowWildPointerMonitoring             =  @"allowWildPointerMonitoring";

@synthesize functionList = _functionList;
@synthesize settingList = _settingList;

+ (instancetype)sharedInstance {
    static TDFSDPersistenceSetting *setting = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        id unarchiver = [NSKeyedUnarchiver unarchiveObjectWithFile:SD_OVERALL_SETTING_CACHE_FIFLE_PATH];
        if (unarchiver) {
            setting = unarchiver;
        } else {
            setting = [[self alloc] init];
        }
    });
    return setting;
}

- (instancetype)init {
    if (self = [super init]) {
        _messageRemindType = SDMessageRemindTypeAPIRecord;
        _allowCatchAPIRecordFlag = YES;
        _allowCrashCaptureFlag = YES;
        _needCacheCrashLogToSandBox = YES;
        _allowMonitorSystemLogFlag = YES;
        _limitSizeOfSingleSystemLogMessageData = 1024 * 10;
        _allowUILagsMonitoring = YES;
        _tolerableLagThreshold = 0.20f;
        _allowApplicationCPUMonitoring = YES;
        _allowApplicationMemoryMonitoring = YES;
        _allowScreenFPSMonitoring = YES;
        _fpsWarnningThreshold = 30;
        _allowWildPointerMonitoring = NO;
    }
    return self;
}

- (NSArray<TDFSDFunctionModel *> *)functionList {
    
    NSMutableArray *functions = @[].mutableCopy;
    
    TDFSDFunctionModel *model = [[TDFSDFunctionModel alloc] init];
    model.index = 0;
    model.functionName = @"API Recorder(disperse)";
    model.functionIcon = @"icon_screenDebugger_APIRecord_disperse";
    model.functionDescription = @"“ This is a convenient developer's real-time view disperse API log tool, support for keyword searches. ”";
    model.quickLaunchDescrition = @"< not specified >";
    [functions addObject:model];
    
    TDFSDFunctionModel *model2 = [[TDFSDFunctionModel alloc] init];
    model2.index = 1;
    model2.functionName = @"API Recorder(binding)";
    model2.functionIcon = @"icon_screenDebugger_APIRecord_binding";
    model2.functionDescription = @"“ This is a convenient developer's real-time view binding API log tool, support for keyword searches. ”";
    model2.quickLaunchDescrition = @"< not specified >";
    [functions addObject:model2];
    
    TDFSDFunctionModel *model3 = [[TDFSDFunctionModel alloc] init];
    model3.index = 2;
    model3.functionName = @"Log Viewer";
    model3.functionIcon = @"icon_screenDebugger_ASLView";
    model3.functionDescription = @"“ This is a convenient developer's real-time view API log tool, content filtering can be configured. ”";
    model3.quickLaunchDescrition = @"< not specified >";
    [functions addObject:model3];
    
    TDFSDFunctionModel *model4 = [[TDFSDFunctionModel alloc] init];
    model4.index = 3;
    model4.functionName = @"Performance Monitor";
    model4.functionIcon = @"icon_screenDebugger_PerformanceMonitor";
    model4.functionDescription = @"“ This is a tool which can monitor the main thread and find out some caton nodes will correspond to the stack trace feedback to the developers. ”";
    model4.quickLaunchDescrition = @"< not specified >";
    [functions addObject:model4];
    
    TDFSDFunctionModel *model5 = [[TDFSDFunctionModel alloc] init];
    model5.index = 4;
    model5.functionName = @"Crash Captor";
    model5.functionIcon = @"icon_screenDebugger_CrashCapture";
    model5.functionDescription = @"“ This is a tool which can help device to capture the crash and simply locate the crash information. ”";
    model5.quickLaunchDescrition = @"< not specified >";
    [functions addObject:model5];
    
    TDFSDFunctionModel *model6 = [[TDFSDFunctionModel alloc] init];
    model6.index = 5;
    model6.functionName = @"RetainCycle Monitor";
    model6.functionIcon = @"icon_screenDebugger_RetainCycle";
    model6.functionDescription = @"“ This is a tool which can help developer to find out retain-cycle nodes in project. ”";
    model6.quickLaunchDescrition = @"< not specified >";
    [functions addObject:model6];
    
    TDFSDFunctionModel *model7 = [[TDFSDFunctionModel alloc] init];
    model7.index = 6;
    model7.functionName = @"关于使用";
    model7.functionIcon = @"icon_screenDebugger_help";
    model7.functionDescription = @"一些关于调试器使用的基本操作和数据选项说明";
    model7.quickLaunchDescrition = @"< no quick launch available >";
    [functions addObject:model7];
    
    return functions;
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
        _allowUILagsMonitoring = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowUILagsMonitoring] boolValue];
        _tolerableLagThreshold = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyTolerableLagThreshold] doubleValue];
        _allowApplicationCPUMonitoring = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowApplicationCPUMonitoring] boolValue];
        _allowApplicationMemoryMonitoring = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowApplicationMemoryMonitoring] boolValue];
        _allowScreenFPSMonitoring = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowScreenFPSMonitoring] boolValue];
        _fpsWarnningThreshold = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyFpsWarnningThreshold] unsignedIntegerValue];
//        _allowWildPointerMonitoring = [[aDecoder decodeObjectForKey:kSDOverallSettingPersistenceKeyAllowWildPointerMonitoring] boolValue];
        _allowWildPointerMonitoring = NO;
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
    [aCoder encodeObject:@(_allowUILagsMonitoring) forKey:kSDOverallSettingPersistenceKeyAllowUILagsMonitoring];
    [aCoder encodeObject:@(_tolerableLagThreshold) forKey:kSDOverallSettingPersistenceKeyTolerableLagThreshold];
    [aCoder encodeObject:@(_allowApplicationCPUMonitoring) forKey:kSDOverallSettingPersistenceKeyAllowApplicationCPUMonitoring];
    [aCoder encodeObject:@(_allowApplicationMemoryMonitoring) forKey:kSDOverallSettingPersistenceKeyAllowApplicationMemoryMonitoring];
    [aCoder encodeObject:@(_allowScreenFPSMonitoring) forKey:kSDOverallSettingPersistenceKeyAllowScreenFPSMonitoring];
    [aCoder encodeObject:@(_fpsWarnningThreshold) forKey:kSDOverallSettingPersistenceKeyFpsWarnningThreshold];
//    [aCoder encodeObject:@(_allowWildPointerMonitoring) forKey:kSDOverallSettingPersistenceKeyAllowWildPointerMonitoring];
}

@end
