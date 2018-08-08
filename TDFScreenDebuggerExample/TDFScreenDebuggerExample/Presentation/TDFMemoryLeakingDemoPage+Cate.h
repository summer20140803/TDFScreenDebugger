//
//  UIViewController+Cate.h
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2018/8/8.
//  Copyright © 2018年 TDF. All rights reserved.
//

#import "TDFMemoryLeakingDemoPage.h"

@interface MyObject : NSObject

@end

@interface TDFMemoryLeakingDemoPage (Cate)

@property (nonatomic, strong) MyObject *obj;

@end
