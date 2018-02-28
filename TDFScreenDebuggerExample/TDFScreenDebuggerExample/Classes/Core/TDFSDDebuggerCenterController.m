//
//  TDFSDDebuggerCenterController.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/20.
//
//

#import "TDFSDDebuggerCenterController.h"
#import "TDFSDCustomizedFlowLayout.h"
#import "TDFSDFunctionCollectionViewCell.h"
#import "TDFSDOverallSettingController.h"
#import "TDFSDPersistenceSetting.h"
#import "TDFSDFunctionCollectionViewModel.h"
#import "UICollectionView+ScreenDebugger.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface TDFSDDebuggerCenterController () <TDFSDFullScreenConsoleControllerInheritProtocol,
                                             UICollectionViewDataSource,
                                             UICollectionViewDelegate,
                                             UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *functionCollectionView;
@property (nonatomic, strong) TDFSDCustomizedFlowLayout *flowLayout;
@property (nonatomic, strong) NSArray<TDFSDFunctionCollectionViewModel *> *viewModels;

@end


@implementation TDFSDDebuggerCenterController

#pragma mark - life cycle
- (void)viewDidLoad {
    [self fetchCollectionViewModels];
    [self.functionCollectionView registerClass:[TDFSDFunctionCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TDFSDFunctionCollectionViewCell class])];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.functionCollectionView sd_triggleWithLoadAnimation];
}

#pragma mark - private
- (void)fetchCollectionViewModels {
    self.viewModels = \
    (NSArray<TDFSDFunctionCollectionViewModel *> *)[[[TDFSDPersistenceSetting sharedInstance].functionList.rac_sequence
    map:^id _Nullable(TDFSDFunctionModel * _Nullable value) {
        TDFSDFunctionCollectionViewModel *viewModel = [[TDFSDFunctionCollectionViewModel alloc] init];
        viewModel.function = value;
        return viewModel;
    }]
    array];
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"Debugger Center";
}

- (__kindof UIView *)contentViewForFullScreenConsole {
    return self.functionCollectionView;
}

- (NSArray<TDFSDFunctionMenuItem *> *)functionMenuItemsForFullScreenConsole {
    if (!self.menuItems) {
        @weakify(self)
        return @[ [TDFSDFunctionMenuItem itemWithImage:[UIImage imageNamed:@"icon_screenDebugger_Setting"]
                    actionHandler:^(TDFSDFunctionMenuItem *item) {
                        // self->strong menuItems->strong item->self
                        @strongify(self)
                        TDFSDOverallSettingController *setting = [[TDFSDOverallSettingController alloc] init];
                        setting.transitioningDelegate = self;
                        [self presentViewController:setting animated:YES completion:nil];
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
    TDFSDFunctionCollectionViewCell *cell = [TDFSDFunctionCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
    [cell bindWithViewModel:self.viewModels[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDFunctionCollectionViewModel *viewModel = self.viewModels[indexPath.row];
    [viewModel.jumpCommand execute:self];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDFunctionCollectionViewModel *viewModel = self.viewModels[indexPath.row];
    return CGSizeMake(viewModel.cellWidth-1, viewModel.cellHeight);
}

#pragma mark - getter
- (UICollectionView *)functionCollectionView {
    if (!_functionCollectionView) {
        _functionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _functionCollectionView.backgroundColor = [UIColor clearColor];
        _functionCollectionView.showsVerticalScrollIndicator = NO;
        _functionCollectionView.showsHorizontalScrollIndicator = NO;
        _functionCollectionView.scrollEnabled = YES;
        _functionCollectionView.alwaysBounceVertical = YES;
        _functionCollectionView.dataSource = self;
        _functionCollectionView.delegate = self;
    }
    return _functionCollectionView;
}

- (TDFSDCustomizedFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[TDFSDCustomizedFlowLayout alloc] init];
        [_flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        CGFloat itemLineMargin = 20;
        CGFloat itemCollectionEdgeMargin = 15;
        _flowLayout.minimumLineSpacing = itemLineMargin;
        _flowLayout.minimumInteritemSpacing = itemCollectionEdgeMargin;
        _flowLayout.sectionInset = UIEdgeInsetsMake(itemLineMargin, itemCollectionEdgeMargin, itemLineMargin, itemCollectionEdgeMargin);
    }
    return _flowLayout;
}


@end
