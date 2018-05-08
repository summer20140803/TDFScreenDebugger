//
//  TDFSDCrashCaptureDetailController.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/7.
//

#import "TDFSDCrashCaptureDetailController.h"
#import "TDFSDTextView.h"
#import "TDFSDCCCrashModel.h"
#import "TDFScreenDebuggerDefine.h"
#import "UIView+ScreenDebugger.h"
#import <Masonry/Masonry.h>

@interface TDFSDCrashCaptureDetailController () <TDFSDFullScreenConsoleControllerInheritProtocol>

@property (nonatomic, strong) TDFSDTextView *crashDetailView;

@end

@implementation TDFSDCrashCaptureDetailController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    SD_DELAY_HANDLER(0.20f, {
        [self.crashDetailView sd_fadeAnimationWithDuration:0.40f];
        self.crashDetailView.text = self.crash.description;
    })
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"Specified Crash Detail";
}

- (__kindof UIView *)contentViewForFullScreenConsole {
    return self.crashDetailView;
}

#pragma mark - getter
- (TDFSDTextView *)crashDetailView {
    if (!_crashDetailView) {
        _crashDetailView = [[TDFSDTextView alloc] init];
        _crashDetailView.textColor = [UIColor whiteColor];
        _crashDetailView.font = [UIFont fontWithName:@"PingFang SC" size:13];
        _crashDetailView.showsVerticalScrollIndicator = NO;
    }
    return _crashDetailView;
}

@end
