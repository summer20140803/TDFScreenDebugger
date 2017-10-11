//
//  TDFSDLVLogManager.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/5.
//

#import <Foundation/Foundation.h>
@class TDFSDLVLogModel;


@interface TDFSDLVLogManager : NSObject

@property (nonatomic, strong, readonly) NSArray<TDFSDLVLogModel *> *logs;

+ (instancetype)manager;

- (void)clearCurrentSystemLogs;

- (void)thaw;
- (void)freeze;

@end
