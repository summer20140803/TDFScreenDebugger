//
//  TDFALResponseModel.h
//  TDFAPILoggerExample
//
//  Created by 开不了口的猫 on 2017/9/15.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFALBaseModel.h"

@interface TDFALResponseModel : TDFALBaseModel

/**
 请求耗时描述
 */
@property (nonatomic,   copy) NSString *timeConsuming;

/**
 状态码描述
 */
@property (nonatomic,   copy) NSString *statusCode;

/**
 成功响应描述
 */
@property (nonatomic,   copy) NSString *response;

/**
 异常响应描述
 */
@property (nonatomic,   copy) NSString *error;

@end
