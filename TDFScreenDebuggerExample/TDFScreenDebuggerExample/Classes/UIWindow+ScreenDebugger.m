//
//  UIWindow+ScreenDebugger.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/13.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "UIWindow+ScreenDebugger.h"
#import "TDFSDManager.h"

@implementation UIWindow (ScreenDebugger)

#if DEBUG
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    [super motionBegan:motion withEvent:event];
    
    if ([TDFSDManager manager].debuggerHidden) {
        [[TDFSDManager manager] showDebugger];
    } else {
        [[TDFSDManager manager] hideDebugger];
    }
}
#endif

@end
