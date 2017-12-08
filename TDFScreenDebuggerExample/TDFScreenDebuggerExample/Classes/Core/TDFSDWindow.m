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
        // make the level higher than alerts presented by system
        self.windowLevel = UIWindowLevelAlert + 101;
    }
    return self;
}

#if DEBUG
- (BOOL)_canBecomeKeyWindow {
    return [self.sd_delegate canBecomeKeyWindow:self];
}

- (BOOL)_canAffectStatusBarAppearance {
    return [self isKeyWindow];
}
#endif


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL pointInside = NO;
    // notify delegate to handle touchEvent logic
    if ([self.sd_delegate window:self shouldHandleTouchEventWithTouchPoint:point]) {
        pointInside = [super pointInside:point withEvent:event];
    }
    // if return YES, it confirms that the window will handle this event
    return pointInside;
}

@end
