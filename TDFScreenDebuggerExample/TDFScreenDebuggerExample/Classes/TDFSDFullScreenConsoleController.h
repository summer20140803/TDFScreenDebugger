//
//  TDFSDFullScreenConsoleController.h
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/13.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDFScreenDebuggerDefine.h"

@class TDFSDFunctionMenuItem;
@protocol TDFSDFullScreenConsoleControllerInheritProtocol <NSObject>

@required
- (NSString *)titleForFullScreenConsole;
- (__kindof UIView *)contentViewForFullScreenConsole;

@optional
- (NSArray<TDFSDFunctionMenuItem *> *)functionMenuItemsForFullScreenConsole;

@end

CF_EXPORT const CGFloat kSDFullScreenContentViewEdgeMargin;

@interface TDFSDFullScreenConsoleController : UIViewController <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong, readonly) UIView *container;
@property (nonatomic, strong, readonly) NSArray<TDFSDFunctionMenuItem *> *menuItems;

- (void)sendClearRemindLabelTextRequestWithContentType:(SDAllReadNotificationContentType)contentType;

@end


@interface TDFSDFunctionMenuItem : UIButton

+ (instancetype)itemWithImage:(UIImage *)image actionHandler:(void (^)(TDFSDFunctionMenuItem *item))actionHandler;

@end
