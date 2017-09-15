//
//  TDFAPILogger.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/5.
//
//

#import "TDFAPILogger.h"
#import <AFNetworking/AFURLSessionManager.h>
#import <objc/runtime.h>

typedef void (^tdfJsonResponsePrettyPrintFormatBlock)(id betterResponseString);
typedef void (^tdfHttpBodyStreamParseBlock)(NSData *streamData);
static dispatch_queue_t _tdfJsonResponseFormatQueue;

BOOL   TDFAPILoggerEnabled         = YES;
char  *TDFAPILoggerRequestLogIcon  = "✈️";
char  *TDFAPILoggerResponseLogIcon = "☀️";
char  *TDFAPILoggerErrorLogIcon    = "❌";


static NSURLRequest * TDFAPILoggerRequestFromAFNNotification(NSNotification *notification) {
    NSURLSessionTask *task = notification.object;
    NSURLRequest *request = task.originalRequest ?: task.currentRequest;
    return request;
}

static NSURLResponse * TDFAPILoggerResponseFromAFNNotification(NSNotification *notification) {
    NSURLSessionTask *task = notification.object;
    NSURLResponse *response = task.response;
    return response;
}

static NSError * TDFAPILoggerErrorFromAFNNotification(NSNotification *notification) {
    NSURLSessionTask *task = notification.object;
    NSError *error = task.error ?: notification.userInfo[AFNetworkingTaskDidCompleteErrorKey];
    return error;
}

static NSString * TDFAPILoggerTaskIdentifierFromAFNNotification(NSNotification *notification) {
    NSURLSessionTask *task = notification.object;
    NSString *taskIdentifier = @(task.taskIdentifier).stringValue;
    return taskIdentifier;
}

static const char* TDFAPILoggerMarkedLine(char* c, uint length) {
    NSMutableString *foldLeft = @"".mutableCopy;
    [[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, length)] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [foldLeft appendString:[NSString stringWithUTF8String:c]];
    }];
    return [[foldLeft copy] UTF8String];
}

static void TDFAPILoggerAsyncJsonResponsePrettyFormat(id response, tdfJsonResponsePrettyPrintFormatBlock block) {
    if (![NSJSONSerialization isValidJSONObject:response]) {
        !block ?: block(response);
        return;
    }
    dispatch_barrier_async(_tdfJsonResponseFormatQueue, ^{
        NSError *formatError = nil;
        NSString *prettyJsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:&formatError] encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            id better = formatError ? response : prettyJsonString;
            !block ?: block(better);
        });
    });
}

static void TDFAPILoggerAsyncHttpBodyStreamParse(NSInputStream *originBodyStream, tdfHttpBodyStreamParseBlock block) {
    
    // this is a bug may cause image can't upload when other thread read the same bodystream
    // copy origin body stream and use the new can avoid this issure
    NSInputStream *bodyStream = [originBodyStream copy];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [bodyStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [bodyStream open];
        
        uint8_t *buffer = NULL;
        NSMutableData *streamData = [NSMutableData data];
        
        while ([bodyStream hasBytesAvailable]) {
            buffer = (uint8_t *)malloc(sizeof(uint8_t) * 1024);
            NSInteger length = [bodyStream read:buffer maxLength:sizeof(uint8_t) * 1024];
            if (bodyStream.streamError || length <= 0) {
                break;
            }
            [streamData appendBytes:buffer length:length];
            free(buffer);
        }
        [bodyStream close];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            !block ?: block([streamData copy]);
        });
    });
}

static void TDFAPILoggerShowRequest(NSString *fmrtStr) {
#if DEBUG
    if (TDFAPILoggerEnabled) {
        printf("\n%s", TDFAPILoggerMarkedLine(TDFAPILoggerRequestLogIcon, 17));
        printf("  ← 请求日志 →  ");
        printf("%s\n", TDFAPILoggerMarkedLine(TDFAPILoggerRequestLogIcon, 17));
        printf("%s\n", [fmrtStr UTF8String]);
        printf("\n%s\n", TDFAPILoggerMarkedLine(TDFAPILoggerRequestLogIcon, 40));
    }
#endif
}

