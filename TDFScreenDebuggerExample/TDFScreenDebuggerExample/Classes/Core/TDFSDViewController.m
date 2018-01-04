//
//  TDFSDViewController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/12.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDViewController.h"
#import "TDFSDThumbnailView.h"
#import "TDFSDPMFloatBrowser.h"
#import "TDFSDPerformanceMonitorLagListController.h"
#import "TDFSDDebuggerCenterController.h"
#import "TDFSDOverallSettingController.h"
#import "TDFSDTransitionAnimator.h"
#import "TDFSDPersistenceSetting.h"
#import "UIView+ScreenDebugger.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) TDFSDThumbnailView *thumbnailView;
@property (nonatomic, strong) TDFSDPMFloatBrowser *floatBrowser;

@end

@implementation TDFSDViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutPageSubviews];
}

#pragma mark - interface
- (BOOL)shouldHandleTouchWithTouchPoint:(CGPoint)touchPoint {
    // if the console or setting is presented, just return YES
    if (self.presentedViewController) {
        return YES;
    }
    if ((!self.thumbnailView.hidden && CGRectContainsPoint(self.thumbnailView.frame, touchPoint)) ||
        (!self.floatBrowser.hidden && CGRectContainsPoint(self.floatBrowser.frame, touchPoint))) {
        return YES;
    }
    return NO;
}

#pragma mark - getter
- (TDFSDThumbnailView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [[TDFSDThumbnailView alloc] initWithFrame:CGRectZero];
        _thumbnailView.tapProxy = [RACSubject subject];
        _thumbnailView.longPressProxy = [RACSubject subject];
        @weakify(self)
        [_thumbnailView.tapProxy subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            if (!self.presentedViewController) {
                TDFSDDebuggerCenterController *center = [[TDFSDDebuggerCenterController alloc] init];
                center.transitioningDelegate = self;
                [self presentViewController:center animated:YES completion:nil];
            }
        }];
        [_thumbnailView.longPressProxy subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            [self openRealTimePerformanceMonitoring:YES];
        }];
    }
    return _thumbnailView;
}

- (TDFSDPMFloatBrowser *)floatBrowser {
    if (!_floatBrowser) {
        _floatBrowser = [[TDFSDPMFloatBrowser alloc] init];
        _floatBrowser.tapProxy = [RACSubject subject];
        _floatBrowser.longPressProxy = [RACSubject subject];
        @weakify(self)
        [_floatBrowser.tapProxy subscribeNext:^(NSNumber * _Nullable tapZoneType) {
            @strongify(self)
            switch (tapZoneType.unsignedIntegerValue) {
                case SDPMTapZoneTypeCPU:{
                    if (![TDFSDPersistenceSetting sharedInstance].allowApplicationCPUMonitoring) {
                        [self goToOverallSettingPage];
                    }
                } break;
                case SDPMTapZoneTypeMemory:{
                    if (![TDFSDPersistenceSetting sharedInstance].allowApplicationMemoryMonitoring) {
                        [self goToOverallSettingPage];
                    }
                } break;
                case SDPMTapZoneTypeFPS:{
                    if (![TDFSDPersistenceSetting sharedInstance].allowScreenFPSMonitoring) {
                        [self goToOverallSettingPage];
                    }
                } break;
                case SDPMTapZoneTypeLag:{
                    if (![TDFSDPersistenceSetting sharedInstance].allowUILagsMonitoring) {
                        [self goToOverallSettingPage];
                    } else {
                        TDFSDPerformanceMonitorLagListController *dest = [[TDFSDPerformanceMonitorLagListController alloc] init];
                        dest.transitioningDelegate = self;
                        [self presentViewController:dest animated:YES completion:nil];
                    }
                } break;
                case SDPMTapZoneTypeCenter:{
                    TDFSDDebuggerCenterController *dest = [[TDFSDDebuggerCenterController alloc] init];
                    dest.transitioningDelegate = self;
                    [self presentViewController:dest animated:YES completion:nil];
                } break;
            }
        }];
        [_floatBrowser.longPressProxy subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            [self openRealTimePerformanceMonitoring:NO];
        }];
        _floatBrowser.hidden = YES;
    }
    return _floatBrowser;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [TDFSDTransitionAnimator new];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [TDFSDTransitionAnimator new];
}

#pragma mark - private
- (void)layoutPageSubviews {
    [self.view addSubview:self.floatBrowser];
    [self.view addSubview:self.thumbnailView];
    
    [self.floatBrowser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset([UIScreen mainScreen].bounds.size.height-60);
        make.left.equalTo(self.view).with.offset([UIScreen mainScreen].bounds.size.width-60);
        make.width.equalTo(@160);
        make.height.equalTo(@110);
    }];
    [self.thumbnailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset([UIScreen mainScreen].bounds.size.height-60);
        make.left.equalTo(self.view).with.offset([UIScreen mainScreen].bounds.size.width-60);
        make.width.and.height.equalTo(@40);
    }];
}

- (void)goToOverallSettingPage {
    TDFSDOverallSettingController *setting = [[TDFSDOverallSettingController alloc] init];
    setting.transitioningDelegate = self;
    [self presentViewController:setting animated:YES completion:nil];
}

- (void)openRealTimePerformanceMonitoring:(BOOL)needOpen {
    self.thumbnailView.hidden = needOpen;
    self.floatBrowser.hidden = !needOpen;
    [self.thumbnailView sd_fadeAnimationWithDuration:0.1];
    [self.floatBrowser sd_fadeAnimationWithDuration:0.1];
    
    if (needOpen) {
        CGPoint offset = self.thumbnailView.frame.origin;
        [self.floatBrowser mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).with.offset(offset.x - 60);
            make.top.equalTo(self.view).with.offset(offset.y - 35);
        }];
        [self.floatBrowser.superview layoutIfNeeded];
    } else {
        CGPoint offset = self.floatBrowser.frame.origin;
        [self.thumbnailView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).with.offset(offset.x + 60);
            make.top.equalTo(self.view).with.offset(offset.y + 35);
        }];
        [self.thumbnailView.superview layoutIfNeeded];
    }
}

@end
