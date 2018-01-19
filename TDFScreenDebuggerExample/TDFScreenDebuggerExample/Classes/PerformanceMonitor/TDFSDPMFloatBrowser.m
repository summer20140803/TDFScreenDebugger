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

#define kSDPMDataLabelSize  CGSizeMake(80., 40.)

//static UIView *createSeparateLine(void) {
//    UIView *separateLine = [[UIView alloc] init];
//    separateLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    return separateLine;
//}

@interface TDFSDPMDataLabel : TDFSDAsyncDisplayLabel {
    @protected
    CAShapeLayer *shapeLayer;
}

@property (nonatomic, copy) void (^didTapDataLabelHandler)(TDFSDPMDataLabel *label);
+ (instancetype)label;
- (void)flash;

@end

@implementation TDFSDPMDataLabel

+ (instancetype)label {
    TDFSDPMDataLabel *label = [[TDFSDPMDataLabel alloc] init];
    
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor colorWithWhite:1 alpha:0.1].CGColor;
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, kSDPMDataLabelSize.width, kSDPMDataLabelSize.height) cornerRadius:0].CGPath;
    [label.layer addSublayer:shapeLayer];
    label->shapeLayer = shapeLayer;
    
    label.numberOfLines = 2;
    label.userInteractionEnabled = YES;
    label.textColor = [UIColor whiteColor];   // ???
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:label action:@selector(tap:)];
    [label addGestureRecognizer:tap];
    
    return label;
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    !self.didTapDataLabelHandler ?: self.didTapDataLabelHandler(self);
}

- (void)flash {
    self->shapeLayer.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.3].CGColor;
    SD_DELAY_HANDLER(0.5, {
        self->shapeLayer.fillColor = [UIColor colorWithWhite:1 alpha:0.1].CGColor;
    });
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
        [self setBackgroundColor:[UIColor colorWithRed:2/255.f green:31/255.f blue:40/255.f alpha:0.8]];
        self.layer.cornerRadius = 20.0f;
        self.layer.masksToBounds = YES;
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
    
//    UIView *separateYLine = createSeparateLine();
//    [self addSubview:separateYLine];
    
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
        make.left.equalTo(self);
        make.top.equalTo(self.cpuView.mas_bottom);
        make.width.equalTo(@(kSDPMDataLabelSize.width));
        make.height.equalTo(@(kSDPMDataLabelSize.height));
    }];
    [self.lagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.memoryView.mas_bottom);
        make.right.equalTo(self);
        make.width.equalTo(@(kSDPMDataLabelSize.width));
        make.height.equalTo(@(kSDPMDataLabelSize.height));
    }];
    [self.centerEnterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.bottom.equalTo(self);
        make.height.equalTo(@30);
    }];
//    [separateYLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self).with.offset(15);
//        make.bottom.equalTo(self).with.offset(-45);
//        make.centerX.equalTo(self);
//        make.width.equalTo(@0.5);
//    }];
    [self layoutIfNeeded];
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

- (void)observeMonitoringDataSource {
    @weakify(self)
    [RACObserve([TDFSDPerformanceMonitor sharedInstance], uiLags) subscribeNext:^(NSArray * _Nullable lags) {
        @strongify(self)
        self.lagView.attributedText = [self formattedAttributedStringWithMonitoringText:[NSString stringWithFormat:@"LAG\n%ld", lags.count]];
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
            self.memoryView.attributedText = [self formattedAttributedStringWithMonitoringText:[NSString stringWithFormat:@"MEM\n%.1fMB", [appMemoryUsage doubleValue]]];
        }
    }];
    [RACObserve([TDFSDPerformanceMonitor sharedInstance], screenFps) subscribeNext:^(NSNumber * _Nullable screenFps) {
        @strongify(self)
        if ([TDFSDPersistenceSetting sharedInstance].allowScreenFPSMonitoring) {
            self.fpsView.attributedText = [self formattedAttributedStringWithMonitoringText:[NSString stringWithFormat:@"FPS\n%d", [screenFps intValue]]];
            if ([screenFps doubleValue] < [TDFSDPersistenceSetting sharedInstance].fpsWarnningThreshold) {
                [self.fpsView flash];
            }
        }
    }];
}

- (NSAttributedString *)formattedAttributedStringWithMonitoringText:(NSString *)monitoringText {
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:monitoringText];
    NSRange dataRange = NSMakeRange(0, monitoringText.length);
    [mutableString addAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"PingFangSC-Medium" size:13],
                                    NSForegroundColorAttributeName : [UIColor whiteColor] }
                           range:dataRange];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
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
        [_centerEnterBtn setBackgroundColor:[UIColor clearColor]];
        _centerEnterBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _centerEnterBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        [_centerEnterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_centerEnterBtn setTitle:@"Tap to Debugger Center" forState:UIControlStateNormal];
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
