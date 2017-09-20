//
//  TDFSDTextView.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/20.
//
//

#import "TDFSDTextView.h"

@implementation TDFSDTextView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.editable = NO;
        self.selectable = YES;
        self.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        self.allowsEditingTextAttributes = YES;
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = NO;
        // avoid the system auto scroll
        self.layoutManager.allowsNonContiguousLayout = NO;
        // ICTextView props
        self.circularSearch = YES;
        self.scrollPosition = ICTextViewScrollPositionMiddle;
        self.searchOptions = NSRegularExpressionCaseInsensitive;
        self.primaryHighlightColor = [UIColor colorWithRed:255/255.f green:249/255.f blue:196/255.f alpha:0.6];
        self.secondaryHighlightColor = [UIColor colorWithRed: 255/255.f green:249/255.f blue:196/255.f alpha:0.2];
    }
    return self;
}

@end
