//
//  TDFSDManager.h
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/12.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDFSDManager : NSObject

@property (nonatomic, assign, readonly) BOOL debuggerHidden;

+ (instancetype)manager;

- (void)showDebugger;
- (void)hideDebugger;

@end
