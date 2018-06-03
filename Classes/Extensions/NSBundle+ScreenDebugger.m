//
//  NSBundle+ScreenDebugger.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/31.
//

#import "NSBundle+ScreenDebugger.h"

@implementation NSBundle (ScreenDebugger)

- (BOOL)isAppleClassesBundle {
    NSString *non_dynamic_library_bundle_path = [[NSBundle mainBundle] bundlePath];
    NSString *dynamic_library_bundle_path_prefix = [non_dynamic_library_bundle_path stringByAppendingPathComponent:@"Frameworks"];
    return !([[self bundlePath] isEqualToString:non_dynamic_library_bundle_path] || [[self bundlePath] hasPrefix:dynamic_library_bundle_path_prefix]);
}

@end
