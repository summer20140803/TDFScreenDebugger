//
//  TDFALBaseModel.h
//  TDFAPILoggerExample
//
//  Created by 开不了口的猫 on 2017/9/15.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TDFALBaseModel : NSObject

/**
 任务唯一标识描述
 */
@property (nonatomic,   copy) NSString *taskIdentifier;

/**
 请求URL描述
 */
@property (nonatomic,   copy) NSString *validURL;

/**
 里程碑时间描述
 */
@property (nonatomic,   copy) NSString *milestoneTime;

/**
 请求方法描述
 */
@property (nonatomic,   copy) NSString *method;

/**
 请求/响应头字段描述
 */
@property (nonatomic,   copy) NSString *headerFields;

/**
 API任务描述
 */
@property (nonatomic,   copy) NSString *taskDescription;

/**
 默认的对象描述
 */
@property (nonatomic,   copy) NSString *selfDescription;

@end
