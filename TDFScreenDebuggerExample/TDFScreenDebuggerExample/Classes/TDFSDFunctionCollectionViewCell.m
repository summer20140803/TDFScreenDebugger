//
//  TDFSDFunctionCollectionViewCell.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/20.
//
//

#import "TDFSDFunctionCollectionViewCell.h"
#import "TDFSDFunctionModel.h"
#import "TDFSDFullScreenConsoleController.h"
#import "TDFSDFunctionCollectionViewModel.h"
#import <Masonry/Masonry.h>


@interface TDFSDFunctionCollectionViewCell ()

@property (nonatomic, strong) UIVisualEffectView *effectBackgroudView;
@property (nonatomic, strong) UILabel *functionNameLabel;
@property (nonatomic, strong) UIImageView *functionIconView;
@property (nonatomic, strong) UILabel *functionDescriptionLabel;
@property (nonatomic, strong) UILabel *quickLaunchDesLabel;

@end

@implementation TDFSDFunctionCollectionViewCell

#pragma mark - life cycle
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    TDFSDFunctionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundView = self.effectBackgroudView;
        self.backgroundView.alpha = 0.35;
        self.layer.cornerRadius = 20.f;
        self.layer.masksToBounds = YES;
        [self layoutPageSubviews];
    }
    return self;
}

#pragma mark - interface methods
- (void)bindWithViewModel:(TDFSDFunctionCollectionViewModel *)viewModel {
    self.functionNameLabel.text = viewModel.function.functionName;
    self.functionIconView.image = [UIImage imageNamed:viewModel.function.functionIcon];
    self.functionDescriptionLabel.text = viewModel.function.functionDescription;
    self.quickLaunchDesLabel.text = viewModel.function.quickLaunchDescrition;
}

#pragma mark - private
- (void)layoutPageSubviews {
    
    [self.contentView addSubview:self.functionIconView];
    [self.contentView addSubview:self.functionNameLabel];
    [self.contentView addSubview:self.functionDescriptionLabel];
    [self.contentView addSubview:self.quickLaunchDesLabel];
    
    [self.effectBackgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.functionIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(12);
        make.top.equalTo(self.contentView).with.offset(18);
        make.width.and.height.equalTo(@40);
    }];
    [self.functionNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.functionIconView.mas_right).with.offset(15);
        make.top.equalTo(self.contentView).with.offset(10);
        make.right.equalTo(self.contentView).with.offset(-8);
        make.height.equalTo(@15);
    }];
    [self.functionDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.functionNameLabel.mas_bottom).with.offset(6);
        make.left.equalTo(self.functionNameLabel);
        make.right.equalTo(self.functionNameLabel);
    }];
    [self.quickLaunchDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.functionDescriptionLabel.mas_bottom).with.offset(6);
        make.height.equalTo(@15);
    }];
}

#pragma mark - getter
- (UIVisualEffectView *)effectBackgroudView {
    if (!_effectBackgroudView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectBackgroudView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _effectBackgroudView;
}

- (UILabel *)functionNameLabel {
    if (!_functionNameLabel) {
        _functionNameLabel = [[UILabel alloc] init];
        [_functionNameLabel setBackgroundColor:[UIColor clearColor]];
        _functionNameLabel.textAlignment = NSTextAlignmentLeft;
        _functionNameLabel.numberOfLines = 1;
        _functionNameLabel.textColor = [UIColor whiteColor];
        _functionNameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:13];
        _functionNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _functionNameLabel;
}

- (UIImageView *)functionIconView {
    if (!_functionIconView) {
        _functionIconView = [[UIImageView alloc] init];
        _functionIconView.contentMode = NSLineBreakByWordWrapping;
    }
    return _functionIconView;
}

- (UILabel *)functionDescriptionLabel {
    if (!_functionDescriptionLabel) {
        _functionDescriptionLabel = [[UILabel alloc] init];
        [_functionDescriptionLabel setBackgroundColor:[UIColor clearColor]];
        _functionDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        _functionDescriptionLabel.numberOfLines = 0;
        _functionDescriptionLabel.textColor = [UIColor whiteColor];
        _functionDescriptionLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
        _functionDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _functionDescriptionLabel;
}

- (UILabel *)quickLaunchDesLabel {
    if (!_quickLaunchDesLabel) {
        _quickLaunchDesLabel = [[UILabel alloc] init];
        [_quickLaunchDesLabel setBackgroundColor:[UIColor clearColor]];
        _quickLaunchDesLabel.textAlignment = NSTextAlignmentCenter;
        _quickLaunchDesLabel.numberOfLines = 1;
        _quickLaunchDesLabel.textColor = [UIColor whiteColor];
        _quickLaunchDesLabel.font = [UIFont fontWithName:@"PingFang SC" size:11];
        _quickLaunchDesLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _quickLaunchDesLabel;
}


@end
