//
//  TDFSDPMFloatBrowser.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/21.
//

#import "TDFSDPMFloatBrowser.h"
#import "TDFSDPerformanceMonitor.h"
#import "TDFScreenDebuggerDefine.h"
#import "TDFSDPersistenceSetting.h"
#import "TDFSDAsyncDisplayLabel.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

#define kSDPMDataLabelSize  CGSizeMake(60., 30.)

@interface TDFSDPMDataLabel : TDFSDAsyncDisplayLabel {
    @protected
    CAShapeLayer *_shapeLayer;
}

@property (nonatomic, copy) void (^didTapDataLabelHandler)(TDFSDPMDataLabel *label);
+ (instancetype)label;
- (void)flash;

@end

@implementation TDFSDPMDataLabel

+ (instancetype)label {
    TDFSDPMDataLabel *label = [[TDFSDPMDataLabel alloc] init];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor colorWithWhite:1 alpha:0].CGColor;
    layer.path = [UIBezierPath bezierPathWithRect:(CGRect){{0, 0}, kSDPMDataLabelSize}].CGPath;
    [label.layer addSublayer:layer];
    label->_shapeLayer = layer;
    
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
    label.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:label action:@selector(tap:)];
    [label addGestureRecognizer:tap];
    
    return label;
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    !self.didTapDataLabelHandler ?: self.didTapDataLabelHandler(self);
}

- (void)flash {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut |
                                                    UIViewAnimationOptionBeginFromCurrentState
     animations:^{
        self->_shapeLayer.fillColor = [UIColor colorWithWhite:1 alpha:0.4].CGColor;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut |
                                                              UIViewAnimationOptionBeginFromCurrentState
             animations:^{
                 self->_shapeLayer.fillColor = [UIColor colorWithWhite:1 alpha:0].CGColor;
            } completion:nil];
        }
    }];
}

@end

@interface TDFSDPMFloatBrowser ()

@property (nonatomic, strong) TDFSDPMDataLabel *cpuView;
@property (nonatomic, strong) TDFSDPMDataLabel *memoryView;
@property (nonatomic, strong) TDFSDPMDataLabel *fpsView;
@property (nonatomic, strong) TDFSDPMDataLabel *lagView;
@property (nonatomic, strong) UIButton *centerEnterBtn;

@end

@implementation TDFSDPMFloatBrowser

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor colorWithRed:2/255.f green:31/255.f blue:40/255.f alpha:0.7]];
        [self layoutPageSubviews];
        [self addLongPressGesture];
        [self observeMonitoringDataSource];
    }
    return self;
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
    [self addSubview:self.cpuView];
    [self addSubview:self.memoryView];
    [self addSubview:self.fpsView];
    [self addSubview:self.lagView];
    [self addSubview:self.centerEnterBtn];
    
    [self.cpuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self);
        make.width.equalTo(@(kSDPMDataLabelSize.width));
        make.height.equalTo(@(kSDPMDataLabelSize.height));
    }];
    [self.memoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.top.equalTo(self);
        make.width.equalTo(@(kSDPMDataLabelSize.width));
        make.height.equalTo(@(kSDPMDataLabelSize.height));
    }];
    [self.fpsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.equalTo(self);
        make.width.equalTo(@(kSDPMDataLabelSize.width));
        make.height.equalTo(@(kSDPMDataLabelSize.height));
    }];
    [self.lagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.equalTo(self);
        make.width.equalTo(@(kSDPMDataLabelSize.width));
        make.height.equalTo(@(kSDPMDataLabelSize.height));
    }];
    [self.centerEnterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.bottom.equalTo(self);
        make.height.equalTo(@20);
    }];
}

- (void)addLongPressGesture {
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] init];
    longPressGesture.minimumPressDuration = 1;
    @weakify(self)
    [longPressGesture.rac_gestureSignal
     subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
         @strongify(self)
         !self.longPressProxy ?: [self.longPressProxy sendNext:x];
     }];
    [self addGestureRecognizer:longPressGesture];
}

