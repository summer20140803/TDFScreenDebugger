//
//  TDFSDFullScreenConsoleController.h
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/13.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TDFSDFullScreenConsoleControllerInheritProtocol <NSObject>

@required
- (NSString *)titleForFullScreenConsole;
- (__kindof UIView *)contentViewForFullScreenConsole;

@end

@interface TDFSDFullScreenConsoleController : UIViewController 

@end
