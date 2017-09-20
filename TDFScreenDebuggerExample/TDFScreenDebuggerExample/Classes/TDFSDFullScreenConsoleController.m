//
//  TDFSDFullScreenConsoleController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/13.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDFullScreenConsoleController.h"
#import "TDFSDManager.h"
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

@end

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

#pragma mark - getter
- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        [_container setBackgroundColor:[UIColor colorWithRed:2/255.f green:31/255.f blue:40/255.f alpha:0.7]];
        _container.alpha = 1;
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
        _consoleTitleLabel.font = [UIFont fontWithName:@"PingFang SC" size:17];
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

#pragma mark - event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [self.container addSubview:self.consoleTitleLabel];
    [self.container addSubview:self.menuTool];
    [self.container addSubview:self.contentView];
    [self.menuTool addSubview:self.menuToolLayoutContainer];
    
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.consoleTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).with.offset(20);
        make.top.equalTo(self.container).with.offset(11);
        make.height.equalTo(@36);
    }];
    [self.menuTool mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.consoleTitleLabel.mas_right).with.offset(30);
        make.right.equalTo(self.container).with.offset(-16);
        make.top.equalTo(self.container).with.offset(11);
        make.height.equalTo(@36);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.consoleTitleLabel.mas_bottom).with.offset(6);
        make.left.equalTo(self.container).with.offset(6);
        make.right.equalTo(self.container).with.offset(-6);
        make.bottom.equalTo(self.container).with.offset(0);
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
