//
//  TDFSDPerformanceMonitorLagDetailController.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/29.
//

#import "TDFSDPerformanceMonitorLagDetailController.h"
#import "TDFSDTextView.h"
#import "TDFSDPMUILagComponentModel.h"
#import "TDFScreenDebuggerDefine.h"
#import "UIView+ScreenDebugger.h"
#import <Masonry/Masonry.h>

@interface TDFSDPerformanceMonitorLagDetailController () <TDFSDFullScreenConsoleControllerInheritProtocol>

@property (nonatomic, strong) TDFSDTextView *lagDetailView;

@end

@implementation TDFSDPerformanceMonitorLagDetailController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    SD_DELAY_HANDLER(0.20f, {
        [self.lagDetailView sd_fadeAnimationWithDuration:0.40f];
        self.lagDetailView.text = [NSString stringWithFormat:@"%@\n\n%@", self.lag.occurTime, self.lag.callStackInfo];
    })
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return SD_STRING(@"Specified Lag Detail");
}

- (__kindof UIView *)contentViewForFullScreenConsole {
    return self.lagDetailView;
}

#pragma mark - getter
- (TDFSDTextView *)lagDetailView {
    if (!_lagDetailView) {
        _lagDetailView = [[TDFSDTextView alloc] init];
        _lagDetailView.textColor = [UIColor whiteColor];
        _lagDetailView.font = [UIFont fontWithName:@"PingFang SC" size:13];
        _lagDetailView.showsVerticalScrollIndicator = NO;
    }
    return _lagDetailView;
}

@end
