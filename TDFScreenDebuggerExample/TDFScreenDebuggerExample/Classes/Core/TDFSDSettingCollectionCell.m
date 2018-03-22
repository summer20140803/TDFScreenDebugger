//
//  TDFSDSettingCollectionCell.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/16.
//

#import "TDFSDSettingCollectionCell.h"
#import <Masonry/Masonry.h>

@interface TDFSDSettingCollectionCell ()

@property (nonatomic, strong) UIVisualEffectView *effectBackgroudView;
@property (nonatomic, strong) UILabel *settingTitleLabel;
@property (nonatomic, strong) UILabel *settingDescriptionLabel;
@property (nonatomic, strong) UISwitch *settingSwitch;
@property (nonatomic, strong) UIButton *pickerButton;

@property (nonatomic, assign) SDSettingEditType type;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation TDFSDSettingCollectionCell

#pragma mark - lifecycle
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath type:(SDSettingEditType)type {
    TDFSDSettingCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.type = type;
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundView = self.effectBackgroudView;
        self.backgroundView.alpha = 0.35;
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        [self layoutPageSubviews];
    }
    return self;
}

#pragma mark - interface methods
- (void)renderWithTitle:(NSString *)title description:(NSString *)description settingOptionValue:(id)settingOptionValue {
    self.settingTitleLabel.text = title;
    self.settingDescriptionLabel.text = description;
    
    if (self.type == SDSettingEditTypeOptionPicker) {
        [self.pickerButton setTitle:settingOptionValue forState:UIControlStateNormal];
    } else if (self.type == SDSettingEditTypeSwitch) {
        [self.settingSwitch setOn:[(NSNumber *)settingOptionValue boolValue] animated:NO];
    }
}

#pragma mark - getter & setter
- (void)setType:(SDSettingEditType)type {
    _type = type;
    switch (type) {
        case SDSettingEditTypeSwitch: {
            self.settingSwitch.hidden = NO;
            self.pickerButton.hidden = YES;
        } break;
        case SDSettingEditTypeOptionPicker: {
            self.settingSwitch.hidden = YES;
            self.pickerButton.hidden = NO;
        } break;
    }
}

- (UIVisualEffectView *)effectBackgroudView {
    if (!_effectBackgroudView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectBackgroudView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _effectBackgroudView;
}

- (UILabel *)settingTitleLabel {
    if (!_settingTitleLabel) {
        _settingTitleLabel = [[UILabel alloc] init];
        [_settingTitleLabel setBackgroundColor:[UIColor clearColor]];
        _settingTitleLabel.textAlignment = NSTextAlignmentLeft;
        _settingTitleLabel.numberOfLines = 1;
        _settingTitleLabel.textColor = [UIColor whiteColor];
        _settingTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14];
        _settingTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _settingTitleLabel;
}

- (UILabel *)settingDescriptionLabel {
    if (!_settingDescriptionLabel) {
        _settingDescriptionLabel = [[UILabel alloc] init];
        [_settingDescriptionLabel setBackgroundColor:[UIColor clearColor]];
        _settingDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        _settingDescriptionLabel.numberOfLines = 0;
        _settingDescriptionLabel.textColor = [UIColor groupTableViewBackgroundColor];
        _settingDescriptionLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
        _settingDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _settingDescriptionLabel;
}

- (UISwitch *)settingSwitch {
    if (!_settingSwitch) {
        _settingSwitch = [[UISwitch alloc] init];
        [_settingSwitch addTarget:self action:@selector(settingSwitchValueDidChangeManually:) forControlEvents:UIControlEventValueChanged];
    }
    return _settingSwitch;
}

- (UIButton *)pickerButton {
    if (!_pickerButton) {
        _pickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pickerButton setBackgroundColor:[UIColor clearColor]];
        [_pickerButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        _pickerButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:13];
        [_pickerButton setTitleColor:[UIColor colorWithRed:85/255.f green:196/255.f blue:245/255.f alpha:1] forState:UIControlStateNormal];
        [_pickerButton addTarget:self action:@selector(pickerButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pickerButton;
}

#pragma mark - private
- (void)layoutPageSubviews {
    [self.contentView addSubview:self.effectBackgroudView];
    [self.contentView addSubview:self.settingTitleLabel];
    [self.contentView addSubview:self.settingDescriptionLabel];
    [self.contentView addSubview:self.settingSwitch];
    [self.contentView addSubview:self.pickerButton];
    
    [self.effectBackgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.settingTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(11);
        make.top.equalTo(self.contentView);
        make.height.equalTo(@40);
        make.right.lessThanOrEqualTo(self.contentView).with.offset(-100);
    }];
    [self.settingDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.settingTitleLabel);
        make.right.equalTo(self.contentView).with.offset(-11);
        make.top.equalTo(self.settingTitleLabel.mas_bottom);
        make.bottom.equalTo(self.contentView).with.offset(0);
    }];
    [self.settingSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-11);
        make.centerY.equalTo(self.settingTitleLabel);
    }];
    [self.pickerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-11);
        make.centerY.equalTo(self.settingSwitch);
        make.left.equalTo(self.settingTitleLabel.mas_right);
        make.height.equalTo(@40);
    }];
}

- (void)settingSwitchValueDidChangeManually:(UISwitch *)switchSender {
    if ([self.optionDelegate respondsToSelector:@selector(switchValueDidChangeManually:withIndexPath:)]) {
        [self.optionDelegate switchValueDidChangeManually:switchSender.isOn withIndexPath:self.indexPath];
    }
}

- (void)pickerButtonDidClick:(UIButton *)buttonSender {
    if ([self.optionDelegate respondsToSelector:@selector(pickerButtonDidClick:)]) {
        [self.optionDelegate pickerButtonDidClickWithIndexPath:self.indexPath];
    }
}

@end
