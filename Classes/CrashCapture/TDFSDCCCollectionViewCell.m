//
//  TDFSDCCCollectionViewCell.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/31.
//

#import "TDFSDCCCollectionViewCell.h"
#import "TDFSDCCCollectionViewModel.h"
#import <Masonry/Masonry.h>

@interface TDFSDCCCollectionViewCell ()

@property (nonatomic, strong) UIVisualEffectView *effectBackgroudView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *exceptionNameLabel;
@property (nonatomic, strong) UILabel *exceptionReasonLabel;

@end

@implementation TDFSDCCCollectionViewCell

#pragma mark - life cycle
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    TDFSDCCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
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
- (void)bindWithViewModel:(TDFSDCCCollectionViewModel *)viewModel {
    self.timeLabel.text = viewModel.crashModel.exceptionTime;
    self.exceptionNameLabel.text = viewModel.crashModel.exceptionName;
    self.exceptionReasonLabel.text = viewModel.crashModel.exceptionReason;
}

#pragma mark - getter
- (UIVisualEffectView *)effectBackgroudView {
    if (!_effectBackgroudView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectBackgroudView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _effectBackgroudView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.numberOfLines = 1;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
        _timeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _timeLabel;
}

- (UILabel *)exceptionNameLabel {
    if (!_exceptionNameLabel) {
        _exceptionNameLabel = [[UILabel alloc] init];
        [_exceptionNameLabel setBackgroundColor:[UIColor clearColor]];
        _exceptionNameLabel.textAlignment = NSTextAlignmentLeft;
        _exceptionNameLabel.numberOfLines = 0;
        _exceptionNameLabel.textColor = [UIColor whiteColor];
        _exceptionNameLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
        _exceptionNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _exceptionNameLabel;
}

- (UILabel *)exceptionReasonLabel {
    if (!_exceptionReasonLabel) {
        _exceptionReasonLabel = [[UILabel alloc] init];
        [_exceptionReasonLabel setBackgroundColor:[UIColor clearColor]];
        _exceptionReasonLabel.textAlignment = NSTextAlignmentLeft;
        _exceptionReasonLabel.numberOfLines = 0;
        _exceptionReasonLabel.textColor = [UIColor whiteColor];
        _exceptionReasonLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
        _exceptionReasonLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _exceptionReasonLabel;
}

#pragma mark - private
- (void)layoutPageSubviews {
    [self.contentView addSubview:self.effectBackgroudView];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.exceptionNameLabel];
    [self.contentView addSubview:self.exceptionReasonLabel];
    
    [self.effectBackgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(8);
        make.right.equalTo(self.contentView).with.offset(-8);
        make.top.equalTo(self.contentView).with.offset(8);
        make.height.equalTo(@15);
    }];
    [self.exceptionNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).with.offset(4);
        make.right.equalTo(self.contentView).with.offset(-8);
        make.left.equalTo(self.contentView).with.offset(8);
    }];
    [self.exceptionReasonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(8);
        make.right.equalTo(self.contentView).with.offset(-8);
        make.top.equalTo(self.exceptionNameLabel.mas_bottom).with.offset(3);
    }];
}

@end
