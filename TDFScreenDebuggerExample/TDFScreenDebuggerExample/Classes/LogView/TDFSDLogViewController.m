//
//  TDFSDLogViewController.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/5.
//

#import "TDFSDLogViewController.h"
#import "TDFSDSearchBar.h"
#import "TDFSDTextView.h"
#import "TDFSDLogViewer.h"
#import "TDFSDLVLogModel.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDLogViewController () <TDFSDFullScreenConsoleControllerInheritProtocol, UISearchBarDelegate>

@property (nonatomic, strong) UIView *systemLogContainer;
@property (nonatomic, strong) TDFSDTextView *logOutputView;
@property (nonatomic, strong) TDFSDSearchBar *searchBar;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation TDFSDLogViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutPageSubviews];
    [self addSystemLogPortObserve];
    [self addKeyboardObserve];
    [self.loadingView startAnimating];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // if too large text content presented in UITextView, it will get stuck during `viewDidLoad`
    // so finally I decide to put fetch text and presentation operation code in `viewDidAppear`
    [self fetchSystemLogs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // textview loading large log-text sometimes consumes too much memory even lead to come up memory performance crysis
    // if happened, we will clear all the current record to save memory problems
    [[TDFSDLogViewer sharedInstance] clearCurrentSystemLogs];
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"Log View";
}

- (UIView *)contentViewForFullScreenConsole {
    return self.systemLogContainer;
}

- (NSArray<TDFSDFunctionMenuItem *> *)functionMenuItemsForFullScreenConsole {
    if (!self.menuItems) {
        @weakify(self)
        return @[
                 [TDFSDFunctionMenuItem itemWithImage:[UIImage imageNamed:@"icon_screenDebugger_search"]
                                        actionHandler:^(TDFSDFunctionMenuItem *item) {
                                            // self->strong menuItems->strong item->self
                                            @strongify(self)
                                            [self relayoutSearchBar];
                                        }],
                 [TDFSDFunctionMenuItem itemWithImage:[UIImage imageNamed:@"icon_screenDebugger_trash"]
                                        actionHandler:^(TDFSDFunctionMenuItem *item) {
                                            [[TDFSDLogViewer sharedInstance] clearCurrentSystemLogs];
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
    
    [self.systemLogContainer addSubview:self.searchBar];
    [self.systemLogContainer addSubview:self.logOutputView];
    [self.container addSubview:self.loadingView];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.systemLogContainer).with.offset(-40);
        make.left.and.right.equalTo(self.systemLogContainer);
        make.height.equalTo(@28);
    }];
    [self.logOutputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.bottom.equalTo(self.systemLogContainer);
        make.top.equalTo(self.searchBar.mas_bottom).with.offset(12);
    }];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.systemLogContainer);
        make.width.and.height.equalTo(@44);
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
         
         self.logOutputView.contentInset = contentInsets;
         self.logOutputView.scrollIndicatorInsets = contentInsets;
         
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
    [self.logOutputView.superview layoutIfNeeded];
    [self animateSearchBarDisplay:!self.logOutputView.frame.origin.y];
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
                     make.top.equalTo(self.systemLogContainer);
                 }];
             } else {
                 [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
                     make.top.equalTo(self.systemLogContainer).with.offset(-40);
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

- (void)addSystemLogPortObserve {
    RAC(self.logOutputView, attributedText) = [[[RACObserve([TDFSDLogViewer sharedInstance], logs)
    skip:1]
    map:^id _Nullable(NSArray<TDFSDLVLogModel *> * _Nullable logModels) {
        return [[logModels.rac_sequence
                map:^id _Nullable(TDFSDLVLogModel * _Nullable logModel) {
                    [logModel setMessageRead:YES];
                    return ({
                        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:logModel.description];
                        [mas addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:11], NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, logModel.description.length)];
                        mas;
                    });
                }]
                foldLeftWithStart:[[NSMutableAttributedString alloc] initWithString:@""]
                reduce:^id _Nullable(NSMutableAttributedString * _Nullable accumulator, NSAttributedString * _Nullable value) {
                    return ([accumulator appendAttributedString:value],
                            accumulator);
                }];
    }]
    deliverOnMainThread];
    
    @weakify(self)
    [[[[[RACObserve(self.logOutputView, attributedText)
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
        [self.logOutputView scrollRangeToVisible:NSMakeRange(self.logOutputView.attributedText.length, 1)];
        [self sendClearRemindLabelTextRequestWithContentType:SDAllReadNotificationContentTypeSystemLog];
    }];
}

- (void)fetchSystemLogs {
    self.logOutputView.attributedText = \
    [[[[TDFSDLogViewer sharedInstance] logs].rac_sequence
    map:^id _Nullable(TDFSDLVLogModel * _Nullable value) {
        return ({
            NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:value.description];
            [mas addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:11], NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, value.description.length)];
            mas;
        });
    }]
    foldLeftWithStart:[[NSMutableAttributedString alloc] initWithString:@""] reduce:^id _Nullable(NSMutableAttributedString * _Nullable accumulator, NSAttributedString * _Nullable value) {
        return ([accumulator appendAttributedString:value],
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
        [self.logOutputView scrollToMatch:keywords searchDirection:direction];
    } else {
        [self.logOutputView resetSearch];
    }
    [self updateSearchMatchStatistics];
}

- (void)updateSearchMatchStatistics {
    self.searchBar.currentSearchIndex = self.logOutputView.indexOfFoundString != NSNotFound ? self.logOutputView.indexOfFoundString + 1 : 0;
    self.searchBar.searchResultTotalCount = self.logOutputView.numberOfMatches != NSNotFound ? self.logOutputView.numberOfMatches : 0;
}

#pragma mark - getter
- (UIView *)systemLogContainer {
    if (!_systemLogContainer) {
        _systemLogContainer = [[UIView alloc] init];
        _systemLogContainer.backgroundColor = [UIColor clearColor];
        _systemLogContainer.userInteractionEnabled = YES;
        _systemLogContainer.clipsToBounds = YES;
    }
    return _systemLogContainer;
}

- (TDFSDTextView *)logOutputView {
    if (!_logOutputView) {
        _logOutputView = [[TDFSDTextView alloc] init];
    }
    return _logOutputView;
}

- (TDFSDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[TDFSDSearchBar alloc] init];
        _searchBar.hitTestView = self.logOutputView;
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
