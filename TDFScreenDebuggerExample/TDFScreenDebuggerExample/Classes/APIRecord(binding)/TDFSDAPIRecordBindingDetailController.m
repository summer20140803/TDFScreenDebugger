//
//  TDFSDAPIRecordBindingDetailController.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/27.
//
//

#import "TDFSDAPIRecordBindingDetailController.h"
#import "TDFSDAPIRecorder.h"
#import "TDFSDTextView.h"
#import "UIView+ScreenDebugger.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

typedef NS_ENUM(NSUInteger, kTDFSDARCurrentContentType) {
    kTDFSDARCurrentContentTypeRequest     =  0,
    kTDFSDARCurrentContentTypeResponse    =  1
};

@interface TDFSDAPIRecordBindingDetailController () <TDFSDFullScreenConsoleControllerInheritProtocol>

@property (nonatomic, strong) UIView *bindingView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) TDFALResponseModel *resp;
@property (nonatomic, strong) TDFSDTextView *bindingContentView;
@property (nonatomic, assign) kTDFSDARCurrentContentType contentType;

@end

@implementation TDFSDAPIRecordBindingDetailController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutPageSubviews];
    self.contentType = kTDFSDARCurrentContentTypeRequest;
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"Specified API Detail";
}

- (__kindof UIView *)contentViewForFullScreenConsole {
    return self.bindingView;
}

#pragma mark - private
- (void)layoutPageSubviews {
    [self.bindingView addSubview:self.segmentedControl];
    [self.bindingView addSubview:self.bindingContentView];
    
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bindingView);
        make.top.equalTo(self.bindingView);
        make.width.equalTo(@140);
        make.height.equalTo(@30);
    }];
    [self.bindingContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentedControl.mas_bottom).with.offset(6);
        make.left.right.equalTo(self.bindingView);
        make.bottom.equalTo(self.bindingView);
    }];
}

#pragma mark - getter & setter
- (void)setContentType:(kTDFSDARCurrentContentType)contentType {
    _contentType = contentType;
    switch (contentType) {
        case kTDFSDARCurrentContentTypeRequest: {
            self.bindingContentView.text = self.req.selfDescription;
        } break;
        case kTDFSDARCurrentContentTypeResponse: {
            self.bindingContentView.text = self.resp ? self.resp.selfDescription : @"The response from the server has not been received yet";
        } break;
    }
    if (self.bindingContentView.refreshControl.isRefreshing) {
        [self.bindingContentView.refreshControl endRefreshing];
    } else {
        [self.bindingContentView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    [self.bindingContentView sd_fadeAnimation];
}

- (TDFALResponseModel *)resp {
    if (!_resp) {
        @weakify(self)
        NSArray *array = \
        [[[TDFSDAPIRecorder sharedInstance].responseDesModels.rac_sequence
        filter:^BOOL(TDFALResponseModel * _Nullable responseModel) {
            @strongify(self)
            return [responseModel.taskIdentifier isEqualToString:self.req.taskIdentifier];
        }]
        array];
        
        if (array.count) {
            _resp = array.lastObject;
        }
    }
    return _resp;
}

- (UIView *)bindingView {
    if (!_bindingView) {
        _bindingView = [[UIView alloc] init];
        _bindingView.backgroundColor = [UIColor clearColor];
    }
    return _bindingView;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Request", @"Response"]];
        _segmentedControl.tintColor = [UIColor whiteColor];
        _segmentedControl.selectedSegmentIndex = 0;
        @weakify(self)
        [[_segmentedControl rac_signalForControlEvents:UIControlEventValueChanged]
        subscribeNext:^(__kindof UISegmentedControl * _Nullable x) {
            @strongify(self)
            self.contentType = x.selectedSegmentIndex;
        }];
    }
    return _segmentedControl;
}

- (TDFSDTextView *)bindingContentView {
    if (!_bindingContentView) {
        _bindingContentView = [[TDFSDTextView alloc] init];
        _bindingContentView.textColor = [UIColor whiteColor];
        _bindingContentView.font = [UIFont fontWithName:@"PingFang SC" size:13];
        _bindingContentView.showsVerticalScrollIndicator = NO;
        
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor whiteColor];
        @weakify(self)
        [[refreshControl rac_signalForControlEvents:UIControlEventValueChanged]
        subscribeNext:^(__kindof UIRefreshControl * _Nullable x) {
            @strongify(self)
            kTDFSDARCurrentContentType currentContentType = self.contentType;
            self.contentType = currentContentType;
        }];
        
        _bindingContentView.refreshControl = refreshControl;
    }
    return _bindingContentView;
}

@end
