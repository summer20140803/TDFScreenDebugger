//
//  TDFSDLogViewer.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/5.
//

#import "TDFSDLogViewer.h"
#import "TDFSDLVLogModel.h"
#import "TDFSDPersistenceSetting.h"
#import "TDFScreenDebuggerDefine.h"
#import <UIKit/UIKit.h>
#import <asl.h>
#import <notify.h>
#import <notify_keys.h>

@interface TDFSDLogViewer ()

@property (nonatomic, strong, readwrite) NSArray<TDFSDLVLogModel *> *logs;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
// typedef NSObject<OS_dispatch_source> *dispatch_source_t;
@property (nonatomic, strong) dispatch_source_t source_t;
@property (nonatomic, assign) int  notifyToken;

@end

@implementation TDFSDLogViewer

#pragma mark - life cycle

#if DEBUG
SD_CONSTRUCTOR_METHOD_DECLARE \
    (SD_CONSTRUCTOR_METHOD_PRIORITY_LOG_VIEW, {
        if ([[TDFSDPersistenceSetting sharedInstance] allowMonitorSystemLogFlag]) {
            [[TDFSDLogViewer sharedInstance] thaw];
        }
    })
#endif

static TDFSDLogViewer *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!sharedInstance) {
        sharedInstance = [super allocWithZone:zone];
    }
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _logs = @[];
    }
    return self;
}

- (void)dealloc {
    [self freeze];
}

#pragma mark - interface methods
- (void)clearCurrentSystemLogs {
    self.logs = @[];
}

#pragma mark - TDFSDFunctionIOControlProtocol
- (void)thaw {
    [self setPortToMonitorAppleLogs];
}

- (void)freeze {
    if (self.source_t) {
        dispatch_cancel(self.source_t);
    }
    if (self.notifyToken) {
        self.notifyToken = 0;
        notify_cancel(self.notifyToken);
    }
}

#pragma mark - private
- (void)setPortToMonitorAppleLogs {
    // asl is replaced by os_log after ios 10.0, so we should judge system version
    if (@available(iOS 10_0, *)) {
        // https://stackoverflow.com/questions/40272910/read-logs-using-the-new-swift-os-log-api
        // in a word, os_log can not let us query system logs like asl
        // for the above reason, we decide to use GCD to put log stream into pipe and then monitor them
        if (self.source_t) {
            dispatch_cancel(self.source_t);
        }
        
        int fd = STDERR_FILENO;
        int origianlFD = fd;
        int originalStdHandle = dup(fd); // save the original for reset
        
        int fildes[2];
        pipe(fildes);  // [0] is read end of pipe while [1] is write end
        dup2(fildes[1], fd);  // duplicate write end of pipe "onto" fd (this closes fd)
        close(fildes[1]);  // close original write end of pipe
        fd = fildes[0];  // we can now monitor the read end of the pipe
        
        NSMutableData* receivedData = [[NSMutableData alloc] init];
        fcntl(fd, F_SETFL, O_NONBLOCK);// set the reading of this file descriptor without delay
        
        dispatch_queue_t highPriorityGlobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_source_t source_t = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, highPriorityGlobalQueue);
        
        int writeEnd = fildes[1];
        dispatch_source_set_cancel_handler(source_t, ^{
            close(writeEnd);
            // reset the original file descriptor
            dup2(originalStdHandle, origianlFD);
        });
        
        dispatch_source_set_event_handler(source_t, ^{
            @autoreleasepool {
                char buffer[[[TDFSDPersistenceSetting sharedInstance] limitSizeOfSingleSystemLogMessageData]];
                ssize_t size = read(fd, (void*)buffer, (size_t)(sizeof(buffer)));
                
                [receivedData setLength:0];
                [receivedData appendBytes:buffer length:size];
            
                NSString *logMessage = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
                if (logMessage) {
                    TDFSDLVLogModel *log = [[TDFSDLVLogModel alloc] init];
                    log.id = @"NO MSG ID";
                    log.message = logMessage;
                    log.time = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
                    
                    // logs prop is observed outside, for safety, we should update logs prop context in main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *currentLogs = [self.logs mutableCopy];
                        [currentLogs addObject:log];
                        self.logs = currentLogs;
                    });
                    
                    // print on STDOUT_FILENO，so that the log can still print on xcode console
                    printf("\n%s\n",[logMessage UTF8String]);
                }
            }
        });
        
        dispatch_resume(source_t);
        
        self.source_t = source_t;
    }
    // use asl
    else {
        if (self.notifyToken) return;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // inspired by lumberjack
            __block unsigned long long lastSeenID  =  0;
            
            int notifyToken = 0;
            dispatch_queue_t highPriorityGlobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            notify_register_dispatch(kNotifyASLDBUpdate, &notifyToken, highPriorityGlobalQueue, ^(int token) {
                
                self.notifyToken = token;
                
                @autoreleasepool {
                    asl_object_t query = asl_new(ASL_TYPE_QUERY);
                    
                    // filter for messages from the current process
                    // note that this appears to happen by default on device, but is required in the simulator
                    NSString *pidString = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
                    asl_set_query(query, ASL_KEY_PID, [pidString UTF8String], ASL_QUERY_OP_EQUAL | ASL_QUERY_OP_NUMERIC);
                    
                    // filter for messages from new asl message id
                    char queryContext[64];
                    snprintf(queryContext, sizeof queryContext, "%llu", lastSeenID);
                    asl_set_query(query, ASL_KEY_MSG_ID, queryContext, ASL_QUERY_OP_GREATER | ASL_QUERY_OP_NUMERIC);
                    
                    aslresponse response = asl_search(NULL, query);
                    aslmsg aslMessage = NULL;
                    
                    NSMutableArray *newLogs = [NSMutableArray array];
                    
                    while ((aslMessage = asl_next(response))) {
                        
                        const char *timeInterval = asl_get(aslMessage, ASL_KEY_TIME);
                        const char *messageId = asl_get(aslMessage, ASL_KEY_MSG_ID);
                        const char *message = asl_get(aslMessage, ASL_KEY_MSG);
                        
                        TDFSDLVLogModel *log = [[TDFSDLVLogModel alloc] init];
                        
                        log.id = messageId ?
                        @(messageId) :
                        @"NO MSG ID";
                        
                        NSDate *aslMsgDate = [NSDate dateWithTimeIntervalSince1970:[@(timeInterval) doubleValue]];
                        log.time = aslMsgDate ?
                        [self.dateFormatter stringFromDate:aslMsgDate] :
                        @"NO MSG TIME";
                        
                        log.message = message ?
                        [[NSString alloc] initWithCString:message encoding:NSUTF8StringEncoding] :
                        @"NO MSG TEXT";
                        
                        [newLogs addObject:log];
                        
                        if (messageId) {
                            // keep trace of which messages we've seen
                            lastSeenID = atoll(asl_get(aslMessage, ASL_KEY_MSG_ID));
                        }
                    }
                    
                    // logs prop is observed outside, for safety, we should update logs prop context in main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *currentLogs = [self.logs mutableCopy];
                        [currentLogs addObjectsFromArray:newLogs];
                        self.logs = [currentLogs copy];
                    });
                    
                    asl_release(response);
                    asl_free(query);
                }
            });
        });
    }
}
    

#pragma mark - getter
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSS";
    }
    return _dateFormatter;
}

@end
