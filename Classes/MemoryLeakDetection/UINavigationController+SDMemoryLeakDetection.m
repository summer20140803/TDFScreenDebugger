//
//  UINavigationController+SDMemoryLeakDetection.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/16.
//

#import "UINavigationController+SDMemoryLeakDetection.h"
#import "NSObject+SDMemoryLeakDetection.h"
#import <objc/runtime.h>

@implementation UINavigationController (SDMemoryLeakDetection)

+ (void)prepareForDetection {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        Method originalMethod = class_getInstanceMethod(class, @selector(pushViewController:animated:));
        Method swizzledMethod = class_getInstanceMethod(class, @selector(sd_mld_pushViewController:animated:));
        
        BOOL didAddMethod = \
        class_addMethod(class,
                        @selector(pushViewController:animated:),
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                @selector(sd_mld_pushViewController:animated:),
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        }
        else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)sd_mld_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self sd_mld_pushViewController:viewController animated:animated];
    [viewController bindWithProxy];
}

@end
