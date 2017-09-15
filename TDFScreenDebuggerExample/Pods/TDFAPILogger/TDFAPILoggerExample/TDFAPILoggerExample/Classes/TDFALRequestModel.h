//
//  TDFALRequestModel.h
//  TDFAPILoggerExample
//
//  Created by 开不了口的猫 on 2017/9/15.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFALBaseModel.h"

@interface TDFALRequestModel : TDFALBaseModel

/**
 请求体描述
 */
@property (nonatomic,   copy) NSString *httpBody;

@end
