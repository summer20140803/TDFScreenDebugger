//
//  TDFSDCCCollectionViewModel.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/31.
//

#import "TDFSDCCCollectionViewModel.h"
#import "TDFSDFullScreenConsoleController.h"
#import "NSString+ScreenDebugger.h"

@interface TDFSDCCCollectionViewModel ()

@property (nonatomic, assign, readwrite) CGFloat cellHeight;
@property (nonatomic, assign, readwrite) CGFloat cellWidth;

@end

@implementation TDFSDCCCollectionViewModel

- (void)setCrashModel:(TDFSDCCCrashModel *)crashModel {
    _crashModel = crashModel;
    self.cellHeight = [self preCellHeightWithCrashModel:crashModel];
}

- (CGFloat)cellWidth {
    if (_cellWidth == 0) {
        CGFloat itemCollectionEdgeMargin = 8;
        if ([@([UIScreen mainScreen].bounds.size.width) intValue] % 2 == 0) {
            _cellWidth = [UIScreen mainScreen].bounds.size.width - 2 * SDFullScreenContentViewEdgeMargin - itemCollectionEdgeMargin * 2;
        } else {
            _cellWidth = [UIScreen mainScreen].bounds.size.width - 2 * SDFullScreenContentViewEdgeMargin - itemCollectionEdgeMargin * 2 - SDFullScreenContentViewDynamicAnimatorFixedOffset;
        }
    }
    return _cellWidth;
}

#pragma mark - private
- (CGFloat)preCellHeightWithCrashModel:(TDFSDCCCrashModel *)crashModel {
    
    CGFloat itemWidth = self.cellWidth;
    CGFloat validURLWidth = itemWidth - 8 * 2;
    
    CGFloat timeLabelHeight = 15;
    
    CGFloat exceptionNameHeight = [crashModel.exceptionName sd_heightForFont:[UIFont fontWithName:@"PingFang SC" size:12] size:CGSizeMake(validURLWidth, MAXFLOAT) mode:NSLineBreakByCharWrapping];
    
    CGFloat exceptionReasonHeight = [crashModel.exceptionReason sd_heightForFont:[UIFont fontWithName:@"PingFang SC" size:12] size:CGSizeMake(validURLWidth, MAXFLOAT) mode:NSLineBreakByCharWrapping];
    
    CGFloat finalHeight = 8 + timeLabelHeight + 4 + exceptionNameHeight + 3 + exceptionReasonHeight + 8;
    
    return finalHeight;
}

@end
