//
//  UIView+ScreenDebugger.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/29.
//
//

#import "UIView+ScreenDebugger.h"

@implementation UIView (ScreenDebugger)

- (void)sd_fadeAnimation {
    
    CATransition *animation = [CATransition animation];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    animation.type = kCATransitionFade;
    animation.duration = 0.15f;
    
    [self.layer addAnimation:animation forKey:nil];
}

@end