static void TDFAPILoggerShowResponse(NSString *fmrtStr) {
#if DEBUG
    if (TDFAPILoggerEnabled) {
        printf("\n%s", TDFAPILoggerMarkedLine(TDFAPILoggerResponseLogIcon, 17));
        printf("  ← 响应日志 →  ");
        printf("%s\n", TDFAPILoggerMarkedLine(TDFAPILoggerResponseLogIcon, 17));
        printf("%s\n", [fmrtStr UTF8String]);
        printf("\n%s\n", TDFAPILoggerMarkedLine(TDFAPILoggerResponseLogIcon, 40));
    }
#endif
}

static void TDFAPILoggerShowError(NSString *fmrtStr) {
#if DEBUG
    if (TDFAPILoggerEnabled) {
        printf("\n%s", TDFAPILoggerMarkedLine(TDFAPILoggerErrorLogIcon, 17));
        printf("  ← 异常日志 →  ");
        printf("%s\n", TDFAPILoggerMarkedLine(TDFAPILoggerErrorLogIcon, 17));
        printf("%s\n", [fmrtStr UTF8String]);
        printf("\n%s\n", TDFAPILoggerMarkedLine(TDFAPILoggerErrorLogIcon, 40));
    }
#endif
}

@implementation TDFAPILogger

+ (instancetype)sharedInstance {
    static TDFAPILogger *logger = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        logger = [[self alloc] init];
        _tdfJsonResponseFormatQueue = dispatch_queue_create("TDFAPILogger.JsonResponsePrettyFormat", DISPATCH_QUEUE_CONCURRENT);
    });
    return logger;
}

- (instancetype)init {
    if (self = [super init]) {
        // default settings..
        _requestLoggerElements =
        TDFAPILoggerRequestElementTakeOffTime |
        TDFAPILoggerRequestElementMethod |
        TDFAPILoggerRequestElementVaildURL |
        TDFAPILoggerRequestElementHeaderFields |
        TDFAPILoggerRequestElementHTTPBody |
        TDFAPILoggerRequestElementTaskIdentifier;
        _responseLoggerElements =
        TDFAPILoggerResponseElementLandTime |
        TDFAPILoggerResponseElementTimeConsuming |
        TDFAPILoggerResponseElementMethod |
        TDFAPILoggerResponseElementVaildURL |
        TDFAPILoggerResponseElementHeaderFields |
        TDFAPILoggerResponseElementStatusCode |
        TDFAPILoggerResponseElementResponse |
        TDFAPILoggerResponseElementTaskIdentifier;
    }
    return self;
}

- (void)dealloc {
    [self close];
}

- (void)open {
#if DEBUG
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiDidTakeOff:) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiDidLand:) name:AFNetworkingTaskDidCompleteNotification object:nil];
#endif
}

