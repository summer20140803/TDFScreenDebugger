//
//  TDFSDFullScreenConsoleController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/13.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDFullScreenConsoleController.h"
#import <Masonry/Masonry.h>

@interface TDFSDFullScreenConsoleController ()

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UILabel *consoleTitleLabel;
@property (nonatomic, strong) __kindof UIView *contentView;

@end

@implementation TDFSDFullScreenConsoleController

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        NSAssert([self conformsToProtocol:@protocol(TDFSDFullScreenConsoleControllerInheritProtocol)],
                 @"subclass should achieve `TDFSDFullScreenConsoleControllerInheritProtocol` methods");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self fsbase_layoutPageSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.container.alpha = 1;
    } completion:nil];
}

#pragma mark - getter
- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        [_container setBackgroundColor:[UIColor colorWithRed:2/255.f green:31/255.f blue:40/255.f alpha:0.7]];
        _container.alpha = 0;
    }
    return _container;
}

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _effectView;
}

- (UILabel *)consoleTitleLabel {
    if (!_consoleTitleLabel) {
        _consoleTitleLabel = [[UILabel alloc] init];
        [_consoleTitleLabel setBackgroundColor:[UIColor clearColor]];
        _consoleTitleLabel.textAlignment = NSTextAlignmentCenter;
        _consoleTitleLabel.numberOfLines = 1;
        _consoleTitleLabel.textColor = [UIColor whiteColor];
        _consoleTitleLabel.font = [UIFont fontWithName:@"PingFang SC" size:24];
        _consoleTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _consoleTitleLabel.text = [(TDFSDFullScreenConsoleController<TDFSDFullScreenConsoleControllerInheritProtocol> *)self titleForFullScreenConsole];
    }
    return _consoleTitleLabel;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [(TDFSDFullScreenConsoleController<TDFSDFullScreenConsoleControllerInheritProtocol> *)self contentViewForFullScreenConsole];
    }
    return _contentView;
}

#pragma mark - event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private
- (void)fsbase_layoutPageSubviews {
    
    [self.view addSubview:self.effectView];
    [self.view addSubview:self.container];
    [self.container addSubview:self.consoleTitleLabel];
    [self.container addSubview:self.contentView];
    
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.consoleTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.container);
        make.top.equalTo(self.container).with.offset(30);
        make.height.equalTo(@44);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.consoleTitleLabel.mas_bottom).with.offset(20);
        make.left.equalTo(self.container).with.offset(28);
        make.right.equalTo(self.container).with.offset(-28);
        make.bottom.equalTo(self.container).with.offset(-20);
    }];
}


@end
