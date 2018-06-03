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
#import "TDFSDFunctionModel.h"
#import "TDFSDPersistenceSetting.h"
#import "UIViewController+ScreenDebugger.h"
#import "TDFSDTransitionAnimator.h"

#import "TDFSDAPIRecordConsoleController.h"
#import "TDFSDAPIRecordSelectableController.h"
#import "TDFSDCrashCaptureHistoryController.h"
#import "TDFSDLogViewController.h"
#import "TDFSDFunctionPageController.h"
#import "TDFSDAboutFutureController.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import <objc/runtime.h>

@interface TDFSDManager () <TDFSDWindowDelegate, UIViewControllerTransitioningDelegate>

// this window is use for store app's origin window and we operate it in the future if need
@property (nonatomic, strong) UIWindow *originWindow;
@property (nonatomic, assign) BOOL sd_canBecomeKeyWindow;

@property (nonatomic, strong, readwrite) TDFSDWindow *screenDebuggerWindow;
@property (nonatomic, strong) TDFSDViewController *screenDebuggerController;

@end

@implementation TDFSDManager

const char *kGestureAssociatedToolTypeKey  =  "gestureAssociatedToolTypeKey";

#if DEBUG
SD_CONSTRUCTOR_METHOD_DECLARE \
(SD_CONSTRUCTOR_METHOD_PRIORITY_BUILD_BASE_CACHE_ROOT, {
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
    if (!self.sd_canBecomeKeyWindow) {
        [self applyForAcceptKeyInput];
    }
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

- (void)registerQuickLaunchGesture:(__kindof UIGestureRecognizer *)launchGesture forSubTool:(SDSubToolType)subTool {
    NSParameterAssert(launchGesture);
    
    NSString *gestureDes = [self gestureDescriptionWithGesture:launchGesture];
    TDFSDFunctionModel *funcModel = [[TDFSDPersistenceSetting sharedInstance].functionList objectAtIndex:subTool];
    funcModel.quickLaunchDescrition = gestureDes;
    
    NSNumber *subToolType = @(subTool);
    objc_setAssociatedObject(launchGesture, kGestureAssociatedToolTypeKey, subToolType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [launchGesture addTarget:self action:@selector(gestureToQuickLaunchFunctionPage:)];
}

- (void)gestureToQuickLaunchFunctionPage:(__kindof UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    
    SDSubToolType toolType = [objc_getAssociatedObject(gesture, kGestureAssociatedToolTypeKey) unsignedIntegerValue];
    
    UIViewController *dest = nil;
    switch (toolType) {
        case SDSubToolTypeDisperseAPIRecord: {
            dest = [[TDFSDAPIRecordConsoleController alloc] init];
        } break;
        case SDSubToolTypeBindingAPIRecord: {
            dest = [[TDFSDAPIRecordSelectableController alloc] init];
        } break;
        case SDSubToolTypeSystemLogView: {
            dest = [[TDFSDLogViewController alloc] init];
        } break;
        case SDSubToolTypeCrashCaptor: {
            dest = [[TDFSDCrashCaptureHistoryController alloc] init];
        } break;
        case SDSubToolTypePerformanceMonitor:
        case SDSubToolTypeMemoryLeakDetector:
        case SDSubToolTypeWildPointerChecker: {
            dest = [[TDFSDFunctionPageController alloc] init];
            TDFSDFunctionModel *funcModel = [[TDFSDPersistenceSetting sharedInstance].functionList objectAtIndex:toolType];
            [(TDFSDFunctionPageController *)dest setFunctionModel:funcModel];
        } break;
        case SDSubToolTypeRetainCycleMonitor: {
            dest = [[TDFSDAboutFutureController alloc] init];
        } break;
    }
    
    if (dest) {
        dest.transitioningDelegate = self;
        UIWindow *effectiveWindow = currentEffectiveWindow();
        [[effectiveWindow.rootViewController sd_obtainTopViewController] presentViewController:dest animated:YES completion:nil];
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

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [TDFSDTransitionAnimator new];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [TDFSDTransitionAnimator new];
}

#pragma mark - private
- (NSString *)gestureDescriptionWithGesture:(__kindof UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
        return SD_STRING(@"👆🏻 tap gesture to quick launch");
    } else if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]]) {
        return SD_STRING(@"👆🏻 swipe gesture to quick launch");
    } else if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return SD_STRING(@"👆🏻 long press gesture to quick launch");
    } else if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        return SD_STRING(@"👆🏻 pan gesture to quick launch");
    } else if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
        return SD_STRING(@"👆🏻 pinch gesture to quick launch");
    } else if ([gesture isKindOfClass:[UIRotationGestureRecognizer class]]) {
        return SD_STRING(@"👆🏻 rotation gesture to quick launch");
    } else if ([gesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return SD_STRING(@"👆🏻 screen-edge pan gesture to quick launch");
    } else {
        return SD_STRING(@"👆🏻 custom gesture to quick launch");
    }
}

static UIWindow *currentEffectiveWindow() {
    // find out the toppest and useable window
    NSArray<UIWindow *> *windows = [[UIApplication sharedApplication] windows];
    UIWindow *effectiveWindow = [[[[windows.rac_sequence
                                    filter:^BOOL(id  _Nullable value) {
                                        return ![(UIWindow *)value isHidden] && [(UIWindow *)value alpha] != 0;
                                    }]
                                   array]
                                  sortedArrayUsingComparator:^NSComparisonResult(UIWindow * _Nonnull obj1, UIWindow * _Nonnull obj2) {
                                      if (obj1.windowLevel > obj2.windowLevel) {
                                          return NSOrderedAscending;
                                      } else {
                                          return NSOrderedDescending;
                                      }
                                  }]
                                 firstObject];
    return effectiveWindow;
}

@end
