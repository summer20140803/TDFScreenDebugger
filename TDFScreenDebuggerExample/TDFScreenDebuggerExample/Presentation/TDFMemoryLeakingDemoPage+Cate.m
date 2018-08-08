//
//  UIViewController+Cate.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2018/8/8.
//  Copyright © 2018年 TDF. All rights reserved.
//

#import "TDFMemoryLeakingDemoPage+Cate.h"
#import <objc/runtime.h>

@implementation MyObject

@end

@implementation TDFMemoryLeakingDemoPage (Cate)

@dynamic obj;

- (MyObject *)obj {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setObj:(MyObject *)obj {
    objc_setAssociatedObject(self, @selector(obj), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
