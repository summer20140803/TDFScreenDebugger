//
//  TDFSDSettingCollectionViewModel.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/20.
//

#import "TDFSDSettingCollectionViewModel.h"
#import "TDFSDFullScreenConsoleController.h"
#import "NSString+ScreenDebugger.h"

@interface TDFSDSettingCollectionViewModel ()

@property (nonatomic, assign, readwrite) CGFloat cellHeight;
@property (nonatomic, assign, readwrite) CGFloat cellWidth;
@property (nonatomic,   copy, readwrite) NSString *settingTitle;
@property (nonatomic,   copy, readwrite) NSString *settingDescription;
@property (nonatomic, assign, readwrite) NSUInteger type;

@end

@implementation TDFSDSettingCollectionViewModel

- (instancetype)initWithSettingDictionary:(NSDictionary *)settingDictionary {
    if (self = [super init]) {
        _settingTitle = settingDictionary[@"title"];
        _settingDescription = settingDictionary[@"description"];
        _type = [settingDictionary[@"type"] unsignedIntegerValue];
        _optionalValues = settingDictionary[@"options"];
        _cellHeight = [self preCellHeight];
    }
    return self;
}

- (CGFloat)cellWidth {
    if (_cellWidth == 0) {
        CGFloat itemCollectionEdgeMargin = 5;
        if ([@([UIScreen mainScreen].bounds.size.width) intValue] % 2 == 0) {
            _cellWidth = [UIScreen mainScreen].bounds.size.width - 2 * SDFullScreenContentViewEdgeMargin - itemCollectionEdgeMargin * 2;
        } else {
            _cellWidth = [UIScreen mainScreen].bounds.size.width - 2 * SDFullScreenContentViewEdgeMargin - itemCollectionEdgeMargin * 2 - SDFullScreenContentViewDynamicAnimatorFixedOffset;
        }
    }
    return _cellWidth;
}

#pragma mark - private
- (CGFloat)preCellHeight {
    
    CGFloat itemWidth = self.cellWidth;
    CGFloat descriptionWidth = itemWidth-11*2;
    
    CGFloat titleHeight = 40;
    CGFloat descriptionHeight = [self.settingDescription sd_heightForFont:[UIFont fontWithName:@"PingFang SC" size:12] size:CGSizeMake(descriptionWidth, MAXFLOAT) mode:NSLineBreakByWordWrapping];
    
    CGFloat finalHeight = titleHeight + descriptionHeight + 20;
    
    return finalHeight;
}

@end
