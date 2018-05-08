//
//  TDFSDAsyncDisplayLabel.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/18.
//

#import "TDFSDAsyncDisplayLabel.h"
#import "TDFSDQueueDispatcher.h"
#import <CoreText/CoreText.h>

@interface TDFSDAsyncDisplayLabel ()

@end

@implementation TDFSDAsyncDisplayLabel

#pragma mark - override methods
- (void)setText:(NSString *)text {
    if ([NSThread isMainThread]) {
        NSMutableParagraphStyle * style = [NSMutableParagraphStyle new];
        style.alignment = self.textAlignment;
        NSAttributedString *as_text = [[NSAttributedString alloc] initWithString:text attributes:
                                       @{ NSFontAttributeName : self.font,
                                          NSForegroundColorAttributeName : self.textColor,
                                          NSParagraphStyleAttributeName : style }];
        CGSize size = self.bounds.size;
        sd_dispatch_async_by_qos_background(^{
            [self displayFrameImageWithSize:size as:as_text];
        });
    } else {
        sd_dispatch_async_to_main_queue(^{
            NSMutableParagraphStyle * style = [NSMutableParagraphStyle new];
            style.alignment = self.textAlignment;
            NSAttributedString *as_text = [[NSAttributedString alloc] initWithString:text attributes:
                                           @{ NSFontAttributeName : self.font,
                                              NSForegroundColorAttributeName : self.textColor,
                                              NSParagraphStyleAttributeName : style }];
            CGSize size = self.bounds.size;
            sd_dispatch_async_by_qos_background(^{
                [self displayFrameImageWithSize:size as:as_text];
            });
        });
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if ([NSThread isMainThread]) {
        CGSize size = self.bounds.size;
        sd_dispatch_async_by_qos_background(^{
            [self displayFrameImageWithSize:size as:attributedText];
        });
    } else {
        sd_dispatch_async_to_main_queue(^{
            CGSize size = self.bounds.size;
            sd_dispatch_async_by_qos_background(^{
                [self displayFrameImageWithSize:size as:attributedText];
            });
        });
    }
}

#pragma mark - private
- (void)displayFrameImageWithSize:(CGSize)size as:(NSAttributedString *)as {
    if (!as) return;
    
//    size.height += 10;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context != NULL) {
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        
        CGSize textSize = [as boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    
        textSize.width = ceil(textSize.width);
        textSize.height = ceil(textSize.height);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake((size.width - textSize.width) / 2, 0, textSize.width, textSize.height));
        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)as);
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, as.length), path, NULL);
        CTFrameDraw(frame, context);
        
        UIImage * contents = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CFRelease(frameSetter);
        CFRelease(frame);
        CFRelease(path);
        
        sd_dispatch_async_to_main_queue(^{
            self.layer.contents = (id)contents.CGImage;
        });
    }
}

@end
