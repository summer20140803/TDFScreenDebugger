//
//  TDFSDManager.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/12.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDManager.h"
#import "TDFSDViewController.h"
#import "TDFScreenDebuggerDefine.h"

@interface TDFSDManager () <TDFSDWindowDelegate>

// this window is use for store app's origin window and we operate it in the future if need
@property (nonatomic, strong) UIWindow *originWindow;
@property (nonatomic, assign) BOOL sd_canBecomeKeyWindow;

@property (nonatomic, strong, readwrite) TDFSDWindow *screenDebuggerWindow;
@property (nonatomic, strong) TDFSDViewController *screenDebuggerController;

@end

@implementation TDFSDManager

#if DEBUG
SD_CONSTRUCTOR_METHOD_DECLARE \
(SD_CONSTRUCTOR_METHOD_PRIORITY_BUILD_CACHE_ROOT, {
    // build exclusive cache folder in sandbox
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *systemDicPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sdkLocalCacheFolderPath = [systemDicPath stringByAppendingPathComponent:SD_LOCAL_CACHE_ROOT_FILE_FOLDER_NAME];
    BOOL isDictonary;
    if ([fileManager fileExistsAtPath:sdkLocalCacheFolderPath isDirectory:&isDictonary] && !isDictonary) {
        [fileManager removeItemAtPath:sdkLocalCacheFolderPath error:nil];
    }
    if (![fileManager fileExistsAtPath:sdkLocalCacheFolderPath]) {
        [fileManager createDirectoryAtPath:sdkLocalCacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
})
#endif

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

        self.sd_canBecomeKeyWindow = NO;
        
        // open system setting to support shake events
        [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    }
    return self;
}

#pragma mark - interface methods
- (void)showDebugger {
    self.screenDebuggerWindow.hidden = NO;
}

- (void)hideDebugger {
    if (self.sd_canBecomeKeyWindow) {
        [self revokeApply];
    }
    self.screenDebuggerWindow.hidden = YES;
}

- (void)applyForAcceptKeyInput {
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (keyWindow != self.screenDebuggerWindow) {
        
        self.originWindow = keyWindow;
        [keyWindow resignFirstResponder];
        
        self.sd_canBecomeKeyWindow = YES;
        [self.screenDebuggerWindow makeKeyWindow];
    }
}

- (void)revokeApply {
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (keyWindow == self.screenDebuggerWindow) {
        
        [keyWindow resignFirstResponder];
        
        self.sd_canBecomeKeyWindow = NO;
        [self.originWindow makeKeyWindow];
    }
}

#pragma mark - getter
- (TDFSDWindow *)screenDebuggerWindow {
    if (!_screenDebuggerWindow) {
        _screenDebuggerWindow = [[TDFSDWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _screenDebuggerWindow.sd_delegate = self;
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

- (BOOL)canBecomeKeyWindow:(TDFSDWindow *)window {
    return self.sd_canBecomeKeyWindow;
}

@end
