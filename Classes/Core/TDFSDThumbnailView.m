//
//  TDFSDThumbnailView.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/12.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDThumbnailView.h"
#import "TDFSDPersistenceSetting.h"
#import "TDFScreenDebuggerDefine.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDMessageRemindBaseViewModel : NSObject

@property (nonatomic,   weak) UILabel *messageRemindLabelReference;
@property (nonatomic, strong) RACDisposable *disposable;

- (void)addSpecificMessageRemindObserve;
- (void)disposeObserve;
- (void)forceAllRead;

@end

@implementation TDFSDMessageRemindBaseViewModel

- (void)addSpecificMessageRemindObserve {
    NSAssert(NO,
             @"should override this method by subclass which inherit `TDFSDMessageRemindBaseViewModel` class");
}

- (void)forceAllRead {
    self.messageRemindLabelReference.text = @"";
}

- (void)disposeObserve {
    if (self.disposable && ![self.disposable isDisposed]) {
        [self.disposable dispose];
    }
}

@end

#import "TDFSDAPIRecorder.h"
#import "TDFALRequestModel+APIRecord.h"
@interface TDFSDMessageRemindARViewModel : TDFSDMessageRemindBaseViewModel

@end

@implementation TDFSDMessageRemindARViewModel

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
        if (unreadCount && unreadCount <= 99) {
            self.messageRemindLabelReference.text = @(unreadCount).stringValue;
        } else if(unreadCount > 99) {
            self.messageRemindLabelReference.text = @"99+";
        } else {
            self.messageRemindLabelReference.text = @"";
        }
    }];
}

@end

#import "TDFSDLogViewer.h"
#import "TDFSDLVLogModel.h"
@interface TDFSDMessageRemindLVViewModel : TDFSDMessageRemindBaseViewModel

@end

@implementation TDFSDMessageRemindLVViewModel

- (void)addSpecificMessageRemindObserve {
    @weakify(self)
    self.disposable = \
    [RACObserve([TDFSDLogViewer sharedInstance], logs) subscribeNext:^(NSArray<TDFSDLVLogModel *> * _Nullable logModels) {
        
        NSUInteger unreadCount = [[[logModels.rac_sequence
        filter:^BOOL(TDFALRequestModel * _Nullable requestDesModel) {
            return !requestDesModel.messageIsRead;
        }]
        array] count];
        
        @strongify(self)
        if (unreadCount && unreadCount <= 99) {
            self.messageRemindLabelReference.text = @(unreadCount).stringValue;
        } else if(unreadCount > 99) {
            self.messageRemindLabelReference.text = @"99+";
        } else {
            self.messageRemindLabelReference.text = @"";
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
        [self addAllReadNoticationObserve];
    }
    return self;
}

- (void)dealloc {
    [self.tapProxy sendCompleted];
    [self.longPressProxy sendCompleted];
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
        !self.tapProxy ?: [self.tapProxy sendNext:x];
    }];
    [self addGestureRecognizer:tapGesture];
}

- (void)addLongPressGesture {
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] init];
    longPressGesture.minimumPressDuration = 0.5;
    @weakify(self)
    [longPressGesture.rac_gestureSignal
    subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self)
        !self.longPressProxy ?: [self.longPressProxy sendNext:x];
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
                self.viewModel = [[TDFSDMessageRemindARViewModel alloc] init];
            }break;
            case SDMessageRemindTypeSystemLog: {
                self.viewModel = [[TDFSDMessageRemindLVViewModel alloc] init];
            }break;
        }
        
        self.viewModel.messageRemindLabelReference = self.unreadMessageRemindLabel;
        [self.viewModel addSpecificMessageRemindObserve];
    }];
}

- (void)addAllReadNoticationObserve {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SD_REMIND_MESSAGE_ALL_READ_NOTIFICATION_NAME object:nil]
    subscribeNext:^(NSNotification * _Nullable x) {
        SDAllReadNotificationContentType type = [x.object unsignedIntegerValue];
        
        // if all-read content type hit the messageRemindType setted by user or default, invoke `forceAllRead` to clear label text
        if (type == (SDAllReadNotificationContentType)[TDFSDPersistenceSetting sharedInstance].messageRemindType) {
            [self.viewModel forceAllRead];
        }
    }];
}

#pragma mark - getter
- (UIImageView *)thumbnailIconView {
    if (!_thumbnailIconView) {
        _thumbnailIconView = [[UIImageView alloc] initWithImage:SD_BUNDLE_IMAGE(@"icon_screenDebugger_thumbnail")];
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

@end

