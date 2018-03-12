//
//  TDFSDFullScreenConsoleController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/13.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDFullScreenConsoleController.h"
#import "TDFSDManager.h"
#import "TDFSDTransitionAnimator.h"
#import "UIView+ScreenDebugger.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>


@interface TDFSDFullScreenConsoleController ()

@property (nonatomic, strong, readwrite) UIView *container;
@property (nonatomic, strong) UIVisualEffectView *effectView;

@property (nonatomic, strong) UILabel *consoleTitleLabel;
@property (nonatomic, strong) __kindof UIView *contentView;

@property (nonatomic, strong) UIScrollView *menuTool;
// menuToolLayoutContainer is convenient and correct for layouting menuItems in menuTool(scrollView)
// https://spin.atomicobject.com/2014/03/05/uiscrollview-autolayout-ios/
@property (nonatomic, strong) UIView *menuToolLayoutContainer;
@property (nonatomic, strong, readwrite) NSArray<TDFSDFunctionMenuItem *> *menuItems;

@property (nonatomic, strong) UIView *hudLayer;
@property (nonatomic, strong) UILabel *hudLabel;

@end

const CGFloat SDFullScreenContentViewEdgeMargin  = 6.f;

static const CGFloat kSDTopToolMenuItemLength = 20.f;
static const CGFloat kSDTopToolMenuItemMargin = kSDTopToolMenuItemLength;

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
    [self fsbase_fetchMenuItems];
    [self fsbase_layoutPageSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // apply to become keywindow for `TDFSDWindow` instance
    [[TDFSDManager manager] applyForAcceptKeyInput];
}

- (void)dealloc {
    // let `TDFSDWindow` instance gives up becoming keywindow
    [[TDFSDManager manager] revokeApply];
}

#pragma mark - interface methods
- (void)sendClearRemindLabelTextRequestWithContentType:(SDAllReadNotificationContentType)contentType {
    [[NSNotificationCenter defaultCenter] postNotificationName:SD_REMIND_MESSAGE_ALL_READ_NOTIFICATION_NAME object:@(contentType)];
}

- (void)presentLoadingHUDWithText:(NSString *)hudText autoDismiss:(BOOL)autoDismiss {
    self.hudLayer.hidden = NO;
    [UIView animateWithDuration:.3 delay:.05 usingSpringWithDamping:.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.hudLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.hudLayer.mas_bottom).with.offset(-40);
        }];
    } completion:^(BOOL finished) {
        if (finished && autoDismiss) {
            SD_DELAY_HANDLER(.5f, {
                [self dismissLoadingHUD];
            });
        }
    }];
    [self.hudLabel.superview layoutIfNeeded];
    [self.hudLabel setText:hudText];
    [self.hudLabel sd_fadeAnimationWithDuration:.2f];
}

- (void)dismissLoadingHUD {
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.hudLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.hudLayer.mas_bottom);
        }];
    } completion:^(BOOL finished) {
        self.hudLayer.hidden = YES;
    }];
    [self.hudLabel.superview layoutIfNeeded];
}

#pragma mark - event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [TDFSDTransitionAnimator new];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [TDFSDTransitionAnimator new];
}

#pragma mark - private
- (void)fsbase_fetchMenuItems {
    if ([self respondsToSelector:@selector(functionMenuItemsForFullScreenConsole)]) {
       NSArray<TDFSDFunctionMenuItem *> *items = [(TDFSDFullScreenConsoleController<TDFSDFullScreenConsoleControllerInheritProtocol> *)self functionMenuItemsForFullScreenConsole];
        self.menuItems = items ?: @[];
    } else {
        self.menuItems = @[];
    }
}

