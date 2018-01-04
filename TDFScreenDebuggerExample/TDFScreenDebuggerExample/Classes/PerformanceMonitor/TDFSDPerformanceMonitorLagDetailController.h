//
//  TDFSDPerformanceMonitorLagDetailController.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/29.
//

#import "TDFSDFullScreenConsoleController.h"
@class TDFSDPMUILagComponentModel;

@interface TDFSDPerformanceMonitorLagDetailController : TDFSDFullScreenConsoleController

@property (nonatomic, strong) TDFSDPMUILagComponentModel *lag;

@end
