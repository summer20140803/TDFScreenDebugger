//
//  TDFSDCrashCaptureHistoryController.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/16.
//

#import "TDFSDCrashCaptureHistoryController.h"
#import "TDFSDCrashCaptor.h"
#import "TDFSDCustomizedFlowLayout.h"
#import "TDFSDCCCollectionViewCell.h"
#import "TDFSDCCCollectionViewModel.h"
#import "TDFSDCrashCaptureDetailController.h"
#import "UICollectionView+ScreenDebugger.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface TDFSDCrashCaptureHistoryController () <TDFSDFullScreenConsoleControllerInheritProtocol,
                                                  UICollectionViewDataSource,
                                                  UICollectionViewDelegate,
                                                  UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *crashHistoryListView;
@property (nonatomic, strong) TDFSDCustomizedFlowLayout *flowLayout;
@property (nonatomic, strong) NSArray<TDFSDCCCollectionViewModel *> *viewModels;

@end

@implementation TDFSDCrashCaptureHistoryController

#pragma mark - life cycle
- (void)viewDidLoad {
    [self fetchCrashHistory];
    [self.crashHistoryListView registerClass:[TDFSDCCCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TDFSDCCCollectionViewCell class])];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.crashHistoryListView sd_triggleWithLoadAnimation];
}

- (void)fetchCrashHistory {
    NSString *cachePath = SD_CRASH_CAPTOR_CACHE_MODEL_ARCHIVE_PATH;
    NSMutableArray *cacheCrashModels = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    if (cacheCrashModels.count) {
        self.viewModels = \
        [[cacheCrashModels.rac_sequence map:^id _Nullable(TDFSDCCCrashModel * _Nullable model) {
            TDFSDCCCollectionViewModel *viewModel = [[TDFSDCCCollectionViewModel alloc] init];
            viewModel.crashModel = model;
            return viewModel;
        }] array];
    }
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"Crash History";
}

- (UIView *)contentViewForFullScreenConsole {
    return self.crashHistoryListView;
}

- (NSArray<TDFSDFunctionMenuItem *> *)functionMenuItemsForFullScreenConsole {
    if (!self.menuItems) {
        return @[ [TDFSDFunctionMenuItem itemWithImage:[UIImage imageNamed:@"icon_screenDebugger_trash"]
                      actionHandler:^(TDFSDFunctionMenuItem *item) {
                          [[TDFSDCrashCaptor sharedInstance] clearHistoryCrashLog];
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
    TDFSDCCCollectionViewCell *cell = [TDFSDCCCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
    [cell bindWithViewModel:self.viewModels[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDCCCollectionViewModel *viewModel = self.viewModels[indexPath.row];
    TDFSDCrashCaptureDetailController *detail = [[TDFSDCrashCaptureDetailController alloc] init];
    detail.crash = viewModel.crashModel;
    detail.transitioningDelegate = self;
    [self presentViewController:detail animated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDCCCollectionViewModel *viewModel = self.viewModels[indexPath.row];
    return CGSizeMake(viewModel.cellWidth-1, viewModel.cellHeight);
}

#pragma mark - getter
- (UICollectionView *)crashHistoryListView {
    if (!_crashHistoryListView) {
        _crashHistoryListView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _crashHistoryListView.backgroundColor = [UIColor clearColor];
        _crashHistoryListView.showsVerticalScrollIndicator = YES;
        _crashHistoryListView.showsHorizontalScrollIndicator = NO;
        _crashHistoryListView.scrollEnabled = YES;
        _crashHistoryListView.alwaysBounceVertical = YES;
        _crashHistoryListView.dataSource = self;
        _crashHistoryListView.delegate = self;
    }
    return _crashHistoryListView;
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
