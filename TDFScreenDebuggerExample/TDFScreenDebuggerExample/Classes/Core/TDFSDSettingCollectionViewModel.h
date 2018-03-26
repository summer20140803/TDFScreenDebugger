//
//  TDFSDSettingCollectionViewModel.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/20.
//

#import <Foundation/Foundation.h>

@interface TDFSDSettingCollectionViewModel : NSObject

@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, assign, readonly) CGFloat cellWidth;
@property (nonatomic, assign, readonly) NSUInteger type;
@property (nonatomic, copy, readonly) NSString *settingTitle;
@property (nonatomic, copy, readonly) NSString *settingDescription;

@property (nonatomic, strong, readonly) NSArray<NSString *> *optionalValues;  // not be nil just when type == SDSettingEditTypeOptionPicker

- (instancetype)initWithSettingDictionary:(NSDictionary *)settingDictionary;

@end
