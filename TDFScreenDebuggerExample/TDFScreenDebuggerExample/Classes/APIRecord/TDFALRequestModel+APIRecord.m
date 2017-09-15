//
//  TDFALRequestModel+APIRecord.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/15.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFALRequestModel+APIRecord.h"
@import UIKit;

@implementation TDFALRequestModel (APIRecord)

- (NSAttributedString *)outputCharacterizationString {
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:self.selfDescription];
    NSRange allRange = NSMakeRange(0, self.selfDescription.length);
    UIColor *color = [UIColor whiteColor];
    [mutableString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:12], NSForegroundColorAttributeName:color} range:allRange];
    return [mutableString copy];
}

@end
