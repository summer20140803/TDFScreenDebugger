//
//  TDFSDManager.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/12.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDManager.h"
#import "TDFSDWindow.h"
#import "TDFSDViewController.h"

@interface TDFSDManager () <TDFSDWindowDelegate>

@property (nonatomic, assign, readwrite) BOOL debuggerHidden;
@property (nonatomic, strong) TDFSDWindow *screenDebuggerWindow;
@property (nonatomic, strong) TDFSDViewController *screenDebuggerController;

@end

@implementation TDFSDManager

+ (instancetype)manager {
    static TDFSDManager *manager = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.debuggerHidden = YES;
        // open system setting to support shake events
        [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    }
    return self;
}

- (void)showDebugger {
    self.screenDebuggerWindow.hidden = NO;
    self.debuggerHidden = NO;
}

- (void)hideDebugger {
    self.screenDebuggerWindow.hidden = YES;
    self.debuggerHidden = YES;
}

#pragma mark - getter
- (TDFSDWindow *)screenDebuggerWindow {
    if (!_screenDebuggerWindow) {
        _screenDebuggerWindow = [[TDFSDWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _screenDebuggerWindow.touchEventDelegate = self;
        _screenDebuggerWindow.rootViewController = self.screenDebuggerController;
    }
    return _screenDebuggerWindow;
}

- (TDFSDViewController *)screenDebuggerController {
    if (!_screenDebuggerController) {
        _screenDebuggerController = [[TDFSDViewController alloc] init];
    }
    return _screenDebuggerController;
}

#pragma mark - TDFSDWindowDelegate
- (BOOL)window:(TDFSDWindow *)window shouldHandleTouchEventWithTouchPoint:(CGPoint)touchPoint {
    // deliver to controller and let it do check logic
    return [self.screenDebuggerController shouldHandleTouchWithTouchPoint:touchPoint];
}

@end
