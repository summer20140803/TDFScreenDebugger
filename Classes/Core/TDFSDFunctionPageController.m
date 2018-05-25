//
//  TDFSDFunctionPageController.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/22.
//

#import "TDFSDFunctionPageController.h"
#import "TDFSDTextView.h"
#import "TDFScreenDebuggerDefine.h"
#import "UIView+ScreenDebugger.h"
#import "TDFSDOverallSettingController.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDFunctionPageController () <TDFSDFullScreenConsoleControllerInheritProtocol>

@property (nonatomic, strong) TDFSDTextView *textView;
@property (nonatomic, strong) UIButton *goSettingButton;

@end

@implementation TDFSDFunctionPageController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self)
    [RACObserve(self.textView, attributedText) subscribeNext:^(NSString *  _Nullable newValue) {
        @strongify(self)
        if (newValue.length) {
            CGSize contentSize = self.textView.contentSize;
            if (!self.goSettingButton.superview) {
                [self.textView addSubview:self.goSettingButton];
                [self.goSettingButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@(contentSize.height+60));
                    make.centerX.equalTo(self.textView);
                    make.height.equalTo(@44);
                    make.left.equalTo(self.textView).with.offset(11);
                }];
                self.textView.contentSize = CGSizeMake(contentSize.width, contentSize.height+114);
            }
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    SD_DELAY_HANDLER(0.50f, {
        [self.textView sd_fadeAnimationWithDuration:0.20f];
        self.textView.attributedText = self.pageContent;
    })
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return self.pageTitle ?: @"";
}

- (__kindof UIView *)contentViewForFullScreenConsole {
    return self.textView;
}

#pragma mark - getter
- (TDFSDTextView *)textView {
    if (!_textView) {
        _textView = [[TDFSDTextView alloc] init];
        _textView.showsVerticalScrollIndicator = NO;
    }
    return _textView;
}

- (UIButton *)goSettingButton {
    if (!_goSettingButton) {
        _goSettingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_goSettingButton setBackgroundColor:[UIColor colorWithRed:85/255.f green:196/255.f blue:245/255.f alpha:1]];
        _goSettingButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _goSettingButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:20];
        [_goSettingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_goSettingButton setTitle:@"Go Setting" forState:UIControlStateNormal];
        [_goSettingButton addTarget:self action:@selector(goToSettingPage) forControlEvents:UIControlEventTouchUpInside];
        _goSettingButton.layer.cornerRadius = 6.0f;
        _goSettingButton.layer.masksToBounds = YES;
    }
    return _goSettingButton;
}

#pragma mark - private
- (void)goToSettingPage {
    TDFSDOverallSettingController *settingPage = [[TDFSDOverallSettingController alloc] init];
    settingPage.transitioningDelegate = self;
    [self presentViewController:settingPage animated:YES completion:nil];
}

@end
