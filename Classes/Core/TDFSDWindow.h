//
//  TDFSDWindow.h
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/12.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TDFSDWindow;

@protocol TDFSDWindowDelegate <NSObject>

- (BOOL)window:(TDFSDWindow *)window shouldHandleTouchEventWithTouchPoint:(CGPoint)touchPoint;
- (BOOL)canBecomeKeyWindow:(TDFSDWindow *)window;

@end

@interface TDFSDWindow : UIWindow

@property (nonatomic, weak) id<TDFSDWindowDelegate> sd_delegate;

@end
