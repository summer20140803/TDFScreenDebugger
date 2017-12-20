//
//  TDFSDCallStackFetcher.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/13.
//

#import <Foundation/Foundation.h>

@interface TDFSDCallStackFetcher : NSObject

+ (NSString *)sd_callStackOfAllThread;
+ (NSString *)sd_callStackOfCurrentThread;
+ (NSString *)sd_callStackOfMainThread;
+ (NSString *)sd_callStackOfNSThread:(NSThread *)thread;

@end
