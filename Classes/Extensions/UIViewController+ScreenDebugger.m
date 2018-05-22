//
//  UIViewController+ScreenDebugger.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/18.
//

#import "UIViewController+ScreenDebugger.h"

@implementation UIViewController (ScreenDebugger)

- (UIViewController *)sd_obtainTopViewController {
    if ([self isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self;
        return [[navigationController.viewControllers lastObject] sd_obtainTopViewController];
    }
    if ([self isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)self;
        return [tabController.selectedViewController sd_obtainTopViewController];
    }
    if (self.presentedViewController) {
        return [self.presentedViewController sd_obtainTopViewController];
    }
    return self;
}

@end
