//
//  TDFSDAPIRecordSelectableController.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/27.
//
//

#import "TDFSDAPIRecordSelectableController.h"
#import "TDFSDCustomizedFlowLayout.h"
#import "TDFSDARCollectionViewCell.h"
#import "TDFSDAPIRecorder.h"
#import "TDFALRequestModel+APIRecord.h"
#import "TDFSDARCollectionViewModel.h"
#import "UICollectionView+ScreenDebugger.h"
#import "TDFSDAPIRecordBindingDetailController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface TDFSDAPIRecordSelectableController () <TDFSDFullScreenConsoleControllerInheritProtocol,
                                                  UICollectionViewDataSource,
                                                  UICollectionViewDelegate,
                                                  UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *apiRequestListView;
@property (nonatomic, strong) TDFSDCustomizedFlowLayout *flowLayout;
@property (nonatomic, strong) NSArray<TDFSDARCollectionViewModel *> *viewModels;

@end


@implementation TDFSDAPIRecordSelectableController

#pragma mark - life cycle
- (void)viewDidLoad {
    [self.apiRequestListView registerClass:[TDFSDARCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TDFSDARCollectionViewCell class])];
    [super viewDidLoad];
    [self observeAPIRequests];
}

#pragma mark - private
- (void)observeAPIRequests {
    @weakify(self)
    [[RACObserve([TDFSDAPIRecorder sharedInstance], requestDesModels)
    map:^id _Nullable(NSArray<TDFALRequestModel *> * _Nullable requests) {
        return [[requests.reverseObjectEnumerator.allObjects.rac_sequence
               map:^id _Nullable(TDFALRequestModel * _Nullable value) {
                   
                   // mark `TDFALRequestModel` instances messageRead to YES
                   [value setMessageRead:YES];
                   
                   TDFSDARCollectionViewModel *viewModel = [[TDFSDARCollectionViewModel alloc] init];
                   viewModel.requestModel = value;
                   return viewModel;
               }]
               array];
    }]
    subscribeNext:^(NSArray<TDFSDARCollectionViewModel *> * _Nullable viewModels) {
        @strongify(self)
        self.viewModels = viewModels;
        [self.apiRequestListView sd_safeReloadDataIfUseCustomLayout];
        [self sendClearRemindLabelTextRequestWithContentType:SDAllReadNotificationContentTypeAPIRecord];
    }];
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"API Record";
}

- (__kindof UIView *)contentViewForFullScreenConsole {
    return self.apiRequestListView;
}

- (NSArray<TDFSDFunctionMenuItem *> *)functionMenuItemsForFullScreenConsole {
    if (!self.menuItems) {
        return @[ [TDFSDFunctionMenuItem itemWithImage:[UIImage imageNamed:@"icon_screenDebugger_trash"]
                     actionHandler:^(TDFSDFunctionMenuItem *item) {
                         [[TDFSDAPIRecorder sharedInstance] clearAllRecords];
                     }] ];
    }
    return self.menuItems;
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModels.count ?: 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDARCollectionViewCell *cell = [TDFSDARCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
    [cell bindWithViewModel:self.viewModels[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDARCollectionViewModel *viewModel = self.viewModels[indexPath.row];
    TDFSDAPIRecordBindingDetailController *detail = [[TDFSDAPIRecordBindingDetailController alloc] init];
    detail.req = viewModel.requestModel;
    detail.transitioningDelegate = self;
    [self presentViewController:detail animated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDARCollectionViewModel *viewModel = self.viewModels[indexPath.row];
    return CGSizeMake(viewModel.cellWidth, viewModel.cellHeight);
}

#pragma mark - getter
- (UICollectionView *)apiRequestListView {
    if (!_apiRequestListView) {
        _apiRequestListView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _apiRequestListView.backgroundColor = [UIColor clearColor];
        _apiRequestListView.showsVerticalScrollIndicator = YES;
        _apiRequestListView.showsHorizontalScrollIndicator = NO;
        _apiRequestListView.scrollEnabled = YES;
        _apiRequestListView.alwaysBounceVertical = YES;
        _apiRequestListView.dataSource = self;
        _apiRequestListView.delegate = self;
    }
    return _apiRequestListView;
}

- (TDFSDCustomizedFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[TDFSDCustomizedFlowLayout alloc] init];
        [_flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        CGFloat itemLineMargin = 10;
        CGFloat itemCollectionEdgeMargin = 8;
        _flowLayout.minimumLineSpacing = itemLineMargin;
        _flowLayout.minimumInteritemSpacing = itemCollectionEdgeMargin;
        _flowLayout.sectionInset = UIEdgeInsetsMake(itemLineMargin, itemCollectionEdgeMargin, itemLineMargin, itemCollectionEdgeMargin);
    }
    return _flowLayout;
}

@end
