//
//  UIView+SDMemoryLeakDetection.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/16.
//

#import "UIView+SDMemoryLeakDetection.h"
#import "NSObject+SDMemoryLeakDetection.h"
#import "TDFSDMLDGeneralizedProxy.h"
#import <objc/runtime.h>

@implementation UIView (SDMemoryLeakDetection)

+ (void)prepareForDetection {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        Method originalMethod = class_getInstanceMethod(class, @selector(didMoveToSuperview));
        Method swizzledMethod = class_getInstanceMethod(class, @selector(sd_mld_didMoveToSuperview));
        
        BOOL didAddMethod = \
        class_addMethod(class,
                        @selector(didMoveToSuperview),
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                @selector(sd_mld_didMoveToSuperview),
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        }
        else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)sd_mld_didMoveToSuperview {
    [self sd_mld_didMoveToSuperview];
    [self bindWithProxy];
}

- (BOOL)isSuspiciousLeaker {
    BOOL isSuspicious = YES;
    
    BOOL isOnUIStack = NO;
    UIView *view = self;
    while (view.superview) {
        view = view.superview;
    }
    if ([view isKindOfClass:[UIWindow class]]) {
        isOnUIStack = YES;
        isSuspicious = NO;
    }
    
    if (self.mld_proxy.weakResponder == nil) {
        UIResponder *responder = self.nextResponder;
        while (responder) {
            if (responder.nextResponder == nil) {
                break;
            }
            else {
                responder = responder.nextResponder;
            }
            if ([responder isKindOfClass:[UIViewController class]]) {
                UIViewController *vc = (UIViewController *)responder;
                self.mld_proxy.weakResponder = vc;
                self.mld_proxy.weakViewControllerOwnerClassName = NSStringFromClass([vc class]);
                self.mld_proxy.weakViewControllerOwnerTitle = vc.title;
                break;
            }
        }
    }
    
    if (isOnUIStack == NO) {
        isSuspicious = YES;
    }
    if ([self.mld_proxy.weakResponder isKindOfClass:[UIViewController class]]) {
        isSuspicious = NO;
    }
    
    return isSuspicious;
}

@end
