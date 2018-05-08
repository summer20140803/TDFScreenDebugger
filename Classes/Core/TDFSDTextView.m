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
        self.primaryHighlightColor = [UIColor colorWithRed:178/255.f green:235/255.f blue:242/255.f alpha:0.35];
        self.secondaryHighlightColor = [UIColor colorWithRed: 178/255.f green:235/255.f blue:242/255.f alpha:0.15];
    }
    return self;
}

@end
