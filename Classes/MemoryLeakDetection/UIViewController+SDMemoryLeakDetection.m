//
//  UIViewController+SDMemoryLeakDetection.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/16.
//

#import "UIViewController+SDMemoryLeakDetection.h"
#import "NSObject+SDMemoryLeakDetection.h"
#import <objc/runtime.h>

@implementation UIViewController (SDMemoryLeakDetection)

+ (void)prepareForDetection {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self sd_mld_siwzzleMethodIMPWithOriginSEL:@selector(presentViewController:animated:completion:) newSEL:@selector(sd_mld_presentViewController:animated:completion:)];
        [self sd_mld_siwzzleMethodIMPWithOriginSEL:@selector(viewDidAppear:) newSEL:@selector(sd_mld_viewDidAppear:)];
    });
}

- (void)sd_mld_presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion {
    [self sd_mld_presentViewController:viewControllerToPresent animated:flag completion:completion];
    [viewControllerToPresent bindWithProxy];
}

- (void)sd_mld_viewDidAppear:(BOOL)animated {
    [self sd_mld_viewDidAppear:animated];
    [self trackAllStrongPropsLeaks];
}

- (BOOL)isSuspiciousLeaker {
    BOOL isSuspicious = NO;
    
    // if a vc's view is added to other vc's view, it's also ok
    BOOL visibleOnScreen = NO;
    UIView *view = self.view;
    while (view.superview != nil) {
        view = view.superview;
    }
    if ([view isKindOfClass:[UIWindow class]]) {
        visibleOnScreen = YES;
    }
    
    BOOL isOnVCStack = NO;
    if (self.navigationController != nil || self.presentingViewController != nil || self == [UIApplication sharedApplication].keyWindow.rootViewController) {
        isOnVCStack = YES;
    }
    
    if (visibleOnScreen == NO && isOnVCStack == NO) {
        isSuspicious = YES;
    }
    
    return isSuspicious;
}

+ (void)sd_mld_siwzzleMethodIMPWithOriginSEL:(SEL)originSEL newSEL:(SEL)newSEL {
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originSEL);
    Method swizzledMethod = class_getInstanceMethod(class, newSEL);
    
    BOOL didAddMethod = \
    class_addMethod(class,
                    originSEL,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            newSEL,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
