//
//  TDFSDManager.h
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/12.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDFSDWindow.h"

typedef NS_ENUM(NSUInteger, SDSubToolType) {
    SDSubToolTypeDisperseAPIRecord        =   0,
    SDSubToolTypeBindingAPIRecord         =   1,
    SDSubToolTypeSystemLogView            =   2,
    SDSubToolTypePerformanceMonitor       =   3,
    SDSubToolTypeCrashCaptor              =   4,
    SDSubToolTypeMemoryLeakDetector       =   5,
    SDSubToolTypeWildPointerChecker       =   6,
    SDSubToolTypeRetainCycleMonitor       =   7,
};

@interface TDFSDManager : NSObject

@property (nonatomic, strong, readonly) TDFSDWindow *screenDebuggerWindow;
@property (nonatomic, assign) BOOL  disableForShakingLaunch;

+ (instancetype)manager;
- (void)applyForAcceptKeyInput;
- (void)revokeApply;

// can be called outside
- (void)showDebugger;
- (void)hideDebugger;
- (void)registerQuickLaunchGesture:(__kindof UIGestureRecognizer *)launchGesture forSubTool:(SDSubToolType)subTool;

@end