- (void)close {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - callback

static void * TDFAPILoggerTakeOffDate = &TDFAPILoggerTakeOffDate;

- (void)apiDidTakeOff:(NSNotification *)notification {
    NSURLRequest *request = TDFAPILoggerRequestFromAFNNotification(notification);
    
    if (!request && !(self.requestLoggerElements & 0x00) && (!self.loggerFilter || self.loggerFilter(request))) return;
    
    // In addition，check whiteList for shielding some needless api log..
    if (self.serverModuleWhiteList && self.serverModuleWhiteList.count) {
        NSString *urlStr = [request.URL absoluteString];
        
        for (NSString *whiteModule in self.serverModuleWhiteList) {
            if (whiteModule &&
                [whiteModule isKindOfClass:[NSString class]] &&
                [whiteModule stringByReplacingOccurrencesOfString:@" " withString:@""].length) {
                
                NSString *serverModule = [NSString stringWithFormat:@"/%@/", whiteModule];
                if ([urlStr containsString:serverModule]) {
                    goto nextStep_Req;
                }
            }
        }
        return;
    }
    
nextStep_Req:;
    objc_setAssociatedObject(notification.object, TDFAPILoggerTakeOffDate, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSMutableString *frmtString = @"".mutableCopy;
    TDFALRequestModel *requestDescriptionModel = [[TDFALRequestModel alloc] init];
    
    if (self.requestLoggerElements & TDFAPILoggerRequestElementTaskIdentifier) {
        NSString *taskIdentifier = TDFAPILoggerTaskIdentifierFromAFNNotification(notification);
        NSString *taskIdentifierDes = [NSString stringWithFormat:@"\n<API序列号> %@", taskIdentifier];
        [frmtString appendString:taskIdentifierDes];
        requestDescriptionModel.taskIdentifier = taskIdentifierDes;
    }
    
    NSURLSessionTask *task = (NSURLSessionTask *)notification.object;
    NSUInteger taskDescLength = [task.taskDescription stringByReplacingOccurrencesOfString:@" " withString:@""].length;
    if (self.defaultTaskDescriptionObj) {
        NSString *taskDescriptionSetByAFN = [NSString stringWithFormat:@"%p", self.defaultTaskDescriptionObj];
        if (taskDescLength && ![task.taskDescription isEqualToString:taskDescriptionSetByAFN]) {
            NSString *apiTaskDes = [NSString stringWithFormat:@"\n<API描述>    %@", task.taskDescription];
            [frmtString appendString:apiTaskDes];
            requestDescriptionModel.taskDescription = apiTaskDes;
        }
    } else {
        if (taskDescLength) {
            NSString *apiTaskDes = [NSString stringWithFormat:@"\n<API描述>    %@", task.taskDescription];
            [frmtString appendString:apiTaskDes];
            requestDescriptionModel.taskDescription = apiTaskDes;
        }
    }
    
    if (self.requestLoggerElements & TDFAPILoggerRequestElementTakeOffTime) {
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *timeStr = [df stringFromDate:objc_getAssociatedObject(notification.object, TDFAPILoggerTakeOffDate)];
        NSString *milestoneTimeDes = [NSString stringWithFormat:@"\n<起飞时间>  %@", timeStr];
        [frmtString appendString:milestoneTimeDes];
        requestDescriptionModel.milestoneTime = milestoneTimeDes;
    }
    
    if (self.requestLoggerElements & TDFAPILoggerRequestElementMethod) {
        NSString *methodDes = [NSString stringWithFormat:@"\n<请求方式>  %@", request.HTTPMethod];
        [frmtString appendString:methodDes];
        requestDescriptionModel.method = methodDes;
    }
    
    if (self.requestLoggerElements & TDFAPILoggerRequestElementVaildURL) {
        NSString *validURLDes = [NSString stringWithFormat:@"\n<请求地址>  %@", [request.URL absoluteString]];
        [frmtString appendString:validURLDes];
        requestDescriptionModel.validURL = validURLDes;
    }
    
    if (self.requestLoggerElements & TDFAPILoggerRequestElementHeaderFields) {
        NSDictionary *headerFields = request.allHTTPHeaderFields;
        NSMutableString *headerFieldFrmtStr = @"".mutableCopy;
        [headerFields enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [headerFieldFrmtStr appendFormat:@"\n\t\"%@\" = \"%@\"", key, obj];
        }];
        NSString *headerFieldsDes = [NSString stringWithFormat:@"\n<HeaderFields>%@", headerFieldFrmtStr];
        [frmtString appendString:headerFieldsDes];
        requestDescriptionModel.headerFields = headerFieldsDes;
    }
    
    if (self.requestLoggerElements & TDFAPILoggerRequestElementHTTPBody) {
        __block id httpBody = nil;
        
        if ([request HTTPBody]) {
            httpBody = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
        }
        // if a request does not set HTTPBody, so here it's need to check HTTPBodyStream
        else if ([request HTTPBodyStream]) {
            NSInputStream *httpBodyStream = request.HTTPBodyStream;
            
            __weak __typeof(self) w_self = self;
            TDFAPILoggerAsyncHttpBodyStreamParse(httpBodyStream, ^(NSData *streamData) {
                __strong __typeof(w_self) s_self = w_self;
                
                httpBody = streamData;
                NSString *httpBodyDes = [NSString stringWithFormat:@"\n<Body>\n\t%@", httpBody];
                [frmtString appendString:httpBodyDes];
                requestDescriptionModel.httpBody = httpBodyDes;
                
                NSString *logMsg = [frmtString copy];
                TDFAPILoggerShowRequest(logMsg);
                
                requestDescriptionModel.selfDescription = logMsg;
                
                !s_self.requestLogReporter ?: s_self.requestLogReporter(requestDescriptionModel);
            });
            return;
        }
        
        if ([httpBody isKindOfClass:[NSString class]] && [(NSString *)httpBody length]) {
            NSMutableString *httpBodyStr = @"".mutableCopy;
            
            NSArray *params = [httpBody componentsSeparatedByString:@"&"];
            [params enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *pair = [obj componentsSeparatedByString:@"="];
                
                NSString *key = nil;
                if ([pair.firstObject respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
                    key = [pair.firstObject stringByRemovingPercentEncoding];
                }else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    key = [pair.firstObject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
                }
                
                NSString *value = nil;
                if ([pair.lastObject respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
                    value = [pair.lastObject stringByRemovingPercentEncoding];
                }else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    value = [pair.lastObject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
                }
                value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
                
                [httpBodyStr appendFormat:@"\n\t\"%@\" = \"%@\"", key, value];
            }];
            
            NSString *httpBodyDes = [NSString stringWithFormat:@"\n<Body>%@", httpBodyStr];
            [frmtString appendString:httpBodyDes];
            requestDescriptionModel.httpBody = httpBodyDes;
        }
    }
    
    NSString *logMsg = [frmtString copy];
    TDFAPILoggerShowRequest(logMsg);
    
    requestDescriptionModel.selfDescription = logMsg;
    
    !self.requestLogReporter ?: self.requestLogReporter(requestDescriptionModel);
}

- (void)apiDidLand:(NSNotification *)notification {
    NSURLRequest *request = TDFAPILoggerRequestFromAFNNotification(notification);
    NSURLResponse *response = TDFAPILoggerResponseFromAFNNotification(notification);
    NSError *error = TDFAPILoggerErrorFromAFNNotification(notification);
    
    if (!request && !response && !(self.responseLoggerElements & 0x00) && (!self.loggerFilter || self.loggerFilter(request))) return;
    
    // In addition，check whiteList for shielding some needless api log..
    if (self.serverModuleWhiteList && self.serverModuleWhiteList.count) {
        NSString *urlStr = [request.URL absoluteString];
        
        for (NSString *whiteModule in self.serverModuleWhiteList) {
            if (whiteModule &&
                [whiteModule isKindOfClass:[NSString class]] &&
                [whiteModule stringByReplacingOccurrencesOfString:@" " withString:@""].length) {
                
                NSString *serverModule = [NSString stringWithFormat:@"/%@/", whiteModule];
                if ([urlStr containsString:serverModule]) {
                    goto nextStep_Resp;
                }
            }
        }
        return;
    }
    
nextStep_Resp:;
    NSInteger responseStatusCode = 0;
    NSDictionary *responseHeaderFields = nil;
    TDFALResponseModel *responseDescriptionModel = [[TDFALResponseModel alloc] init];
    
    // NSHTTPURLResponse inherit NSURLResponse，it has statusCode and allHeaderFields prop..
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        responseStatusCode = [(NSHTTPURLResponse *)response statusCode];
        responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
    }
    
    NSMutableString *frmtString = @"".mutableCopy;
    // avoid compile time deviation..
    NSDate *landDate = [NSDate date];
    
    if (self.responseLoggerElements & TDFAPILoggerResponseElementTaskIdentifier) {
        NSString *taskIdentifier = TDFAPILoggerTaskIdentifierFromAFNNotification(notification);
        NSString *taskIdentifierDes = [NSString stringWithFormat:@"\n<API序列号> %@", taskIdentifier];
        [frmtString appendString:taskIdentifierDes];
        responseDescriptionModel.taskIdentifier = taskIdentifierDes;
    }
    
    NSURLSessionTask *task = (NSURLSessionTask *)notification.object;
    NSUInteger taskDescLength = [task.taskDescription stringByReplacingOccurrencesOfString:@" " withString:@""].length;
    if (self.defaultTaskDescriptionObj) {
        NSString *taskDescriptionSetByAFN = [NSString stringWithFormat:@"%p", self.defaultTaskDescriptionObj];
        if (taskDescLength && ![task.taskDescription isEqualToString:taskDescriptionSetByAFN]) {
            NSString *apiTaskDes = [NSString stringWithFormat:@"\n<API描述>    %@", task.taskDescription];
            [frmtString appendString:apiTaskDes];
            responseDescriptionModel.taskDescription = apiTaskDes;
        }
    } else {
        if (taskDescLength) {
            NSString *apiTaskDes = [NSString stringWithFormat:@"\n<API描述>    %@", task.taskDescription];
            [frmtString appendString:apiTaskDes];
            responseDescriptionModel.taskDescription = apiTaskDes;
        }
    }
    
    if (self.responseLoggerElements & TDFAPILoggerResponseElementLandTime) {
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *timeStr = [df stringFromDate:landDate];
        NSString *milestoneTimeDes = [NSString stringWithFormat:@"\n<着陆时间>  %@", timeStr];
        [frmtString appendString:milestoneTimeDes];
        responseDescriptionModel.milestoneTime = milestoneTimeDes;
    }
    
    if (self.responseLoggerElements & TDFAPILoggerResponseElementTimeConsuming) {
        NSTimeInterval timeConsuming = [landDate timeIntervalSinceDate:objc_getAssociatedObject(notification.object, TDFAPILoggerTakeOffDate)];
        NSString *secondConsuming = [NSString stringWithFormat:@"%.3f秒", timeConsuming];
        NSString *timeConsumingDes = [NSString stringWithFormat:@"\n<请求耗时>  %@", secondConsuming];
        [frmtString appendString:timeConsumingDes];
        responseDescriptionModel.timeConsuming = timeConsumingDes;
    }
    
    if (self.responseLoggerElements & TDFAPILoggerResponseElementMethod) {
        NSString *methodDes = [NSString stringWithFormat:@"\n<请求方式>  %@", request.HTTPMethod];
        [frmtString appendString:methodDes];
        responseDescriptionModel.method = methodDes;
    }
    
    if (self.responseLoggerElements & TDFAPILoggerResponseElementStatusCode) {
        if (responseStatusCode) {
            NSString *statusCodeDes = [NSString stringWithFormat:@"\n<状态码>     %ld", responseStatusCode];
            [frmtString appendString:statusCodeDes];
            responseDescriptionModel.statusCode = statusCodeDes;
        }
    }
    
    if (self.responseLoggerElements & TDFAPILoggerResponseElementVaildURL) {
        NSString *validURLDes = [NSString stringWithFormat:@"\n<请求地址>  %@", [request.URL absoluteString]];
        [frmtString appendString:validURLDes];
        responseDescriptionModel.validURL = validURLDes;
    }
    
    if (self.responseLoggerElements & TDFAPILoggerResponseElementHeaderFields) {
        if (responseHeaderFields) {
            NSMutableString *headerFieldFrmtStr = @"".mutableCopy;
            [responseHeaderFields enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [headerFieldFrmtStr appendFormat:@"\n\t\"%@\" = \"%@\"", key, obj];
            }];
            NSString *headerFieldsDes = [NSString stringWithFormat:@"\n<HeaderFields>%@", headerFieldFrmtStr];
            [frmtString appendString:headerFieldsDes];
            responseDescriptionModel.headerFields = headerFieldsDes;
        }
    }
    
    if (self.responseLoggerElements & TDFAPILoggerResponseElementResponse) {
        if (error) {
            NSString *errorDes = [NSString stringWithFormat:@"\n<Error>\n\tErrorDomain = %@\n\tCode = %ld\n\tLocalizedDescription = %@", error.domain, error.code, error.localizedDescription];
            [frmtString appendString:errorDes];
            responseDescriptionModel.error = errorDes;
        } else {
            // JSON pretty print format, by async to improve performance..
            id serializedResponse = notification.userInfo[AFNetworkingTaskDidCompleteSerializedResponseKey];
            
            __weak __typeof(self) w_self = self;
            TDFAPILoggerAsyncJsonResponsePrettyFormat(serializedResponse, ^(id betterResponseString) {
                __strong __typeof(w_self) s_self = w_self;
                NSString *responseDes = [NSString stringWithFormat:@"\n<Response>\n%@", betterResponseString];
                [frmtString appendString:responseDes];
                responseDescriptionModel.response = responseDes;
                
                NSString *logMsg = [frmtString copy];
                TDFAPILoggerShowResponse(logMsg);
                
                responseDescriptionModel.selfDescription = logMsg;
                
                !s_self.responseLogReporter ?: s_self.responseLogReporter(responseDescriptionModel);
            });
            return;
        }
    }
    
    NSString *logMsg = [frmtString copy];
    
    if (error) {
        TDFAPILoggerShowError(logMsg);
    } else {
        TDFAPILoggerShowResponse(logMsg);
    }
    
    responseDescriptionModel.selfDescription = logMsg;
    
    !self.responseLogReporter ?: self.responseLogReporter(responseDescriptionModel);
}

@end
