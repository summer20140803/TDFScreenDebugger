//
//  NSString+ScreenDebugger.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/28.
//
//

#import "NSString+ScreenDebugger.h"

@implementation NSString (ScreenDebugger)

- (CGFloat)sd_heightForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGFloat height;
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        height = rect.size.height;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        height = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode].height;
#pragma clang diagnostic pop
    }
    return height;
}

@end
