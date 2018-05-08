//
//  TDFSDAPIRecordConsoleController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/14.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDAPIRecordConsoleController.h"
#import "TDFSDAPIRecorder.h"
#import "TDFALRequestModel+APIRecord.h"
#import "TDFSDSearchBar.h"
#import "TDFSDTextView.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDAPIRecordConsoleController () <TDFSDFullScreenConsoleControllerInheritProtocol, UISearchBarDelegate>

@property (nonatomic, strong) UIView *apiRecordContainer;
@property (nonatomic, strong) TDFSDTextView *apiOutputView;
@property (nonatomic, strong) TDFSDSearchBar *searchBar;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation TDFSDAPIRecordConsoleController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutPageSubviews];
    [self addAPIRecordPortObserve];
    [self addKeyboardObserve];
    [self.loadingView startAnimating];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // if too large text content presented in UITextView, it will get stuck during `viewDidLoad`
    // so finally I decide to put fetch text and presentation operation code in `viewDidAppear`
    [self fetchAlreadyExistRecord];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // textview loading large api-records sometimes consumes too much memory even lead to come up memory performance crysis
    // if happened, we will clear all the current record to save memory problems
    [[TDFSDAPIRecorder sharedInstance] clearAllRecords];
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"API Record";
}

- (UIView *)contentViewForFullScreenConsole {
    return self.apiRecordContainer;
}

- (NSArray<TDFSDFunctionMenuItem *> *)functionMenuItemsForFullScreenConsole {
    if (!self.menuItems) {
        @weakify(self)
        return @[
                 [TDFSDFunctionMenuItem itemWithImage:SD_BUNDLE_IMAGE(@"icon_screenDebugger_search")
                 actionHandler:^(TDFSDFunctionMenuItem *item) {
                     // self->strong menuItems->strong item->self
                     @strongify(self)
                     [self relayoutSearchBar];
                 }],
                 [TDFSDFunctionMenuItem itemWithImage:SD_BUNDLE_IMAGE(@"icon_screenDebugger_trash")
                 actionHandler:^(TDFSDFunctionMenuItem *item) {
                     [[TDFSDAPIRecorder sharedInstance] clearAllRecords];
                 }]
               ];
    }
    return self.menuItems;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchNextMatch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchNextMatch];
}

#pragma mark - private
- (void)layoutPageSubviews {
    
    [self.apiRecordContainer addSubview:self.searchBar];
    [self.apiRecordContainer addSubview:self.apiOutputView];
    [self.container addSubview:self.loadingView];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.apiRecordContainer).with.offset(-40);
        make.left.and.right.equalTo(self.apiRecordContainer);
        make.height.equalTo(@28);
    }];
    [self.apiOutputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.bottom.equalTo(self.apiRecordContainer);
        make.top.equalTo(self.searchBar.mas_bottom).with.offset(12);
    }];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.apiRecordContainer);
    }];
}

- (void)addKeyboardObserve {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil]
    subscribeNext:^(NSNotification * _Nullable notification) {
        @strongify(self)
        CGRect kbFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat contentInsetsHeight = self.view.bounds.size.height - kbFrame.origin.y;
        if (contentInsetsHeight) {
            contentInsetsHeight -= SDSearchBarInputAccessoryHeight;
        }
        
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        contentInsets.bottom = contentInsetsHeight;
        
        self.apiOutputView.contentInset = contentInsets;
        self.apiOutputView.scrollIndicatorInsets = contentInsets;
        
        if (!contentInsetsHeight) {
            [self.searchBar.accessoryDelayCommand execute:@(NO)];
        }
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidChangeFrameNotification object:nil]
    subscribeNext:^(NSNotification * _Nullable notification) {
        @strongify(self)
        CGRect kbFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat contentInsetsHeight = self.view.bounds.size.height - kbFrame.origin.y;
        
        if (contentInsetsHeight) {
            [self.searchBar.accessoryDelayCommand execute:@(YES)];
        }
    }];
}

- (void)relayoutSearchBar {
    [self.apiOutputView.superview layoutIfNeeded];
    [self animateSearchBarDisplay:!self.apiOutputView.frame.origin.y];
}

- (void)animateSearchBarDisplay:(BOOL)shouldDisplay {
    
    if (!shouldDisplay) {
        [self.searchBar resignFirstResponder];
    }
    
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionLayoutSubviews |
                                              UIViewAnimationOptionBeginFromCurrentState |
                                              UIViewAnimationOptionAllowAnimatedContent;
    
    animationOptions |= shouldDisplay ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn;
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0
        options:animationOptions
        animations:^{
            if (shouldDisplay) {
                [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.apiRecordContainer);
                }];
            } else {
                [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.apiRecordContainer).with.offset(-40);
                }];
            }
            [self.searchBar.superview layoutIfNeeded];
        }
        completion:^(BOOL finished) {
            if (finished && shouldDisplay) {
                [self.searchBar becomeFirstResponder];
            }
    }];
}

