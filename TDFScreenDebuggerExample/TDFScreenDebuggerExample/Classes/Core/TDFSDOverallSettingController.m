//
//  TDFSDOverallSettingController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/14.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDOverallSettingController.h"
#import "TDFSDPersistenceSetting.h"

@interface TDFSDOverallSettingController () <TDFSDFullScreenConsoleControllerInheritProtocol>

@end

@implementation TDFSDOverallSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"Debugger Settings";
}

- (UIView *)contentViewForFullScreenConsole {
    return [[UIView alloc] init];
}

@end
