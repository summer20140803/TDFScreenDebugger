//
//  TDFSDFullScreenConsoleController.h
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/13.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TDFSDFunctionMenuItem;
@protocol TDFSDFullScreenConsoleControllerInheritProtocol <NSObject>

@required
- (NSString *)titleForFullScreenConsole;
- (__kindof UIView *)contentViewForFullScreenConsole;

@optional
- (NSArray<TDFSDFunctionMenuItem *> *)fuctionMenuItemsForFullScreenConsole;

@end

@interface TDFSDFullScreenConsoleController : UIViewController

@property (nonatomic, strong, readonly) UIView *container;

@end


@interface TDFSDFunctionMenuItem : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy) void (^actionHandler)(TDFSDFunctionMenuItem *item);

+ (instancetype)itemWithTitle:(NSString *)title image:(UIImage *)image;
+ (instancetype)itemWithTitle:(NSString *)title image:(UIImage *)image actionHandler:(void (^)(TDFSDFunctionMenuItem *item))actionHandler;

@end
