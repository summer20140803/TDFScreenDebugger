//
//  TDFSDLVLogManager.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/5.
//

#import "TDFSDLVLogManager.h"
#import "TDFSDLVLogModel.h"
#import <asl.h>
#import <os/log.h>

@interface TDFSDLVLogManager ()

@property (nonatomic, strong, readwrite) NSArray<TDFSDLVLogModel *> *logs;
@property (nonatomic, strong) NSTimer *fetchTimer;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

static const CGFloat TDFSDLVSystemLogFetchInterval   =  1.0f;

@implementation TDFSDLVLogManager

#pragma mark - life cycle
+ (instancetype)manager {
    static TDFSDLVLogManager *manager = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _logs = @[];
        [self thaw];
    }
    return self;
}

- (void)dealloc {
    [self.fetchTimer invalidate];
    self.fetchTimer = nil;
}

#pragma mark - interface methods
- (void)clearCurrentSystemLogs {
    self.logs = @[];
}

- (void)thaw {
    self.fetchTimer = [NSTimer scheduledTimerWithTimeInterval:TDFSDLVSystemLogFetchInterval target:self selector:@selector(pollingFilteredSystemLogs) userInfo:nil repeats:YES];
    [self fetchExistSystemLogs];
}

- (void)freeze {
    [self.fetchTimer invalidate];
    self.fetchTimer = nil;
}

#pragma mark - private
- (void)fetchExistSystemLogs {
    [self fetchSystemLogsWithTimeThreshold:NSNotFound];
}

- (void)pollingFilteredSystemLogs {
    [self fetchSystemLogsWithTimeThreshold:TDFSDLVSystemLogFetchInterval];
}

- (void)fetchSystemLogsWithTimeThreshold:(NSTimeInterval)timeThreshold {
    
    NSDate *thresholdDate = [NSDate dateWithTimeIntervalSinceNow:-timeThreshold];
    
    // asl is replaced by os_log after ios 10.0, so we should judge system version
    // use os_log
    //        if (NSFoundationVersionNumber >= NSFoundationVersionNumber10_0) {
    //
    //        }
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 10.0f) {
        // https://stackoverflow.com/questions/40272910/read-logs-using-the-new-swift-os-log-api
    }
    // use asl
    else {
        asl_object_t query = asl_new(ASL_TYPE_QUERY);
        
        // filter for messages from the current process.
        // note that this appears to happen by default on device, but is required in the simulator.
        NSString *pidString = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
        asl_set_query(query, ASL_KEY_PID, [pidString UTF8String], ASL_QUERY_OP_EQUAL);
        
        aslresponse response = asl_search(NULL, query);
        aslmsg aslMessage = NULL;
        
        NSMutableArray *newLogs = [NSMutableArray array];
        while ((aslMessage = asl_next(response))) {
            
            @autoreleasepool {
                const char *timeInterval = asl_get(aslMessage, ASL_KEY_TIME);
                // filter logs which is not in the time threshold
                NSDate *aslMsgDate = [NSDate dateWithTimeIntervalSince1970:[@(timeInterval) doubleValue]];
                NSComparisonResult compareResult = [aslMsgDate compare:thresholdDate];
                if (compareResult == NSOrderedAscending) {
                    continue;
                }
                
                const char *messageId = asl_get(aslMessage, ASL_KEY_MSG_ID);
                const char *message = asl_get(aslMessage, ASL_KEY_MSG);
                
                TDFSDLVLogModel *log = [[TDFSDLVLogModel alloc] init];
                
                log.id = messageId ?
                @(messageId) :
                @"NO MSG ID";
                
                log.time = aslMsgDate ?
                [self.dateFormatter stringFromDate:aslMsgDate] :
                @"NO MSG TIME";
                
                log.message = message ?
                [[NSString alloc] initWithCString:message encoding:NSUTF8StringEncoding] :
                @"NO MSG TEXT";
                
                [newLogs addObject:log];
            }
        }
        
        NSMutableArray *currentLogs = [self.logs mutableCopy];
        [currentLogs addObjectsFromArray:newLogs];
        
        self.logs = [currentLogs copy];
        
        asl_release(response);
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
