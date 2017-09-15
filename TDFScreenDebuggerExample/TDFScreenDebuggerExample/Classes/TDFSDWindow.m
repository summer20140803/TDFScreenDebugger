//
//  TDFSDWindow.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/12.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDWindow.h"

@implementation TDFSDWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // make the level higher than the window created by login assistant
        self.windowLevel = UIWindowLevelStatusBar + 101;
    }
    return self;
}

#if DEBUG
- (BOOL)_canBecomeKeyWindow {
    return NO;
}

- (BOOL)_canAffectStatusBarAppearance {
    return NO;
}
#endif


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL pointInside = NO;
    // notify delegate to handle touchEvent logic
    if ([self.touchEventDelegate window:self shouldHandleTouchEventWithTouchPoint:point]) {
        pointInside = [super pointInside:point withEvent:event];
    }
    // if return YES, it confirms that the window will handle this event
    return pointInside;
}

@end
