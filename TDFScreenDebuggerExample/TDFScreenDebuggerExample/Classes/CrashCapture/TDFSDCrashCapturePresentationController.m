//
//  TDFSDCrashCapturePresentationController.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/16.
//

#import "TDFSDCrashCapturePresentationController.h"
#import "TDFSDCCCrashModel.h"
#import <Masonry/Masonry.h>

@interface TDFSDCrashCapturePresentationController ()

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *presentationView;
@property (nonatomic, strong) UIButton *exportButton;
@property (nonatomic, strong) UIButton *terminateButton;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation TDFSDCrashCapturePresentationController

static const NSString *kSDCCExportButtonTitle     =  @"Export";
static const NSString *kSDCCTerminateButtonTitle  =  @"Terminate";

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self layoutPageSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.presentationView.attributedText = [self crashInfoAttributedString];
}

#pragma mark - private
- (void)layoutPageSubviews {
    [self.view addSubview:self.effectView];
    [self.view addSubview:self.container];
    [self.container addSubview:self.titleLabel];
    [self.container addSubview:self.presentationView];
    [self.container addSubview:self.exportButton];
    [self.container addSubview:self.terminateButton];
    [self.exportButton addSubview:self.indicatorView];
    
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.container).with.offset(40);
        make.left.equalTo(self.container).with.offset(16);
        make.right.equalTo(self.container).with.offset(-16);
    }];
    [self.presentationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(12);
        make.left.equalTo(self.container).with.offset(11);
        make.right.equalTo(self.container).with.offset(-11);
        make.bottom.equalTo(self.container).with.offset(-48);
    }];
    [self.exportButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container).with.offset(12);
        make.right.equalTo(self.container.mas_centerX).with.offset(-6);
        make.bottom.equalTo(self.container).with.offset(-8);
        make.height.equalTo(@34);
    }];
    [self.terminateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.container.mas_centerX).with.offset(6);
        make.right.equalTo(self.container).with.offset(-12);
        make.bottom.equalTo(self.container).with.offset(-8);
        make.height.equalTo(@34);
    }];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.exportButton);
    }];
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

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:22];
        _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _titleLabel.text = @"Hey, We capture a crash !";
    }
    return _titleLabel;
}

- (UITextView *)presentationView {
    if (!_presentationView) {
        _presentationView = [[UITextView alloc] init];
        _presentationView.backgroundColor = [UIColor clearColor];
        _presentationView.editable = NO;
        _presentationView.selectable = YES;
        _presentationView.allowsEditingTextAttributes = YES;
        _presentationView.showsVerticalScrollIndicator = NO;
        _presentationView.showsHorizontalScrollIndicator = NO;
        _presentationView.textColor = [UIColor whiteColor];
    }
    return _presentationView;
}

- (UIButton *)exportButton {
    if (!_exportButton) {
        _exportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exportButton setBackgroundColor:[UIColor colorWithRed:118/255.f green:215/255.f blue:196/255.f alpha:0.15]];
        _exportButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _exportButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
        [_exportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_exportButton setTitle:(NSString *)kSDCCExportButtonTitle forState:UIControlStateNormal];
        _exportButton.layer.cornerRadius = 4.0f;
        _exportButton.layer.masksToBounds = YES;
        @weakify(self)
        _exportButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(UIButton * _Nullable input) {
            @strongify(self)
            [input setTitle:@"" forState:UIControlStateNormal];
            input.userInteractionEnabled = NO;
            [self.indicatorView startAnimating];
            void(^done)() = ^{
                @strongify(self)
                [self.exportButton setTitle:(NSString *)kSDCCExportButtonTitle forState:UIControlStateNormal];
                self.exportButton.userInteractionEnabled = YES;
                [self.indicatorView stopAnimating];
            };
            !self.exportProxy ?: [self.exportProxy sendNext:done];
            return [RACSignal empty];
        }];
    }
    return _exportButton;
}

- (UIButton *)terminateButton {
    if (!_terminateButton) {
        _terminateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_terminateButton setBackgroundColor:[UIColor colorWithRed:118/255.f green:215/255.f blue:196/255.f alpha:0.15]];
        _terminateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _terminateButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
        [_terminateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_terminateButton setTitle:(NSString *)kSDCCTerminateButtonTitle forState:UIControlStateNormal];
        _terminateButton.layer.cornerRadius = 4.0f;
        _terminateButton.layer.masksToBounds = YES;
        @weakify(self)
        _terminateButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            !self.terminateProxy ?: [self.terminateProxy sendNext:self.crashInfo];
            return [RACSignal empty];
        }];
    }
    return _terminateButton;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _indicatorView;
}

- (NSAttributedString *)crashInfoAttributedString {
    NSString *preTip = @"The following is a detailed crash message\n\n";
    NSString *crashDes = self.crashInfo.description;
    NSString *crashInfo = [NSString stringWithFormat:@"%@%@", preTip, crashDes];
    NSMutableAttributedString *mutableAS = [[NSMutableAttributedString alloc] initWithString:crashInfo];
    NSRange allRange = NSMakeRange(0, crashInfo.length);
    NSRange preRange = NSMakeRange(0, preTip.length);
    [mutableAS addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:13], NSForegroundColorAttributeName:[UIColor whiteColor]} range:allRange];
    [mutableAS addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:15], NSForegroundColorAttributeName:[UIColor yellowColor]} range:preRange];
    return [mutableAS copy];
}

@end
