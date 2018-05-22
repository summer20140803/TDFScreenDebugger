//
//  TDFSDMLDGeneralizedProtocol.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/16.
//

#import <Foundation/Foundation.h>

CF_EXPORT const  NSString * SDMLDMemoryLeakDetectionDidStartNotificationName;
CF_EXPORT const  NSString * SDMLDMemoryLeakDetectionDidFindSuspiciousLeakerNotificationName;

@protocol TDFSDMLDGeneralizedProtocol <NSObject>

@required
+ (void)prepareForDetection;
- (void)bindWithProxy;
- (BOOL)isSuspiciousLeaker;

@end
