//
//  TDFSDThumbnailView.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/12.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDThumbnailView.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDThumbnailView ()

@property (nonatomic, strong) UIImageView *thumbnailIconView;
@property (nonatomic, strong) UILabel     *unreadTaskCountLabel;

@end

@implementation TDFSDThumbnailView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self layoutPageSubviews];
        [self addTapGesture];
        [self addLongPressGesture];
        [self addTextObserver];
        _unreadTaskCountLabel.text = @"99+";
    }
    return self;
}

#pragma mark - getter
- (UIImageView *)thumbnailIconView {
    if (!_thumbnailIconView) {
        UIImage *thumbnailIcon = [UIImage imageNamed:@"icon_screenDebugger_thumbnail"];
        _thumbnailIconView = [[UIImageView alloc] initWithImage:thumbnailIcon];
        _thumbnailIconView.contentMode = UIViewContentModeScaleToFill;
    }
    return _thumbnailIconView;
}

- (UILabel *)unreadTaskCountLabel {
    if (!_unreadTaskCountLabel) {
        _unreadTaskCountLabel = [[UILabel alloc] init];
        [_unreadTaskCountLabel setBackgroundColor:[UIColor colorWithRed:241/255.f green:56/255.f blue:56/255.f alpha:1]];
        _unreadTaskCountLabel.textAlignment = NSTextAlignmentCenter;
        _unreadTaskCountLabel.numberOfLines = 1;
        _unreadTaskCountLabel.textColor = [UIColor whiteColor];
        _unreadTaskCountLabel.font = [UIFont boldSystemFontOfSize:11];
        _unreadTaskCountLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _unreadTaskCountLabel.layer.cornerRadius = 7;
        _unreadTaskCountLabel.layer.masksToBounds = YES;
    }
    return _unreadTaskCountLabel;
}

#pragma mark - event
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint curTouchPoint = [touch locationInView:self];
    CGPoint preTouchPoint = [touch previousLocationInView:self];
    
    CGFloat finalX = self.frame.origin.x + curTouchPoint.x - preTouchPoint.x;
    CGFloat finalY = self.frame.origin.y + curTouchPoint.y - preTouchPoint.y;
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.superview).with.offset(finalX);
        make.top.equalTo(self.superview).with.offset(finalY);
    }];
    
    [self.superview layoutIfNeeded];
}

#pragma mark - private
- (void)layoutPageSubviews {
    [self addSubview:self.thumbnailIconView];
    [self addSubview:self.unreadTaskCountLabel];
    [self.thumbnailIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.unreadTaskCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_right).with.offset(-2);
        make.centerY.equalTo(self.mas_top).with.offset(3);
        make.height.equalTo(@14);
        make.width.greaterThanOrEqualTo(@14);
    }];
}

- (void)addTapGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    @weakify(self)
    [tapGesture.rac_gestureSignal subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self)
        !self.tapProxy ?: [self.tapProxy sendNext:nil];
    }];
    [self addGestureRecognizer:tapGesture];
}

- (void)addLongPressGesture {
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] init];
    longPressGesture.minimumPressDuration = 1;
    @weakify(self)
    [longPressGesture.rac_gestureSignal
    subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self)
        !self.longPressProxy ?: [self.longPressProxy sendNext:nil];
    }];
    [self addGestureRecognizer:longPressGesture];
}

- (void)addTextObserver {
    [RACObserve(self.unreadTaskCountLabel, text) subscribeNext:^(NSString * _Nullable newText) {
        if (newText && newText.length) {
            self.unreadTaskCountLabel.hidden = NO;
            CGSize fitSize = [self.unreadTaskCountLabel sizeThatFits:CGSizeZero];
            CGFloat fitWidth = fitSize.width < 14 ? 14 : fitSize.width + 4;
            [self.unreadTaskCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(fitWidth));
            }];
        } else {
            self.unreadTaskCountLabel.hidden = YES;
        }
    }];
}


@end
