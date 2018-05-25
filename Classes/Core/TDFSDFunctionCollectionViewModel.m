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
                    NSString *pageTitle = [self functionPageTitleWithIndex:self.function.index];
                    if (pageTitle) {
                        target = [[TDFSDFunctionPageController alloc] init];
                        NSAttributedString *pageContent = [self functionPageContentWithIndex:self.function.index];
                        [(TDFSDFunctionPageController *)target setPageTitle:pageTitle];
                        [(TDFSDFunctionPageController *)target setPageContent:pageContent];
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

- (NSString *)functionPageTitleWithIndex:(NSUInteger)functionIndex {
    switch (functionIndex) {
        case 3: return @"Performance Monitor"; break;
        case 5: return @"MemoryLeak Detector"; break;
        case 6: return @"WildPointer Checker"; break;
    }
    return nil;
}

- (NSAttributedString *)functionPageContentWithIndex:(NSUInteger)functionIndex {
    NSMutableAttributedString *mutablePageContent = [[NSMutableAttributedString alloc] initWithString:@""];
    NSString *frontPageContent;
    NSString *settingParamsIntro = @"The follwing params could be setted by developers\n\n";;
    NSString *paramsDetail;
    
    switch (functionIndex) {
        case 3: {
            frontPageContent = @"\n\tThis is a tool which can monitor the main thread and find out some caton nodes will correspond to the stack trace feedback to the developers, it can also monitor app CPU/Memory usage, detecting current UI FPS and more performance data for developers.\n\n";
            NSString *par1 = @" • allowUILagsMonitoring";
            NSString *par2 = @" • tolerableLagThreshold";
            NSString *par3 = @" • allowApplicationCPUMonitoring";
            NSString *par4 = @" • allowApplicationMemoryMonitoring";
            NSString *par5 = @" • allowScreenFPSMonitoring";
            NSString *par6 = @" • fpsWarnningThreshold";
            paramsDetail = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@", par1, par2, par3, par4, par5, par6];
        } break;
        case 5: {
            frontPageContent = @"\n\tThis is a tool which can help developer to find out some suspicious memory leak points in project, it will loop through all strongly referenced nodes of each controller, but does not include objects that may be singletons, then give developers friendly tips for some suspicious leakers.\n\n";
            NSString *par1 = @" • allowMemoryLeaksDetectionFlag";
            NSString *par2 = @" • memoryLeakingWarningType";
            paramsDetail = [NSString stringWithFormat:@"%@\n%@", par1, par2];
        } break;
        case 6: {
            frontPageContent = @"\n\tThis is a tool which can help developer to find out some wild pointer errors in project. However, turning on checking will cause a continuous increase in memory usage, so this feature will be reset to the off state when the application is killed by default.\n\n";
            NSString *par1 = @" • allowWildPointerMonitoring";
            NSString *par2 = @" • maxZombiePoolCapacity";
            paramsDetail = [NSString stringWithFormat:@"%@\n%@", par1, par2];
        } break;
    }
    
    NSDictionary *frontAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:16], NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSDictionary *introAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:14], NSForegroundColorAttributeName:[UIColor yellowColor]};
    NSDictionary *paramsAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size:16], NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSAttributedString *frontAS = [[NSAttributedString alloc] initWithString:frontPageContent attributes:frontAttributes];
    NSAttributedString *introAS = [[NSAttributedString alloc] initWithString:settingParamsIntro attributes:introAttributes];
    NSAttributedString *paramsAS = [[NSAttributedString alloc] initWithString:paramsDetail attributes:paramsAttributes];
    [mutablePageContent appendAttributedString:frontAS];
    [mutablePageContent appendAttributedString:introAS];
    [mutablePageContent appendAttributedString:paramsAS];
    
    return [mutablePageContent copy];
}

@end

