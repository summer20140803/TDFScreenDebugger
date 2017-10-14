//
//  TDFSDPersistenceSetting.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/17.
//
//

#import <Foundation/Foundation.h>
@class TDFSDFunctionModel;

typedef NS_ENUM(NSUInteger, SDMessageRemindType) {
    SDMessageRemindTypeAPIRecord   = 0,
    SDMessageRemindTypeSystemLog   = 1,
};

@interface TDFSDPersistenceSetting : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) NSArray<TDFSDFunctionModel *> *functionList;


//==========================
//  OPTIONAL SETTING ITEMS
//==========================

/**
 a setting which decides the type of the remind number. default is SDMessageRemindTypeAPIRecord
 */
@property (nonatomic, assign) SDMessageRemindType messageRemindType;

/**
 a flag to tell the log viewer Whether should catch API records. default is YES
 */
@property (nonatomic, assign) BOOL allowCatchAPIRecordFlag;

/**
 a flag to tell the log viewer Whether should monitor system logs. default is YES
 */
@property (nonatomic, assign) BOOL allowMonitorSystemLogFlag;

/**
 a flag to tell the crash captor Whether should capture crash. default is YES
 */
@property (nonatomic, assign) BOOL allowCrashCaptureFlag;

/**
 a flag to tell the crash captor Whether need cache crash-log to local file,
 cached file can be look over again in history-list. default is YES
 */
@property (nonatomic, assign) BOOL needCacheCrashLogToSandBox;

/**
 when log viewr receives a system log message data, we create buffer according to given max-size,
 if over, will cut out the data to given max-size. default is 1024 * 10, just be avaliable for iOS 10.0+
 */
@property (nonatomic, assign) ssize_t limitSizeOfSingleSystemLogMessageData  NS_CLASS_AVAILABLE_IOS(10_0);

@end
