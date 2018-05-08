//
//  NSString+ScreenDebugger.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/28.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface NSString (ScreenDebugger)

- (CGFloat)sd_heightForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

@end
