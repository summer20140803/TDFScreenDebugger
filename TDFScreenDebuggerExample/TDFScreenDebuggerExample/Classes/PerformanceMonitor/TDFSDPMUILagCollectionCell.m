//
//  TDFSDPMUILagCollectionCell.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/29.
//

#import "TDFSDPMUILagCollectionCell.h"
#import <Masonry/Masonry.h>

@interface TDFSDPMUILagCollectionCell ()

@property (nonatomic, strong) UIVisualEffectView *effectBackgroudView;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation TDFSDPMUILagCollectionCell

#pragma mark - life cycle
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    TDFSDPMUILagCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
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
- (void)bindWithViewModel:(TDFSDPMUILagCollectionViewModel *)viewModel {
    self.timeLabel.text = [NSString stringWithFormat:@"%@", viewModel.lagModel.occurTime];
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
        _timeLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
        _timeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _timeLabel;
}

#pragma mark - private
- (void)layoutPageSubviews {
    [self.contentView addSubview:self.effectBackgroudView];
    [self.contentView addSubview:self.timeLabel];
    
    [self.effectBackgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(8);
        make.right.equalTo(self.contentView).with.offset(-8);
        make.center.equalTo(self.contentView);
    }];
}

@end
