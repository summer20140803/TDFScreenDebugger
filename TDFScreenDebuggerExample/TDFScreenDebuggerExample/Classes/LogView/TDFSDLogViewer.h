//
//  TDFSDLVLogManager.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/5.
//

#import <Foundation/Foundation.h>
#import "TDFSDFunctionIOControlProtocol.h"
@class TDFSDLVLogModel;


@interface TDFSDLogViewer : NSObject <TDFSDFunctionIOControlProtocol>

@property (nonatomic, strong, readonly) NSArray<TDFSDLVLogModel *> *logs;

+ (instancetype)sharedInstance;

- (void)clearCurrentSystemLogs;

@end
