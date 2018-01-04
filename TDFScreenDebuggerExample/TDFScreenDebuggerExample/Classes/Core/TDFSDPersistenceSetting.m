//
//  TDFSDPersistenceSetting.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/17.
//
//

#import "TDFSDPersistenceSetting.h"
#import "TDFSDFunctionModel.h"

@implementation TDFSDPersistenceSetting

+ (instancetype)sharedInstance {
    static TDFSDPersistenceSetting *setting = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        setting = [[self alloc] init];
        setting.messageRemindType = SDMessageRemindTypeSystemLog;
        setting.allowCatchAPIRecordFlag = YES;
        setting.allowCrashCaptureFlag = YES;
        setting.needCacheCrashLogToSandBox = YES;
        setting.allowMonitorSystemLogFlag = YES;
        setting.limitSizeOfSingleSystemLogMessageData = 1024 * 10;
        setting.allowUILagsMonitoring = YES;
        setting.tolerableLagThreshold = 0.20f;
        setting.allowApplicationCPUMonitoring = YES;
        setting.allowApplicationMemoryMonitoring = YES;
        setting.allowScreenFPSMonitoring = YES;
        setting.fpsWarnningThreshold = 56.0f;
    });
    return setting;
}

- (NSArray<TDFSDFunctionModel *> *)functionList {
    
    NSMutableArray *functions = @[].mutableCopy;
    
    TDFSDFunctionModel *model = [[TDFSDFunctionModel alloc] init];
    model.index = 0;
    model.functionName = @"API Recorder(disperse)";
    model.functionIcon = @"icon_screenDebugger_APIRecord_disperse";
    model.functionDescription = @"“ This is a convenient developer's real-time view disperse API log tool, support for keyword searches. ”";
    model.quickLaunchDescrition = @"< just tap once >";
    [functions addObject:model];
    
    TDFSDFunctionModel *model2 = [[TDFSDFunctionModel alloc] init];
    model2.index = 1;
    model2.functionName = @"API Recorder(binding)";
    model2.functionIcon = @"icon_screenDebugger_APIRecord_binding";
    model2.functionDescription = @"“ This is a convenient developer's real-time view binding API log tool, support for keyword searches. ”";
    model2.quickLaunchDescrition = @"< just tap twice >";
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

    return functions;
}

@end
