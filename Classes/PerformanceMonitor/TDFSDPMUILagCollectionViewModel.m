//
//  TDFSDPMUILagCollectionViewModel.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/29.
//

#import "TDFSDPMUILagCollectionViewModel.h"
#import "TDFSDFullScreenConsoleController.h"
#import "NSString+ScreenDebugger.h"

static const CGFloat kSDPMUILagCollectionCellHeight   =  30.0f;

@interface TDFSDPMUILagCollectionViewModel ()

@property (nonatomic, assign, readwrite) CGFloat cellHeight;
@property (nonatomic, assign, readwrite) CGFloat cellWidth;

@end

@implementation TDFSDPMUILagCollectionViewModel

- (void)setLagModel:(TDFSDPMUILagComponentModel *)lagModel {
    _lagModel = lagModel;
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

- (CGFloat)cellHeight {
    return kSDPMUILagCollectionCellHeight;
}

@end
