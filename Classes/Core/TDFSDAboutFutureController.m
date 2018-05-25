//
//  TDFSDAboutFutureController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2018/3/26.
//  Copyright © 2018年 TDF. All rights reserved.
//

#import "TDFSDAboutFutureController.h"
#import "TDFSDTextView.h"
#import "TDFScreenDebuggerDefine.h"
#import "UIView+ScreenDebugger.h"
#import <Masonry/Masonry.h>

@interface TDFSDAboutFutureController () <TDFSDFullScreenConsoleControllerInheritProtocol>

@property (nonatomic, strong) TDFSDTextView *tipView;

@end

@implementation TDFSDAboutFutureController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    SD_DELAY_HANDLER(0.50f, {
        [self.tipView sd_fadeAnimationWithDuration:0.20f];
        self.tipView.text = @"\n\nStay tuned ...";
    })
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"Feature In Future";
}

- (__kindof UIView *)contentViewForFullScreenConsole {
    return self.tipView;
}

#pragma mark - getter
- (TDFSDTextView *)tipView {
    if (!_tipView) {
        _tipView = [[TDFSDTextView alloc] init];
        _tipView.textColor = [UIColor whiteColor];
        _tipView.textAlignment = NSTextAlignmentCenter;
        _tipView.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:36];
        _tipView.showsVerticalScrollIndicator = NO;
    }
    return _tipView;
}

@end
