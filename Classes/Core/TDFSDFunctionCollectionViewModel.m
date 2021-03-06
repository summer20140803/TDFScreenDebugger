//
//  TDFSDFunctionCollectionViewModel.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/26.
//
//

#import "TDFSDFunctionCollectionViewModel.h"
#import "TDFSDFullScreenConsoleController.h"
#import "NSString+ScreenDebugger.h"
#import "TDFScreenDebuggerDefine.h"

#import "TDFSDAPIRecordConsoleController.h"
#import "TDFSDAPIRecordSelectableController.h"
#import "TDFSDLogViewController.h"
#import "TDFSDCrashCaptureHistoryController.h"
#import "TDFSDDeveloperGuideController.h"
#import "TDFSDAboutFutureController.h"
#import "TDFSDFunctionPageController.h"

@interface TDFSDFunctionCollectionViewModel ()

@property (nonatomic, assign, readwrite) CGFloat cellHeight;
@property (nonatomic, assign, readwrite) CGFloat cellWidth;

@end

@implementation TDFSDFunctionCollectionViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        @weakify(self)
        self.jumpCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            UIViewController<UIViewControllerTransitioningDelegate> *current = input;
            UIViewController *target = nil;
            
            switch (self.function.index) {
                case 0: target = [[TDFSDAPIRecordConsoleController alloc] init]; break;
                case 1: target = [[TDFSDAPIRecordSelectableController alloc] init]; break;
                case 2: target = [[TDFSDLogViewController alloc] init]; break;
                case 4: target = [[TDFSDCrashCaptureHistoryController alloc] init]; break;
                case 8: target = [[TDFSDDeveloperGuideController alloc] init]; break;
                default: {
                    if (self.function.index == 3 || self.function.index == 5 || self.function.index == 6) {
                        target = [[TDFSDFunctionPageController alloc] init];
                        [(TDFSDFunctionPageController *)target setFunctionModel:self.function];
                    } else {
                        target = [[TDFSDAboutFutureController alloc] init]; break;
                    }
                }
            }
            
            if (current && target) {
                target.transitioningDelegate = current;
                [current presentViewController:target animated:YES completion:nil];
            }
            return [RACSignal empty];
        }];
    }
    return self;
}

- (void)setFunction:(TDFSDFunctionModel *)function {
    _function = function;
    self.cellHeight = [self preCellHeightWithFunction:function];
}

- (CGFloat)cellWidth {
    if (_cellWidth == 0) {
        CGFloat itemCollectionEdgeMargin = 15;
        if ([@([UIScreen mainScreen].bounds.size.width) intValue] % 2 == 0) {
            _cellWidth = [UIScreen mainScreen].bounds.size.width - 2 * SDFullScreenContentViewEdgeMargin - itemCollectionEdgeMargin * 2;
        } else {
            _cellWidth = [UIScreen mainScreen].bounds.size.width - 2 * SDFullScreenContentViewEdgeMargin - itemCollectionEdgeMargin * 2 - SDFullScreenContentViewDynamicAnimatorFixedOffset;
        }
    }
    return _cellWidth;
}

#pragma mark - private
- (CGFloat)preCellHeightWithFunction:(TDFSDFunctionModel *)function {
    
    CGFloat itemWidth = self.cellWidth;
    CGFloat descriptionWidth = itemWidth - 12 - 40 - 15 - 8;
    
    CGFloat nameHeight = 15;
    CGFloat descriptionHeight = [function.functionDescription sd_heightForFont:[UIFont fontWithName:@"PingFang SC" size:12] size:CGSizeMake(descriptionWidth, MAXFLOAT) mode:NSLineBreakByWordWrapping];
    CGFloat quickLaunchDesHeight = 15;
    
    CGFloat finalHeight = 10 + nameHeight + 6 + descriptionHeight + 6 + quickLaunchDesHeight + 5;
    
    return finalHeight;
}


@end

