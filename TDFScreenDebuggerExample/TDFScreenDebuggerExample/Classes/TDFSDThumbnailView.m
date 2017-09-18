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
#import "TDFSDPersistenceSetting.h"

@interface TDFSDMessageRemindBaseViewModel : NSObject

@property (nonatomic,   weak) UILabel *messageRemindLabelReference;
@property (nonatomic, strong) RACDisposable *disposable;

- (void)addSpecificMessageRemindObserve;
- (void)disposeObserve;

@end

@implementation TDFSDMessageRemindBaseViewModel

- (void)addSpecificMessageRemindObserve {
    NSAssert(NO,
             @"should override this method by subclass which inherit `TDFSDMessageRemindBaseViewModel` class");
}

- (void)disposeObserve {
    if (self.disposable && ![self.disposable isDisposed]) {
        [self.disposable dispose];
    }
}

@end

#import "TDFSDAPIRecorder.h"
#import "TDFALRequestModel+APIRecord.h"

@interface TDFSDMessageRemindALViewModel : TDFSDMessageRemindBaseViewModel

@end

@implementation TDFSDMessageRemindALViewModel

- (void)addSpecificMessageRemindObserve {
    @weakify(self)
    self.disposable = \
    [RACObserve([TDFSDAPIRecorder sharedInstance], requestDesModels) subscribeNext:^(NSArray<TDFALRequestModel *> * _Nullable requestDescriptions) {
        
        NSUInteger unreadCount = [[[requestDescriptions.rac_sequence
        filter:^BOOL(TDFALRequestModel * _Nullable requestDesModel) {
            return !requestDesModel.messageIsRead;
        }]
        array] count];
        
        @strongify(self)
        if (unreadCount <= 99) {
            self.messageRemindLabelReference.text = @(unreadCount).stringValue;
        } else {
            self.messageRemindLabelReference.text = @"99+";
        }
    }];
}

@end


@interface TDFSDThumbnailView ()

@property (nonatomic, strong) UIImageView *thumbnailIconView;
@property (nonatomic, strong) UILabel     *unreadMessageRemindLabel;
@property (nonatomic, strong) __kindof TDFSDMessageRemindBaseViewModel *viewModel;

@end

@implementation TDFSDThumbnailView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self layoutPageSubviews];
        [self addTapGesture];
        [self addLongPressGesture];
        [self addMessageRemindTextObserve];
        [self addThumbnailMessageRemindTypeObserve];
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

- (UILabel *)unreadMessageRemindLabel {
    if (!_unreadMessageRemindLabel) {
        _unreadMessageRemindLabel = [[UILabel alloc] init];
        [_unreadMessageRemindLabel setBackgroundColor:[UIColor colorWithRed:241/255.f green:56/255.f blue:56/255.f alpha:1]];
        _unreadMessageRemindLabel.textAlignment = NSTextAlignmentCenter;
        _unreadMessageRemindLabel.numberOfLines = 1;
        _unreadMessageRemindLabel.textColor = [UIColor whiteColor];
        _unreadMessageRemindLabel.font = [UIFont boldSystemFontOfSize:11];
        _unreadMessageRemindLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _unreadMessageRemindLabel.layer.cornerRadius = 7;
        _unreadMessageRemindLabel.layer.masksToBounds = YES;
    }
    return _unreadMessageRemindLabel;
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
    [self addSubview:self.unreadMessageRemindLabel];
    [self.thumbnailIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.unreadMessageRemindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_right).with.offset(-12);
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
        self.unreadMessageRemindLabel.text = @"";
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

- (void)addMessageRemindTextObserve {
    @weakify(self)
    [RACObserve(self.unreadMessageRemindLabel, text) subscribeNext:^(NSString * _Nullable newText) {
        @strongify(self)
        
        if (newText && newText.length && ![newText isEqualToString:@"0"]) {
            self.unreadMessageRemindLabel.hidden = NO;
            CGSize fitSize = [self.unreadMessageRemindLabel sizeThatFits:CGSizeZero];
            CGFloat fitWidth = fitSize.width + 4 < 14 ? 14 : fitSize.width + 4;
            [self.unreadMessageRemindLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(fitWidth));
            }];
        } else {
            self.unreadMessageRemindLabel.hidden = YES;
        }
    }];
}

- (void)addThumbnailMessageRemindTypeObserve {
    @weakify(self)
    [RACObserve([TDFSDPersistenceSetting sharedInstance], messageRemindType) subscribeNext:^(NSNumber *  _Nullable messageRemindType) {
        @strongify(self)
        
        if (self.viewModel) {
            [self.viewModel disposeObserve];
        }
        
        switch ([messageRemindType unsignedIntegerValue]) {
            case SDMessageRemindTypeAPIRecord: {
                self.viewModel = [[TDFSDMessageRemindALViewModel alloc] init];
            }break;
        }
        
        self.viewModel.messageRemindLabelReference = self.unreadMessageRemindLabel;
        [self.viewModel addSpecificMessageRemindObserve];
    }];
}

@end

