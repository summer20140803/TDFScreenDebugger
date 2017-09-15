//
//  TDFAPILogger.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/5.
//
//

#import <Foundation/Foundation.h>
#import "TDFALRequestModel.h"
#import "TDFALResponseModel.h"

//======================================
// 运行期可通过LLDB `expr`命令实时修改的变量
//======================================

// 所有API日志的统一开关
CF_EXPORT BOOL  TDFAPILoggerEnabled;
// 请求日志的可定制格式符号
CF_EXPORT char *TDFAPILoggerRequestLogIcon;
// 响应日志的可定制格式符号
CF_EXPORT char *TDFAPILoggerResponseLogIcon;
// 异常日志的可定制格式符号
CF_EXPORT char *TDFAPILoggerErrorLogIcon;


//============================
//   可定制的API日志的组成元素
//============================

typedef NS_OPTIONS(NSUInteger, TDFAPILoggerRequestElement) {
    /** API起飞时间 */
    TDFAPILoggerRequestElementTakeOffTime        = 1 << 0,
    /** API请求方式 */
    TDFAPILoggerRequestElementMethod             = 1 << 1,
    /** API有效的请求路径 */
    TDFAPILoggerRequestElementVaildURL           = 1 << 2,
    /** API请求头字段 */
    TDFAPILoggerRequestElementHeaderFields       = 1 << 3,
    /** API请求体(一般是入参) */
    TDFAPILoggerRequestElementHTTPBody           = 1 << 4,
    /** API任务唯一标识 */
    TDFAPILoggerRequestElementTaskIdentifier     = 1 << 5,
};

typedef NS_OPTIONS(NSUInteger, TDFAPILoggerResponseElement) {
    /** API着陆时间 */
    TDFAPILoggerResponseElementLandTime          = 1 << 0,
    /** API请求-响应耗时 */
    TDFAPILoggerResponseElementTimeConsuming     = 1 << 1,
    /** API请求方式 */
    TDFAPILoggerResponseElementMethod            = 1 << 2,
    /** API有效的请求路径 */
    TDFAPILoggerResponseElementVaildURL          = 1 << 3,
    /** API响应头字段 */
    TDFAPILoggerResponseElementHeaderFields      = 1 << 4,
    /** API响应状态码 */
    TDFAPILoggerResponseElementStatusCode        = 1 << 5,
    /** API响应主体(或者异常) */
    TDFAPILoggerResponseElementResponse          = 1 << 6,
    /** API任务唯一标识 */
    TDFAPILoggerResponseElementTaskIdentifier    = 1 << 7,
};


@interface TDFAPILogger : NSObject

/**
 请求日志 可定制的组成元素
 */
@property (nonatomic, assign) TDFAPILoggerRequestElement  requestLoggerElements;

/**
 响应日志/异常日志 可定制的组成元素
 */
@property (nonatomic, assign) TDFAPILoggerResponseElement responseLoggerElements;

/**
 服务模块白名单，
 可用来在研发自己模块期间屏蔽其他模块的API日志，
 默认应用服务端全部模块
 */
@property (nonatomic, strong) NSArray<NSString *> *       serverModuleWhiteList;

/**
 AFN内部指定task的taskDescription的对象，
 一般是项目工程里直接接触和封装AFNetworking的单例对象，
 比如`TDFHTTPClient`单例对象
 */
@property (nonatomic, strong) id                          defaultTaskDescriptionObj;

/**
 API日志过滤器，
 在打印请求日志和响应日志之前都会通过这个block询问是否需要打印，
 block会将请求或者响应时获取的NSURLRequest子类实例返回给外部，
 外部通过request去作一些自定义的判定处理，
 return YES表示需要打印，return NO表示过滤这些日志
 */
@property (nonatomic,   copy) BOOL(^loggerFilter)(__kindof const NSURLRequest *request);

/**
 API请求日志汇报者，
 会在格式化后(不包括emoji)的请求描述模型通过这个block传给外部
 */
@property (nonatomic,   copy) void(^requestLogReporter)(TDFALRequestModel *requestLogDescription);

/**
 API响应日志汇报者，
 会在格式化后(不包括emoji)的响应描述模型通过这个block传给外部
 */
@property (nonatomic,   copy) void(^responseLogReporter)(TDFALResponseModel *responseLogDescription);


/**
 获取单例
 @return 单例
 */
+ (instancetype)sharedInstance;

/**
 开启API日志
 */
- (void)open;

/**
 关闭API日志
 (一般不需要这么做)
 */
- (void)close;

@end
