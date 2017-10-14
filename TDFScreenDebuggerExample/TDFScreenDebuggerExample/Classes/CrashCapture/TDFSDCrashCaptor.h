//
//  TDFSDCrashCaptor.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/13.
//

#import <Foundation/Foundation.h>
#import "TDFSDFunctionIOControlProtocol.h"

@interface TDFSDCrashCaptor : NSObject <TDFSDFunctionIOControlProtocol>

+ (instancetype)sharedInstance;

- (void)clearHistoryCrashLog;

@end
