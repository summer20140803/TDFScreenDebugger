//
//  TDFScreenDebuggerDefine.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/28.
//
//

#ifndef TDFScreenDebuggerDefine_h
#define TDFScreenDebuggerDefine_h


//========================
//  SDK LOCAL CACHE FILE
//========================
#define SD_LOCAL_CACHE_ROOT_FILE_FOLDER_NAME      @"screen_debugger_local_cache"

#define SD_CRASH_CAPTOR_CACHE_FILE_FOLDER_NAME    @"crash_captor"
#define SD_CRASH_CAPTOR_CACHE_EXPORT_FILE_PATH  \
({  \
    NSDateFormatter *df = [[NSDateFormatter alloc] init];  \
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];  \
    NSString *timeStr = [df stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];  \
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];  \
    NSString *rootFolderPath = [documentPath stringByAppendingPathComponent:SD_LOCAL_CACHE_ROOT_FILE_FOLDER_NAME];  \
    NSString *crashCacheFolderPath = [rootFolderPath stringByAppendingPathComponent:SD_CRASH_CAPTOR_CACHE_FILE_FOLDER_NAME];  \
    NSString *crashLogCachePath = [crashCacheFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.log", timeStr]];  \
    crashLogCachePath;  \
})
#define SD_CRASH_CAPTOR_CACHE_MODEL_ARCHIVE_PATH  \
({  \
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];  \
    NSString *rootFolderPath = [documentPath stringByAppendingPathComponent:SD_LOCAL_CACHE_ROOT_FILE_FOLDER_NAME];  \
    NSString *crashCacheFolderPath = [rootFolderPath stringByAppendingPathComponent:SD_CRASH_CAPTOR_CACHE_FILE_FOLDER_NAME];  \
    NSString *crashModelsCachePath = [crashCacheFolderPath stringByAppendingPathComponent:@"crashModels.archive"];  \
    crashModelsCachePath;  \
})


//========================
//   CONSTRUCTOR METHOD
//========================
#define SD_CONSTRUCTOR_METHOD_PRIORITY_CRASH_CAPTURE     4294967295    //(2^32-1 in 32bit)
#define SD_CONSTRUCTOR_METHOD_PRIORITY_LOG_VIEW          101
#define SD_CONSTRUCTOR_METHOD_PRIORITY_API_RECORD        102

#define SD_CONSTRUCTOR_METHOD_PRIORITY_BUILD_CACHE_ROOT   200
#define SD_CONSTRUCTOR_METHOD_PRIORITY_BUILD_CACHE_CRASH  201

#define SD_CONSTRUCTOR_METHOD_DECLARE(PRIORITY, ...)  \
__attribute__((constructor(PRIORITY)))  \
static void sd_contructor_method##PRIORITY (void) {  \
    static dispatch_once_t onceToken;  \
    dispatch_once(&onceToken, ^{  \
        __VA_ARGS__  \
    });  \
}

//============================
//   REMIND MESSAGE DEFINES
//============================
typedef NS_ENUM(NSUInteger, SDAllReadNotificationContentType) {
    SDAllReadNotificationContentTypeAPIRecord   =  0,
    SDAllReadNotificationContentTypeSystemLog   =  1,
};

#define SD_REMIND_MESSAGE_ALL_READ_NOTIFICATION_NAME  @"sd_remind_message_all_read_notification_name"

//==========================
//   CRASH EXCEPTION TYPE
//==========================
#define SD_CRASH_EXCEPTION_TYPE_SIGNAL   @"mach_signal_exception"
#define SD_CRASH_EXCEPTION_TYPE_OC       @"oc_exception"


#endif /* TDFScreenDebuggerDefine_h */
