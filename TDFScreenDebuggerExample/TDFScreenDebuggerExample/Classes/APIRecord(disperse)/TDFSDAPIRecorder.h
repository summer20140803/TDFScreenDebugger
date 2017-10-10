//
//  TDFSDAPIRecorder.h
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/14.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TDFAPILogger/TDFAPILogger.h>

@interface TDFSDAPIRecorder : NSObject

@property (nonatomic, strong, readonly) NSArray<__kindof TDFALBaseModel *> *descriptionModels;
@property (nonatomic, strong, readonly) NSArray<TDFALRequestModel *> *requestDesModels;
@property (nonatomic, strong, readonly) NSArray<TDFALResponseModel *> *responseDesModels;

+ (instancetype)sharedInstance;

- (void)clearAllRecords;

@end
