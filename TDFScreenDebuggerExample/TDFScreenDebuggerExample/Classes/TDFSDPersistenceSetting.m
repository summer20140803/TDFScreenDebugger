//
//  TDFSDPersistenceSetting.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/17.
//
//

#import "TDFSDPersistenceSetting.h"

@implementation TDFSDPersistenceSetting

static TDFSDPersistenceSetting *setting = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        setting = [[self alloc] init];
    });
    return setting;
}

@end