- (void)observeMonitoringDataSource {
    @weakify(self)
    [RACObserve([TDFSDPerformanceMonitor sharedInstance], uiLags) subscribeNext:^(NSArray * _Nullable lags) {
        @strongify(self)
        self.lagView.attributedText = [self formattedAttributedStringWithMonitoringText:[NSString stringWithFormat:@"Lags\n%ld", lags.count]];
        [self.lagView flash];
    }];
    [RACObserve([TDFSDPerformanceMonitor sharedInstance], appCpuUsage) subscribeNext:^(NSNumber * _Nullable appCpuUsage) {
        @strongify(self)
        if ([TDFSDPersistenceSetting sharedInstance].allowApplicationCPUMonitoring) {
            self.cpuView.attributedText = [self formattedAttributedStringWithMonitoringText:[NSString stringWithFormat:@"CPU\n%.1f%%", [appCpuUsage doubleValue]]];
        }
    }];
    [RACObserve([TDFSDPerformanceMonitor sharedInstance], appMemoryUsage) subscribeNext:^(NSNumber * _Nullable appMemoryUsage) {
        @strongify(self)
        if ([TDFSDPersistenceSetting sharedInstance].allowApplicationMemoryMonitoring) {
            self.memoryView.attributedText = [self formattedAttributedStringWithMonitoringText:[NSString stringWithFormat:@"Memory\n%.1f%%", [appMemoryUsage doubleValue]]];
        }
    }];
    [RACObserve([TDFSDPerformanceMonitor sharedInstance], screenFps) subscribeNext:^(NSNumber * _Nullable screenFps) {
        @strongify(self)
        if ([TDFSDPersistenceSetting sharedInstance].allowScreenFPSMonitoring) {
            self.fpsView.attributedText = [self formattedAttributedStringWithMonitoringText:[NSString stringWithFormat:@"FPS\n%.1f%%", [screenFps doubleValue]]];
            if ([screenFps doubleValue] < [TDFSDPersistenceSetting sharedInstance].fpsWarnningThreshold) {
                [self.fpsView flash];
            }
        }
    }];
}

- (NSAttributedString *)formattedAttributedStringWithMonitoringText:(NSString *)monitoringText {
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:monitoringText];
    NSRange titleRange = NSMakeRange(0, [monitoringText rangeOfString:@"\n"].location);
    [mutableString addAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:13],
                                    NSForegroundColorAttributeName:[UIColor whiteColor] }
                           range:titleRange];
    NSRange dataRange = NSMakeRange([monitoringText rangeOfString:@"\n"].location, monitoringText.length);
    [mutableString addAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:16],
                                    NSForegroundColorAttributeName:[UIColor whiteColor] }
                           range:dataRange];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [mutableString addAttributes:@{ NSParagraphStyleAttributeName : style } range:NSMakeRange(0, monitoringText.length)];
    return mutableString;
}

#pragma mark - getter
- (TDFSDPMDataLabel *)cpuView {
    if (!_cpuView) {
        _cpuView = [TDFSDPMDataLabel label];
        @weakify(self)
        _cpuView.didTapDataLabelHandler = ^(TDFSDPMDataLabel *label) {
            @strongify(self)
            !self.tapProxy ?: [self.tapProxy sendNext:@(SDPMTapZoneTypeCPU)];
        };
    }
    return _cpuView;
}

- (TDFSDPMDataLabel *)memoryView {
    if (!_memoryView) {
        _memoryView = [TDFSDPMDataLabel label];
        @weakify(self)
        _memoryView.didTapDataLabelHandler = ^(TDFSDPMDataLabel *label) {
            @strongify(self)
            !self.tapProxy ?: [self.tapProxy sendNext:@(SDPMTapZoneTypeMemory)];
        };
    }
    return _memoryView;
}

- (TDFSDPMDataLabel *)fpsView {
    if (!_fpsView) {
        _fpsView = [TDFSDPMDataLabel label];
        @weakify(self)
        _fpsView.didTapDataLabelHandler = ^(TDFSDPMDataLabel *label) {
            @strongify(self)
            !self.tapProxy ?: [self.tapProxy sendNext:@(SDPMTapZoneTypeFPS)];
        };
    }
    return _fpsView;
}

- (TDFSDPMDataLabel *)lagView {
    if (!_lagView) {
        _lagView = [TDFSDPMDataLabel label];
        @weakify(self)
        _lagView.didTapDataLabelHandler = ^(TDFSDPMDataLabel *label) {
            @strongify(self)
            !self.tapProxy ?: [self.tapProxy sendNext:@(SDPMTapZoneTypeLag)];
        };
    }
    return _lagView;
}

- (UIButton *)centerEnterBtn {
    if (!_centerEnterBtn) {
        _centerEnterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_centerEnterBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
        _centerEnterBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _centerEnterBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:15];
        [_centerEnterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_centerEnterBtn setTitle:@"Debugger Center" forState:UIControlStateNormal];
        @weakify(self)
        _centerEnterBtn.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            !self.tapProxy ?: [self.tapProxy sendNext:@(SDPMTapZoneTypeCenter)];
            return [RACSignal empty];
        }];
    }
    return _centerEnterBtn;
}

@end
