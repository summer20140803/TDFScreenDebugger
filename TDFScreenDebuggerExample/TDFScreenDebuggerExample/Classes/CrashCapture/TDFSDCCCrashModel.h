//
//  TDFSDCCCrashModel.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/14.
//

#import <Foundation/Foundation.h>

@interface TDFSDCCCrashModel : NSObject

@property (nonatomic,   copy) NSString *exceptionType;
@property (nonatomic,   copy) NSString *exceptionTime;
@property (nonatomic,   copy) NSString *exceptionName;
@property (nonatomic,   copy) NSString *exceptionReason;
@property (nonatomic,   copy) NSString *exceptionCallStack;

@end