- (void)fsbase_layoutPageSubviews {
    
    [self.view addSubview:self.effectView];
    [self.view addSubview:self.container];
    [self.view addSubview:self.hudLayer];
    [self.hudLayer addSubview:self.hudLabel];
    [self.container addSubview:self.consoleTitleLabel];
    [self.container addSubview:self.contentView];
    
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.hudLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.hudLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hudLayer.mas_bottom);
        make.left.and.right.equalTo(self.hudLayer);
        make.height.equalTo(@40);
    }];
    [self.consoleTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).with.offset(20);
        make.top.equalTo(self.container).with.offset(SD_IS_IPHONEX ? 35 : 11);
        make.height.equalTo(@36);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.consoleTitleLabel.mas_bottom).with.offset(6);
        make.left.equalTo(self.container).with.offset(SDFullScreenContentViewEdgeMargin);
        make.right.equalTo(self.container).with.offset(-SDFullScreenContentViewEdgeMargin);
        make.bottom.equalTo(self.container).with.offset(0);
    }];
    
    [self.container layoutIfNeeded];
    
    // In order to avoid the following system warning, so we should judge items count setted by `TDFSDFullScreenConsoleControllerInheritProtocol` method
    // This NSLayoutConstraint is being configured with a constant that exceeds internal limits.  A smaller value will be substituted, but this problem should be fixed. Break on BOOL _NSLayoutConstraintNumberExceedsLimit() to debug.  This will be logged only once.  This may break in the future.
    if (self.menuItems.count) {
        
        [self.container addSubview:self.menuTool];
        [self.menuTool addSubview:self.menuToolLayoutContainer];
        
        [self.menuTool mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.consoleTitleLabel.mas_right).with.offset(30);
            make.right.equalTo(self.container).with.offset(-16);
            make.top.equalTo(self.consoleTitleLabel);
            make.height.equalTo(@36);
        }];
        
        [self.menuTool.superview layoutIfNeeded];
        
        CGFloat contentWidth = self.menuItems.count * kSDTopToolMenuItemLength + (self.menuItems.count-1) * kSDTopToolMenuItemMargin;
        CGFloat containerWidth = contentWidth > self.menuTool.bounds.size.width ? contentWidth : self.menuTool.bounds.size.width;
        
        // must set the complete layout constraints for vertical and horizontal direction
        // http://adad184.com/2015/12/01/scrollview-under-autolayout/
        [self.menuToolLayoutContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.menuTool);
            make.height.equalTo(self.menuTool);
            make.width.equalTo(@(containerWidth));
        }];
        
        [self.menuItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TDFSDFunctionMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.menuToolLayoutContainer addSubview:obj];
            [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                CGFloat rightMargin = (self.menuItems.count-idx-1) * (kSDTopToolMenuItemMargin+kSDTopToolMenuItemLength);
                make.right.equalTo(self.menuToolLayoutContainer).with.offset(-rightMargin);
                make.centerY.equalTo(self.menuTool);
                make.width.and.height.equalTo(@(kSDTopToolMenuItemLength));
            }];
        }];
    }
}

#pragma mark - getter
- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        [_container setBackgroundColor:[UIColor colorWithRed:2/255.f green:31/255.f blue:40/255.f alpha:0.7]];
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
        _consoleTitleLabel.textAlignment = NSTextAlignmentLeft;
        _consoleTitleLabel.numberOfLines = 1;
        _consoleTitleLabel.textColor = [UIColor whiteColor];
        _consoleTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        _consoleTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _consoleTitleLabel.text = [(TDFSDFullScreenConsoleController<TDFSDFullScreenConsoleControllerInheritProtocol> *)self titleForFullScreenConsole];
    }
    return _consoleTitleLabel;
}

- (UIScrollView *)menuTool {
    if (!_menuTool) {
        _menuTool = [[UIScrollView alloc] init];
        _menuTool.backgroundColor = [UIColor clearColor];
        _menuTool.scrollEnabled = YES;
        _menuTool.showsVerticalScrollIndicator = NO;
        _menuTool.showsHorizontalScrollIndicator = NO;
    }
    return _menuTool;
}

- (UIView *)menuToolLayoutContainer {
    if (!_menuToolLayoutContainer) {
        _menuToolLayoutContainer = [[UIView alloc] init];
        _menuToolLayoutContainer.backgroundColor = [UIColor clearColor];
    }
    return _menuToolLayoutContainer;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [(TDFSDFullScreenConsoleController<TDFSDFullScreenConsoleControllerInheritProtocol> *)self contentViewForFullScreenConsole];
    }
    return _contentView;
}

- (UIView *)hudLayer {
    if (!_hudLayer) {
        _hudLayer = [[UIView alloc] init];
        _hudLayer.backgroundColor = [UIColor clearColor];
        _hudLayer.hidden = YES;
    }
    return _hudLayer;
}

- (UILabel *)hudLabel {
    if (!_hudLabel) {
        _hudLabel = [[UILabel alloc] init];
        [_hudLabel setBackgroundColor:[UIColor yellowColor]];
        _hudLabel.textAlignment = NSTextAlignmentCenter;
        _hudLabel.numberOfLines = 1;
        _hudLabel.textColor = [UIColor whiteColor];
        _hudLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14];
        _hudLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _hudLabel;
}

@end

@implementation TDFSDFunctionMenuItem

+ (instancetype)itemWithImage:(UIImage *)image actionHandler:(void (^)(TDFSDFunctionMenuItem *))actionHandler {
    TDFSDFunctionMenuItem *item = [TDFSDFunctionMenuItem buttonWithType:UIButtonTypeCustom];
    [item setBackgroundColor:[UIColor clearColor]];
    [item setBackgroundImage:image forState:UIControlStateNormal];
    @weakify(item)
    item.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(item)
        !actionHandler ?: actionHandler(item);
        return [RACSignal empty];
    }];
    return item;
}

@end
