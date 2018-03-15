//
//  TDFSDARCollectionViewModel.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/28.
//
//

#import "TDFSDARCollectionViewModel.h"
#import "TDFSDFullScreenConsoleController.h"
#import "NSString+ScreenDebugger.h"

@interface TDFSDARCollectionViewModel ()

@property (nonatomic, assign, readwrite) CGFloat cellHeight;
@property (nonatomic, assign, readwrite) CGFloat cellWidth;

@end

@implementation TDFSDARCollectionViewModel

- (void)setRequestModel:(TDFALRequestModel *)requestModel {
    _requestModel = requestModel;
    self.cellHeight = [self preCellHeightWithRequestModel:requestModel];
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
- (CGFloat)preCellHeightWithRequestModel:(TDFALRequestModel *)requestModel {
    
    CGFloat itemWidth = self.cellWidth;
    CGFloat validURLWidth = itemWidth - 8 * 2;
    
    CGFloat timeLabelHeight = 15;
    
    NSString *taskDescription = [requestModel.taskDescription stringByReplacingOccurrencesOfString:@"\n" withString:@""] ?: @"Not set";
    CGFloat taskDescriptionHeight = [taskDescription sd_heightForFont:[UIFont fontWithName:@"PingFang SC" size:12] size:CGSizeMake(validURLWidth, MAXFLOAT) mode:NSLineBreakByCharWrapping];
    
    NSString *validURL = [requestModel.validURL stringByReplacingOccurrencesOfString:@"\n" withString:@""] ?: @"Not set";
    CGFloat validURLHeight = [validURL sd_heightForFont:[UIFont fontWithName:@"PingFang SC" size:12] size:CGSizeMake(validURLWidth, MAXFLOAT) mode:NSLineBreakByCharWrapping];
    
    CGFloat finalHeight = 8 + timeLabelHeight + 4 + taskDescriptionHeight + 3 + validURLHeight + 8;
    
    return finalHeight;
}

@end
