//
//  TDFSDCrashCaptor.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/13.
//

#import <Foundation/Foundation.h>
#import "TDFSDFunctionIOControlProtocol.h"
@class TDFSDCCCrashModel;

@interface TDFSDCrashCaptor : NSObject <TDFSDFunctionIOControlProtocol>

+ (instancetype)sharedInstance;
- (void)clearHistoryCrashLog;

/**
 this handler block can be used for customized reporting behavior
 */
@property (nonatomic,  copy) void (^sd_didReceiveCrashHandler)(TDFSDCCCrashModel *crashModel);

@end
