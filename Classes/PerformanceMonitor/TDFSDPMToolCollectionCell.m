//
//  TDFSDPMToolCollectionCell.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/6.
//

#import "TDFSDPMToolCollectionCell.h"
#import <Masonry/Masonry.h>

@interface TDFSDPMToolCollectionCell ()

@property (nonatomic, strong) UIVisualEffectView *effectBackgroudView;
@property (nonatomic, strong) UILabel *toolNameLabel;
@property (nonatomic, strong) UILabel *toolDescriptionLabel;
@property (nonatomic, strong) UISwitch *toolSwitch;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation TDFSDPMToolCollectionCell

#pragma mark - life cycle
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    TDFSDPMToolCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    cell.indexPath = indexPath;
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundView = self.effectBackgroudView;
        self.backgroundView.alpha = 0.35;
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        [self layoutPageSubviews];
    }
    return self;
}

#pragma mark - interface methods
- (void)bindWithViewModel:(TDFSDPMExtraToolModel *)viewModel {
    self.toolNameLabel.text = viewModel.name;
    self.toolDescriptionLabel.text = viewModel.toolDescription;
    [self.toolSwitch setOn:viewModel.isOn animated:NO];
}

#pragma mark - getter
- (UIVisualEffectView *)effectBackgroudView {
    if (!_effectBackgroudView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectBackgroudView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _effectBackgroudView;
}

- (UILabel *)toolNameLabel {
    if (!_toolNameLabel) {
        _toolNameLabel = [[UILabel alloc] init];
        [_toolNameLabel setBackgroundColor:[UIColor clearColor]];
        _toolNameLabel.textAlignment = NSTextAlignmentLeft;
        _toolNameLabel.numberOfLines = 1;
        _toolNameLabel.textColor = [UIColor whiteColor];
        _toolNameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:15];
        _toolNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _toolNameLabel;
}

- (UILabel *)toolDescriptionLabel {
    if (!_toolDescriptionLabel) {
        _toolDescriptionLabel = [[UILabel alloc] init];
        [_toolDescriptionLabel setBackgroundColor:[UIColor clearColor]];
        _toolDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        _toolDescriptionLabel.numberOfLines = 2;
        _toolDescriptionLabel.textColor = [UIColor groupTableViewBackgroundColor];
        _toolDescriptionLabel.font = [UIFont fontWithName:@"PingFang SC" size:13];
        _toolDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _toolDescriptionLabel;
}

- (UISwitch *)toolSwitch {
    if (!_toolSwitch) {
        _toolSwitch = [[UISwitch alloc] init];
        _toolSwitch.tintColor = [UIColor colorWithRed:27/255.f green:156/255.f blue:226/255.f alpha:1];
        _toolSwitch.onTintColor = [UIColor colorWithRed:27/255.f green:156/255.f blue:226/255.f alpha:1];
        _toolSwitch.thumbTintColor = [UIColor colorWithRed:27/255.f green:156/255.f blue:226/255.f alpha:1];
        [_toolSwitch addTarget:self action:@selector(toolSwitchDidChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _toolSwitch;
}

#pragma mark - private
- (void)layoutPageSubviews {
    [self.contentView addSubview:self.effectBackgroudView];
    [self.contentView addSubview:self.toolNameLabel];
    [self.contentView addSubview:self.toolDescriptionLabel];
    [self.contentView addSubview:self.toolSwitch];
    
    [self.effectBackgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.toolNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(11);
        make.top.equalTo(self.contentView);
        make.height.equalTo(@35);
        make.right.lessThanOrEqualTo(self.contentView).with.offset(-80);
    }];
    [self.toolDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.toolNameLabel);
        make.right.equalTo(self.toolNameLabel);
        make.top.equalTo(self.toolNameLabel.mas_bottom);
        make.bottom.equalTo(self.contentView).with.offset(-5);
    }];
    [self.toolSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-11);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)toolSwitchDidChange:(UISwitch *)toolSwitch {
    !self.toolSwitchDidChangeHandler ?: self.toolSwitchDidChangeHandler(self.indexPath, toolSwitch.isOn);
}

@end