- (void)addAPIRecordPortObserve {
    RAC(self.apiOutputView, attributedText) = [[[RACObserve([TDFSDAPIRecorder sharedInstance], descriptionModels)
    skip:1]
    map:^id _Nullable(NSArray<__kindof TDFALBaseModel<TDFSDAPIRecordCharacterizationProtocol> *> *descriptionModels) {
        return [[descriptionModels.rac_sequence
               map:^id _Nullable(__kindof TDFALBaseModel<TDFSDAPIRecordCharacterizationProtocol> * _Nullable descriptionModel) {
                   
                   // mark `TDFALRequestModel` instances messageRead to YES
                   if ([descriptionModel isKindOfClass:[TDFALRequestModel class]]) {
                       [(TDFALRequestModel *)descriptionModel setMessageRead:YES];
                   }
                   return descriptionModel.outputCharacterizationString;
               }]
               foldLeftWithStart:[[NSMutableAttributedString alloc] initWithString:@""]
               reduce:^id _Nullable(NSMutableAttributedString * _Nullable accumulator, NSAttributedString * _Nullable value) {
                   return ((void)([accumulator appendAttributedString:value]),
                           (void)([accumulator appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]]),
                           accumulator);
               }];
    }]
    deliverOnMainThread];
    
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
        [self sendClearRemindLabelTextRequestWithContentType:SDAllReadNotificationContentTypeAPIRecord];
    }];
}

- (void)fetchAlreadyExistRecord {
    self.apiOutputView.attributedText = [[[TDFSDAPIRecorder sharedInstance].descriptionModels.rac_sequence
    map:^id _Nullable(__kindof TDFALBaseModel<TDFSDAPIRecordCharacterizationProtocol> * _Nullable descriptionModel) {
        
        // mark `TDFALRequestModel` instances messageRead to YES
        if ([descriptionModel isKindOfClass:[TDFALRequestModel class]]) {
            [(TDFALRequestModel *)descriptionModel setMessageRead:YES];
        }
        return descriptionModel.outputCharacterizationString;
    }]
    foldLeftWithStart:[[NSMutableAttributedString alloc] initWithString:@""]
    reduce:^id _Nullable(NSMutableAttributedString * _Nullable accumulator, NSAttributedString * _Nullable value) {
        return ((void)([accumulator appendAttributedString:value]),
                (void)([accumulator appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]]),
                accumulator);
    }];
}

- (void)searchNextMatch {
    [self searchKeywordsWithDirection:ICTextViewSearchDirectionForward];
}

- (void)searchPreviousMatch {
    [self searchKeywordsWithDirection:ICTextViewSearchDirectionBackward];
}

- (void)searchKeywordsWithDirection:(ICTextViewSearchDirection)direction {
    NSString *keywords = self.searchBar.text;
    if (keywords.length) {
        [self.apiOutputView scrollToMatch:keywords searchDirection:direction];
    } else {
        [self.apiOutputView resetSearch];
    }
    [self updateSearchMatchStatistics];
}

- (void)updateSearchMatchStatistics {
    self.searchBar.currentSearchIndex = self.apiOutputView.indexOfFoundString != NSNotFound ? self.apiOutputView.indexOfFoundString + 1 : 0;
    self.searchBar.searchResultTotalCount = self.apiOutputView.numberOfMatches != NSNotFound ? self.apiOutputView.numberOfMatches : 0;
}

#pragma mark - getter
- (UIView *)apiRecordContainer {
    if (!_apiRecordContainer) {
        _apiRecordContainer = [[UIView alloc] init];
        _apiRecordContainer.backgroundColor = [UIColor clearColor];
        _apiRecordContainer.userInteractionEnabled = YES;
        _apiRecordContainer.clipsToBounds = YES;
    }
    return _apiRecordContainer;
}

- (TDFSDTextView *)apiOutputView {
    if (!_apiOutputView) {
        _apiOutputView = [[TDFSDTextView alloc] init];
    }
    return _apiOutputView;
}

- (TDFSDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[TDFSDSearchBar alloc] init];
        _searchBar.hitTestView = self.apiOutputView;
        _searchBar.delegate = self;
        _searchBar.previousProxy = [RACSubject subject];
        _searchBar.nextProxy = [RACSubject subject];
        @weakify(self)
        [_searchBar.previousProxy subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            [self searchPreviousMatch];
        }];
        [_searchBar.nextProxy subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            [self searchNextMatch];
        }];
    }
    return _searchBar;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _loadingView;
}

@end
