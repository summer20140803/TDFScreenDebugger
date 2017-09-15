//
//  TDFALResponseModel+APIRecord.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/15.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFALResponseModel+APIRecord.h"
@import UIKit;

@implementation TDFALResponseModel (APIRecord)

- (NSAttributedString *)outputCharacterizationString {
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:self.selfDescription];
    NSRange allRange = NSMakeRange(0, self.selfDescription.length);
    UIColor *color;
    if (self.response) {
        color = [UIColor greenColor];
    } else if (self.error) {
        color = [UIColor redColor];
    }
    [mutableString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:12], NSForegroundColorAttributeName:color} range:allRange];
    return [mutableString copy];
}

@end
