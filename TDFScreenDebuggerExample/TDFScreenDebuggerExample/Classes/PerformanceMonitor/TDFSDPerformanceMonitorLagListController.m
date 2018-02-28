//
//  TDFSDPerformanceMonitorLagListController.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/26.
//

#import "TDFSDPerformanceMonitorLagListController.h"
#import "TDFSDPerformanceMonitorLagDetailController.h"
#import "TDFSDPerformanceMonitor.h"
#import "TDFSDCustomizedFlowLayout.h"
#import "TDFSDPMUILagCollectionCell.h"
#import "TDFSDPMUILagCollectionViewModel.h"
#import "UICollectionView+ScreenDebugger.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface TDFSDPerformanceMonitorLagListController () <TDFSDFullScreenConsoleControllerInheritProtocol,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *cachedLagListView;
@property (nonatomic, strong) TDFSDCustomizedFlowLayout *flowLayout;
@property (nonatomic, strong) NSArray<TDFSDPMUILagCollectionViewModel *> *viewModels;

@end

@implementation TDFSDPerformanceMonitorLagListController

#pragma mark - life cycle
- (void)viewDidLoad {
    [self.cachedLagListView registerClass:[TDFSDPMUILagCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([TDFSDPMUILagCollectionCell class])];
    [self observeUILags];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.cachedLagListView sd_triggleWithLoadAnimation];
}

#pragma mark - private
- (void)observeUILags {
    @weakify(self)
    [[RACObserve([TDFSDPerformanceMonitor sharedInstance], uiLags)
      map:^id _Nullable(NSArray<TDFSDPMUILagComponentModel *> * _Nullable lags) {
          return [[lags.reverseObjectEnumerator.allObjects.rac_sequence
                   map:^id _Nullable(TDFSDPMUILagComponentModel * _Nullable lag) {
                       TDFSDPMUILagCollectionViewModel *viewModel = [[TDFSDPMUILagCollectionViewModel alloc] init];
                       viewModel.lagModel = lag;
                       return viewModel;
                   }]
                  array];
     }]
     subscribeNext:^(NSArray<TDFSDPMUILagCollectionViewModel *> * _Nullable viewModels) {
         @strongify(self)
         self.viewModels = viewModels;
         [self.cachedLagListView sd_safeReloadDataIfUseCustomLayout];
     }];
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"UI Thread Lags";
}

- (UIView *)contentViewForFullScreenConsole {
    return self.cachedLagListView;
}

- (NSArray<TDFSDFunctionMenuItem *> *)functionMenuItemsForFullScreenConsole {
    if (!self.menuItems) {
        return @[ [TDFSDFunctionMenuItem itemWithImage:[UIImage imageNamed:@"icon_screenDebugger_trash"]
                                         actionHandler:^(TDFSDFunctionMenuItem *item) {
                                             [[TDFSDPerformanceMonitor sharedInstance] clearAllCachedUILags];
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
    TDFSDPMUILagCollectionCell *cell = [TDFSDPMUILagCollectionCell cellWithCollectionView:collectionView indexPath:indexPath];
    [cell bindWithViewModel:self.viewModels[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDPMUILagCollectionViewModel *viewModel = self.viewModels[indexPath.row];
    TDFSDPerformanceMonitorLagDetailController *detail = [[TDFSDPerformanceMonitorLagDetailController alloc] init];
    detail.lag = viewModel.lagModel;
    detail.transitioningDelegate = self;
    [self presentViewController:detail animated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDPMUILagCollectionViewModel *viewModel = self.viewModels[indexPath.row];
    return CGSizeMake(viewModel.cellWidth-1, viewModel.cellHeight);
}

#pragma mark - getter
- (UICollectionView *)cachedLagListView {
    if (!_cachedLagListView) {
        _cachedLagListView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _cachedLagListView.backgroundColor = [UIColor clearColor];
        _cachedLagListView.showsVerticalScrollIndicator = YES;
        _cachedLagListView.showsHorizontalScrollIndicator = NO;
        _cachedLagListView.scrollEnabled = YES;
        _cachedLagListView.alwaysBounceVertical = YES;
        _cachedLagListView.dataSource = self;
        _cachedLagListView.delegate = self;
    }
    return _cachedLagListView;
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
