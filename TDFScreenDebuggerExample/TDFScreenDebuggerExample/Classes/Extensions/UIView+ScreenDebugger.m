//
//  UIView+ScreenDebugger.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/29.
//
//

#import "UIView+ScreenDebugger.h"

@implementation UIView (ScreenDebugger)

- (void)sd_fadeAnimationWithDuration:(CGFloat)duration {
    
    CATransition *animation = [CATransition animation];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

    animation.type = kCATransitionFade;
    animation.duration = duration;
    
    [self.layer addAnimation:animation forKey:nil];
}

@end
