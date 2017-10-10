//
//  TDFSDLVLogModel.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/5.
//

#import "TDFSDLVLogModel.h"
#import <objc/runtime.h>

@implementation TDFSDLVLogModel

- (NSString *)description {
    return [NSString stringWithFormat:@"\n[%@]\n%@\n", self.time, self.message];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"\n[%@]\n%@\n", self.time, self.message];
}

#pragma mark - TDFSDMessageRemindProtocol
- (BOOL)messageIsRead {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setMessageRead:(BOOL)messageRead {
    objc_setAssociatedObject(self, @selector(messageIsRead), @(messageRead), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
