//
//  TDFSDSettingOptionPickerCell.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/23.
//

#import <UIKit/UIKit.h>

@interface TDFSDSettingOptionPickerCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)bindWithOptionTitle:(NSString *)optionTitle optionDidPickHandler:(void (^)(NSIndexPath *indexPath, NSString *pickValue))optionDidPickHandler;

@end
