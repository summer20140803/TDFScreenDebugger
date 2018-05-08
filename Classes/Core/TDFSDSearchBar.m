//
//  TDFSDSearchBar.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/19.
//
//

#import "TDFSDSearchBar.h"
#import <Masonry/Masonry.h>
#import "TDFScreenDebuggerDefine.h"

@interface TDFSDInputAccessoryView : UIView

@property (nonatomic,   weak) UIView     *hitTestView;
@property (nonatomic, strong) UIButton   *previousButton;
@property (nonatomic, strong) UIButton   *nextButton;
@property (nonatomic, strong) UILabel    *currentSearchIndexLabel;
@property (nonatomic, strong) UILabel    *searchResultTotalCountLabel;
@property (nonatomic, strong) UIView     *lineView;
@property (nonatomic, assign) NSUInteger currentSearchIndex;
@property (nonatomic, assign) NSUInteger searchResultTotalCount;
@property (nonatomic, strong) RACSubject *previousProxy;
@property (nonatomic, strong) RACSubject *nextProxy;

@end

@implementation TDFSDInputAccessoryView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        [self layoutPageSubviews];
    }
    return self;
}

- (UIButton *)previousButton {
    if (!_previousButton) {
        _previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_previousButton setBackgroundColor:[UIColor clearColor]];
        [_previousButton setBackgroundImage:SD_BUNDLE_IMAGE(@"icon_screenDebugger_up") forState:UIControlStateNormal];
        @weakify(self)
        _previousButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            !self.previousProxy ?: [self.previousProxy sendNext:input];
            return [RACSignal empty];
        }];
    }
    return _previousButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setBackgroundColor:[UIColor clearColor]];
        [_nextButton setBackgroundImage:SD_BUNDLE_IMAGE(@"icon_screenDebugger_down") forState:UIControlStateNormal];
        @weakify(self)
        _nextButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            !self.nextProxy ?: [self.nextProxy sendNext:input];
            return [RACSignal empty];
        }];
    }
    return _nextButton;
}

- (UILabel *)currentSearchIndexLabel {
    if (!_currentSearchIndexLabel) {
        _currentSearchIndexLabel = [[UILabel alloc] init];
        [_currentSearchIndexLabel setBackgroundColor:[UIColor clearColor]];
        _currentSearchIndexLabel.textAlignment = NSTextAlignmentCenter;
        _currentSearchIndexLabel.numberOfLines = 1;
        _currentSearchIndexLabel.textColor = [UIColor whiteColor];
        _currentSearchIndexLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
        _currentSearchIndexLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _currentSearchIndexLabel.text = @"0";
    }
    return _currentSearchIndexLabel;
}

- (UILabel *)searchResultTotalCountLabel {
    if (!_searchResultTotalCountLabel) {
        _searchResultTotalCountLabel = [[UILabel alloc] init];
        [_searchResultTotalCountLabel setBackgroundColor:[UIColor clearColor]];
        _searchResultTotalCountLabel.textAlignment = NSTextAlignmentCenter;
        _searchResultTotalCountLabel.numberOfLines = 1;
        _searchResultTotalCountLabel.textColor = [UIColor whiteColor];
        _searchResultTotalCountLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
        _searchResultTotalCountLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _searchResultTotalCountLabel.text = @"0";
    }
    return _searchResultTotalCountLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor whiteColor];
    }
    return _lineView;
}

- (void)setCurrentSearchIndex:(NSUInteger)currentSearchIndex {
    _currentSearchIndex = currentSearchIndex;
    _currentSearchIndexLabel.text = @(currentSearchIndex).stringValue;
}

- (void)setSearchResultTotalCount:(NSUInteger)searchResultTotalCount {
    _searchResultTotalCount = searchResultTotalCount;
    _searchResultTotalCountLabel.text = @(searchResultTotalCount).stringValue;
}

