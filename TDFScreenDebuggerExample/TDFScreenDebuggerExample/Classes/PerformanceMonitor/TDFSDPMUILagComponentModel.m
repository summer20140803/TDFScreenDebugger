//
//  TDFSDPMUILagComponentModel.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/13.
//

#import "TDFSDPMUILagComponentModel.h"
#import <objc/runtime.h>

@implementation TDFSDPMUILagComponentModel

- (NSString *)description {
    return self.callStackInfo;
}

- (BOOL)isEqual:(id)object {
    return [self.description isEqualToString:object];
}

#pragma mark - TDFSDMessageRemindProtocol
- (BOOL)messageIsRead {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setMessageRead:(BOOL)messageRead {
    objc_setAssociatedObject(self, @selector(messageIsRead), @(messageRead), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
