//
//  TDFSDPerformanceMonitor.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/13.
//

#import <Foundation/Foundation.h>
#import "TDFSDFunctionIOControlProtocol.h"
#import "TDFScreenDebuggerDefine.h"
@class TDFSDPMUILagComponentModel;

@interface TDFSDPerformanceMonitor : NSObject <TDFSDFunctionIOControlProtocol>

@property (nonatomic, strong, readonly) NSArray<TDFSDPMUILagComponentModel *> *uiLags;
@property (nonatomic, assign, readonly) int     screenFps;
@property (nonatomic, assign, readonly) CGFloat appCpuUsage;
@property (nonatomic, assign, readonly) CGFloat appMemoryUsage;

+ (instancetype)sharedInstance;

@end
