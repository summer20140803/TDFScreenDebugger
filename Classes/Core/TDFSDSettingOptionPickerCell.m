//
//  TDFSDSettingOptionPickerCell.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/23.
//

#import "TDFSDSettingOptionPickerCell.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDSettingOptionPickerCell ()

@property (nonatomic, strong) UILabel *optionTitleLabel;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic,   copy) void (^optionDidPickHandler)(NSIndexPath *indexPath, NSString *pickValue);

@end

@implementation TDFSDSettingOptionPickerCell

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    TDFSDSettingOptionPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    if (!cell) {
        cell = [[TDFSDSettingOptionPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([self class])];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:20/255.f green:157/255.f blue:180/255.f alpha:1.0]];
        cell.contentView.layer.cornerRadius = 20.0f;
        cell.contentView.layer.masksToBounds = YES;
        [cell layoutPageSubviews];
    }
    cell.indexPath = indexPath;
    return cell;
}

- (void)bindWithOptionTitle:(NSString *)optionTitle optionDidPickHandler:(void (^)(NSIndexPath *, NSString *))optionDidPickHandler {
    self.optionTitleLabel.text = optionTitle;
    self.optionDidPickHandler = optionDidPickHandler;
}

#pragma mark - getter
- (UILabel *)optionTitleLabel {
    if (!_optionTitleLabel) {
        _optionTitleLabel = [[UILabel alloc] init];
        [_optionTitleLabel setBackgroundColor:[UIColor clearColor]];
        _optionTitleLabel.textAlignment = NSTextAlignmentCenter;
        _optionTitleLabel.numberOfLines = 2;
        _optionTitleLabel.textColor = [UIColor whiteColor];
        _optionTitleLabel.font = [UIFont fontWithName:@"PingFang SC" size:16];
        _optionTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _optionTitleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        @weakify(self)
        [tap.rac_gestureSignal subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            !self.optionDidPickHandler ?: self.optionDidPickHandler(self.indexPath, self.optionTitleLabel.text);
        }];
        [_optionTitleLabel addGestureRecognizer:tap];
    }
    return _optionTitleLabel;
}

#pragma mark - private
- (void)layoutPageSubviews {
    [self.contentView addSubview:self.optionTitleLabel];
    [self.optionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

@end
