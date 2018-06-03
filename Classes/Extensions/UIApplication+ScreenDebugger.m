//
//  UIApplication+ScreenDebugger.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/6/2.
//

#import "UIApplication+ScreenDebugger.h"
#import <objc/runtime.h>

@implementation UIApplication (ScreenDebugger)

#if DEBUG
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self sd_siwzzleMethodIMPWithOriginSEL:@selector(motionBegan:withEvent:) newSEL:@selector(sd_motionBegan:withEvent:)];
    });
}

+ (void)sd_siwzzleMethodIMPWithOriginSEL:(SEL)originSEL newSEL:(SEL)newSEL {
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

- (void)sd_motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [self sd_motionBegan:motion withEvent:event];
}
#endif

@end
