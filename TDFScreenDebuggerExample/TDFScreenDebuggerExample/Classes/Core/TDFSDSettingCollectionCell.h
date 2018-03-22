//
//  TDFSDSettingCollectionCell.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/16.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SDSettingEditType) {
    SDSettingEditTypeSwitch,
    SDSettingEditTypeOptionPicker,
};

@protocol SDSettingCollectionCellOptionPickerDelegate <NSObject>

- (void)pickerButtonDidClickWithIndexPath:(NSIndexPath *)indexPath;
- (void)switchValueDidChangeManually:(BOOL)isOn withIndexPath:(NSIndexPath *)indexPath;

@end

@interface TDFSDSettingCollectionCell : UICollectionViewCell

@property (nonatomic,   weak) id<SDSettingCollectionCellOptionPickerDelegate> optionDelegate;

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath type:(SDSettingEditType)type;

/**
 ------------------------------------------------
 |            type              ||     value    |
 ------------------------------------------------
 |   SDSettingEditTypeSwitch    || @(NO)/@(YES) |
 ------------------------------------------------
 |SDSettingEditTypeOptionPicker || @"optionXXX" |
 ------------------------------------------------
 */
- (void)renderWithTitle:(NSString *)title description:(NSString *)description settingOptionValue:(id)settingOptionValue;

@end
