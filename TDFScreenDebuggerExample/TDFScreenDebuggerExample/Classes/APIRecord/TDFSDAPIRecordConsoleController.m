//
//  TDFSDAPIRecordConsoleController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/14.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDAPIRecordConsoleController.h"
#import "TDFSDAPIRecorder.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "TDFALRequestModel+APIRecord.h"

@interface TDFSDAPIRecordConsoleController () <TDFSDFullScreenConsoleControllerInheritProtocol>

@property (nonatomic, strong) UITextView *apiOutputView;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation TDFSDAPIRecordConsoleController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutPageSubviews];
    [self addAPIRecordPortObserve];
    [self.loadingView startAnimating];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // if too large text content presented in UITextView, it will get stuck during `viewDidLoad`
    // so I decide to put fetch text and presentation operation code in `viewDidAppear`
    [self fetchAlreadyExistRecord];
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"API Record";
}

- (UIView *)contentViewForFullScreenConsole {
    return self.apiOutputView;
}

#pragma mark - getter
- (UITextView *)apiOutputView {
    if (!_apiOutputView) {
        _apiOutputView = [[UITextView alloc] init];
        _apiOutputView.backgroundColor = [UIColor clearColor];
        _apiOutputView.editable = NO;
        _apiOutputView.selectable = YES;
        _apiOutputView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        _apiOutputView.allowsEditingTextAttributes = YES;
        _apiOutputView.showsVerticalScrollIndicator = YES;
        _apiOutputView.showsHorizontalScrollIndicator = NO;
        // avoid the system auto scroll
        _apiOutputView.layoutManager.allowsNonContiguousLayout = NO;
    }
    return _apiOutputView;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _loadingView;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearButton setBackgroundColor:[UIColor clearColor]];
        _clearButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _clearButton.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:15];
        [_clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_clearButton setTitle:@"Clear" forState:UIControlStateNormal];
        _clearButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            [[TDFSDAPIRecorder sharedInstance] clearAllRecords];
            return [RACSignal empty];
        }];
    }
    return _clearButton;
}

#pragma mark - private
- (void)layoutPageSubviews {
    [self.container addSubview:self.loadingView];
    [self.container addSubview:self.clearButton];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.apiOutputView);
        make.width.and.height.equalTo(@44);
    }];
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.container).with.offset(-11);
        make.top.equalTo(self.container).with.offset(11);
        make.width.equalTo(@60);
        make.height.equalTo(@40);
    }];
}

- (void)addAPIRecordPortObserve {
    RAC(self.apiOutputView, attributedText) = [[RACObserve([TDFSDAPIRecorder sharedInstance], descriptionModels)
    skip:1]
    map:^id _Nullable(NSArray<__kindof TDFALBaseModel<TDFSDAPIRecordCharacterizationProtocol> *> *descriptionModels) {
        return [[descriptionModels.rac_sequence
               map:^id _Nullable(__kindof TDFALBaseModel<TDFSDAPIRecordCharacterizationProtocol> * _Nullable descriptionModel) {
                   return descriptionModel.outputCharacterizationString;
               }]
               foldLeftWithStart:[[NSMutableAttributedString alloc] initWithString:@""]
               reduce:^id _Nullable(NSMutableAttributedString * _Nullable accumulator, NSAttributedString * _Nullable value) {
                   return ([accumulator appendAttributedString:value],
                           [accumulator appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]],
                           accumulator);
               }];
    }];
    
    @weakify(self)
    [[[[[RACObserve(self.apiOutputView, attributedText)
    skip:1]
    distinctUntilChanged]
    delay:0.2f]
    doNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.loadingView.isAnimating) {
            [self.loadingView stopAnimating];
        }
    }]
    subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.apiOutputView scrollRangeToVisible:NSMakeRange(self.apiOutputView.attributedText.length, 1)];
    }];
}

- (void)fetchAlreadyExistRecord {
    self.apiOutputView.attributedText = [[[TDFSDAPIRecorder sharedInstance].descriptionModels.rac_sequence
    map:^id _Nullable(__kindof TDFALBaseModel<TDFSDAPIRecordCharacterizationProtocol> * _Nullable descriptionModel) {
        // mark all-read `TDFALRequestModel` instances messageRead to YES
        if ([descriptionModel isKindOfClass:[TDFALRequestModel class]]) {
            [(TDFALRequestModel *)descriptionModel setMessageRead:YES];
        }
        return descriptionModel.outputCharacterizationString;
    }]
    foldLeftWithStart:[[NSMutableAttributedString alloc] initWithString:@""]
    reduce:^id _Nullable(NSMutableAttributedString * _Nullable accumulator, NSAttributedString * _Nullable value) {
        return ([accumulator appendAttributedString:value],
                [accumulator appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]],
                accumulator);
    }];
}


@end