// override `hitTest:withEvent` method to change the default responder(self) to customView
// otherwise the viewController `touchBegan` method will be invoked
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.previousButton.frame, point)) {
        return self.previousButton;
    }
    if (CGRectContainsPoint(self.nextButton.frame, point)) {
        return self.nextButton;
    }
    UIView *hitTestView = [super hitTest:point withEvent:event];
    return self.hitTestView ?: hitTestView;
}

- (void)layoutPageSubviews {
    [self addSubview:self.previousButton];
    [self addSubview:self.nextButton];
    [self addSubview:self.currentSearchIndexLabel];
    [self addSubview:self.lineView];
    [self addSubview:self.searchResultTotalCountLabel];
    
    [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-11);
        make.width.and.height.equalTo(@30);
        make.bottom.equalTo(self).with.offset(-90);
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).with.offset(-10);
        make.right.equalTo(self.previousButton);
        make.width.and.height.equalTo(self.previousButton);
    }];
    [self.currentSearchIndexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.previousButton);
        make.height.equalTo(@20);
        make.top.equalTo(self.previousButton.mas_bottom).with.offset(5);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.previousButton);
        make.width.equalTo(self.searchResultTotalCountLabel).with.offset(6);
        make.height.equalTo(@0.5);
        make.top.equalTo(self.currentSearchIndexLabel.mas_bottom);
    }];
    [self.searchResultTotalCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom);
        make.centerX.equalTo(self.previousButton);
        make.height.equalTo(@20);
    }];
}

@end


@interface TDFSDSearchBar ()

@property (nonatomic, strong) TDFSDInputAccessoryView *inputAccessoryContainer;

@property (nonatomic, strong, readwrite) RACCommand *accessoryDelayCommand;

@end

const CGFloat SDSearchBarInputAccessoryHeight  = 130.f;

@implementation TDFSDSearchBar

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        self.barStyle = UIBarStyleBlack;
        self.searchBarStyle = UISearchBarStyleMinimal;
        self.placeholder = @"enter keywords to search";
        self.translucent = YES;
        self.tintColor = [UIColor lightTextColor];
        [self.inputAccessoryContainer setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, SDSearchBarInputAccessoryHeight)];
        self.inputAccessoryView = self.inputAccessoryContainer;
        @weakify(self)
        self.accessoryDelayCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber * _Nullable input) {
            BOOL shouldDisplay = [input boolValue];
            @strongify(self)
            self.inputAccessoryContainer.hidden = !shouldDisplay;
            return [RACSignal empty];
        }];
    }
    return self;
}

#pragma mark - getter & setter
- (void)setHitTestView:(UIView *)hitTestView {
    _hitTestView = hitTestView;
    _inputAccessoryContainer.hitTestView = hitTestView;
}

- (void)setPreviousProxy:(RACSubject *)previousProxy {
    _previousProxy = previousProxy;
    _inputAccessoryContainer.previousProxy = previousProxy;
}

- (void)setNextProxy:(RACSubject *)nextProxy {
    _nextProxy = nextProxy;
    _inputAccessoryContainer.nextProxy = nextProxy;
}

- (void)setCurrentSearchIndex:(NSUInteger)currentSearchIndex {
    _currentSearchIndex = currentSearchIndex;
    _inputAccessoryContainer.currentSearchIndex = currentSearchIndex;
}

- (void)setSearchResultTotalCount:(NSUInteger)searchResultTotalCount {
    _searchResultTotalCount = searchResultTotalCount;
    _inputAccessoryContainer.searchResultTotalCount = searchResultTotalCount;
}

- (TDFSDInputAccessoryView *)inputAccessoryContainer {
    if (!_inputAccessoryContainer) {
        _inputAccessoryContainer = [[TDFSDInputAccessoryView alloc] init];
        _inputAccessoryContainer.hitTestView = self.hitTestView;
        _inputAccessoryContainer.previousProxy = self.previousProxy;
        _inputAccessoryContainer.nextProxy = self.nextProxy;
    }
    return _inputAccessoryContainer;
}

@end
