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
#import "TDFSDFunctionModel.h"
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
        self.textView.attributedText = [self functionPageContentWithIndex:self.functionModel.index];
    })
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return [self functionPageTitleWithIndex:self.functionModel.index] ?: @"";
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
        [_goSettingButton setTitle:SD_STRING(@"Go Setting") forState:UIControlStateNormal];
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

- (NSString *)functionPageTitleWithIndex:(NSUInteger)functionIndex {
    switch (functionIndex) {
        case 3: return SD_STRING(@"Performance Monitor"); break;
        case 5: return SD_STRING(@"MemoryLeak Detector"); break;
        case 6: return SD_STRING(@"WildPointer Checker"); break;
    }
    return nil;
}

- (NSAttributedString *)functionPageContentWithIndex:(NSUInteger)functionIndex {
    NSMutableAttributedString *mutablePageContent = [[NSMutableAttributedString alloc] initWithString:@""];
    NSString *frontPageContent;
    NSString *settingParamsIntro = SD_STRING(@"The follwing params could be setted by developers\n\n");;
    NSString *paramsDetail;
    
    switch (functionIndex) {
        case 3: {
            frontPageContent = SD_STRING(@"\n\tThis is a tool which can monitor the main thread and find out some caton nodes will correspond to the stack trace feedback to the developers, it can also monitor app CPU/Memory usage, detecting current UI FPS and more performance data for developers.\n\n");
            NSString *par1 = [NSString stringWithFormat:@" • %@", SD_STRING(@"allowUILagsMonitoring")];
            NSString *par2 = [NSString stringWithFormat:@" • %@", SD_STRING(@"tolerableLagThreshold")];
            NSString *par3 = [NSString stringWithFormat:@" • %@", SD_STRING(@"allowApplicationCPUMonitoring")];
            NSString *par4 = [NSString stringWithFormat:@" • %@", SD_STRING(@"allowApplicationMemoryMonitoring")];
            NSString *par5 = [NSString stringWithFormat:@" • %@", SD_STRING(@"allowScreenFPSMonitoring")];
            NSString *par6 = [NSString stringWithFormat:@" • %@", SD_STRING(@"fpsWarnningThreshold")];
            paramsDetail = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@", par1, par2, par3, par4, par5, par6];
        } break;
        case 5: {
            frontPageContent = SD_STRING(@"\n\tThis is a tool which can help developer to find out some suspicious memory leak points in project, it will loop through all strongly referenced nodes of each controller, but does not include objects that may be singletons, then give developers friendly tips for some suspicious leakers.\n\n");
            NSString *par1 = [NSString stringWithFormat:@" • %@", SD_STRING(@"allowMemoryLeaksDetectionFlag")];
            NSString *par2 = [NSString stringWithFormat:@" • %@", SD_STRING(@"memoryLeakingWarningType")];
            paramsDetail = [NSString stringWithFormat:@"%@\n%@", par1, par2];
        } break;
        case 6: {
            frontPageContent = SD_STRING(@"\n\tThis is a tool which can help developer to find out some wild pointer errors in project. However, turning on checking will cause a continuous increase in memory usage, so this feature will be reset to the off state when the application is killed by default.\n\n");
            NSString *par1 = [NSString stringWithFormat:@" • %@", SD_STRING(@"allowWildPointerCheck")];
            NSString *par2 = [NSString stringWithFormat:@" • %@", SD_STRING(@"maxZombiePoolCapacity")];
            paramsDetail = [NSString stringWithFormat:@"%@\n%@", par1, par2];
        } break;
    }
    
    NSDictionary *frontAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:16], NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSDictionary *introAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:14], NSForegroundColorAttributeName:[UIColor yellowColor]};
    NSDictionary *paramsAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size:16], NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSAttributedString *frontAS = [[NSAttributedString alloc] initWithString:frontPageContent attributes:frontAttributes];
    NSAttributedString *introAS = [[NSAttributedString alloc] initWithString:settingParamsIntro attributes:introAttributes];
    NSAttributedString *paramsAS = [[NSAttributedString alloc] initWithString:paramsDetail attributes:paramsAttributes];
    [mutablePageContent appendAttributedString:frontAS];
    [mutablePageContent appendAttributedString:introAS];
    [mutablePageContent appendAttributedString:paramsAS];
    
    return [mutablePageContent copy];
}

@end
