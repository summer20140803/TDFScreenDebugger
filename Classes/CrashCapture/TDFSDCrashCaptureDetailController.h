//
//  TDFSDCrashCaptureDetailController.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/7.
//

#import "TDFSDFullScreenConsoleController.h"
@class TDFSDCCCrashModel;

@interface TDFSDCrashCaptureDetailController : TDFSDFullScreenConsoleController

@property (nonatomic, strong) TDFSDCCCrashModel *crash;

@end
