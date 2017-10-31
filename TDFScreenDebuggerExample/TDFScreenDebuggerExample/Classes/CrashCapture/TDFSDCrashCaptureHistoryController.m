//
//  TDFSDCrashCaptureHistoryController.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/16.
//

#import "TDFSDCrashCaptureHistoryController.h"
#import "TDFSDCrashCaptor.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface TDFSDCrashCaptureHistoryController () <TDFSDFullScreenConsoleControllerInheritProtocol>

@end

@implementation TDFSDCrashCaptureHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *cachePath = SD_CRASH_CAPTOR_CACHE_MODEL_ARCHIVE_PATH;
    NSMutableArray *cacheCrashModels = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    NSLog(@"%@", cacheCrashModels);
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"Crash History";
}

- (UIView *)contentViewForFullScreenConsole {
    return [[UIView alloc] init];
}

- (NSArray<TDFSDFunctionMenuItem *> *)functionMenuItemsForFullScreenConsole {
    if (!self.menuItems) {
        return @[ [TDFSDFunctionMenuItem itemWithImage:[UIImage imageNamed:@"icon_screenDebugger_trash"]
                      actionHandler:^(TDFSDFunctionMenuItem *item) {
                          [[TDFSDCrashCaptor sharedInstance] clearHistoryCrashLog];
                      }] ];
    }
    return self.menuItems;
}

@end
