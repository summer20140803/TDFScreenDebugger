//
//  TDFSDARCollectionViewCell.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/27.
//
//

#import "TDFSDARCollectionViewCell.h"
#import "TDFSDARCollectionViewModel.h"
#import "TDFScreenDebuggerDefine.h"
#import <Masonry/Masonry.h>

@interface TDFSDARCollectionViewCell ()

@property (nonatomic, strong) UIVisualEffectView *effectBackgroudView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *validURLLabel;

@end

@implementation TDFSDARCollectionViewCell

#pragma mark - life cycle
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    TDFSDARCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
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
- (void)bindWithViewModel:(TDFSDARCollectionViewModel *)viewModel {
    self.timeLabel.text = [viewModel.requestModel.milestoneTime stringByReplacingOccurrencesOfString:@"\n" withString:@""] ?: SD_STRING(@"Not set");
    self.descriptionLabel.text = [viewModel.requestModel.taskDescription stringByReplacingOccurrencesOfString:@"\n" withString:@""] ?: SD_STRING(@"Not set");
    self.validURLLabel.text = [viewModel.requestModel.validURL stringByReplacingOccurrencesOfString:@"\n" withString:@""] ?: SD_STRING(@"Not set");
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

- (UILabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc] init];
        [_descriptionLabel setBackgroundColor:[UIColor clearColor]];
        _descriptionLabel.textAlignment = NSTextAlignmentLeft;
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.textColor = [UIColor whiteColor];
        _descriptionLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
        _descriptionLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _descriptionLabel;
}

- (UILabel *)validURLLabel {
    if (!_validURLLabel) {
        _validURLLabel = [[UILabel alloc] init];
        [_validURLLabel setBackgroundColor:[UIColor clearColor]];
        _validURLLabel.textAlignment = NSTextAlignmentLeft;
        _validURLLabel.numberOfLines = 0;
        _validURLLabel.textColor = [UIColor whiteColor];
        _validURLLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
        _validURLLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _validURLLabel;
}

#pragma mark - private
- (void)layoutPageSubviews {
    [self.contentView addSubview:self.effectBackgroudView];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.descriptionLabel];
    [self.contentView addSubview:self.validURLLabel];
    
    [self.effectBackgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(8);
        make.right.equalTo(self.contentView).with.offset(-8);
        make.top.equalTo(self.contentView).with.offset(8);
        make.height.equalTo(@15);
    }];
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).with.offset(4);
        make.right.equalTo(self.contentView).with.offset(-8);
        make.left.equalTo(self.contentView).with.offset(8);
    }];
    [self.validURLLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(8);
        make.right.equalTo(self.contentView).with.offset(-8);
        make.top.equalTo(self.descriptionLabel.mas_bottom).with.offset(3);
    }];
}

@end
