//
//  TDFSDViewController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/12.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDViewController.h"
#import "TDFSDThumbnailView.h"
#import "TDFSDAPIRecordConsoleController.h"
#import "TDFSDDebuggerCenterController.h"
#import "TDFSDTransitionAnimator.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) TDFSDThumbnailView *thumbnailView;

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
    if (CGRectContainsPoint(self.thumbnailView.frame, touchPoint)) {
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
            TDFSDAPIRecordConsoleController *console = [[TDFSDAPIRecordConsoleController alloc] init];
            console.transitioningDelegate = self;
            [self presentViewController:console animated:YES completion:nil];
        }];
        [_thumbnailView.longPressProxy subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            if (!self.presentedViewController) {
                TDFSDDebuggerCenterController *center = [[TDFSDDebuggerCenterController alloc] init];
                center.transitioningDelegate = self;
                [self presentViewController:center animated:YES completion:nil];
            }
        }];
    }
    return _thumbnailView;
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
    [self.view addSubview:self.thumbnailView];
    [self.thumbnailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset([UIScreen mainScreen].bounds.size.height-60);
        make.left.equalTo(self.view).with.offset([UIScreen mainScreen].bounds.size.width-60);
        make.width.and.height.equalTo(@40);
    }];
}

@end
