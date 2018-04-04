//
//  TDFSDPerformanceMonitorToolController.m
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/6.
//

#import "TDFSDPerformanceMonitorToolController.h"
#import "TDFSDTextView.h"
#import "TDFScreenDebuggerDefine.h"
#import "TDFSDPMExtraToolModel.h"
#import "TDFSDPMToolCollectionCell.h"
#import "TDFSDPMWildPointerChecker.h"
#import "UIView+ScreenDebugger.h"
#import "TDFSDCustomizedFlowLayout.h"
#import "UICollectionView+ScreenDebugger.h"
#import "TDFSDPersistenceSetting.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDPerformanceMonitorToolController () <TDFSDFullScreenConsoleControllerInheritProtocol,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *toolListView;
@property (nonatomic, strong) NSArray<TDFSDPMExtraToolModel *> *toolModels;

@end

@implementation TDFSDPerformanceMonitorToolController

#pragma mark - life cycle
- (void)viewDidLoad {
    [self initializeTools];
    [self.toolListView registerClass:[TDFSDPMToolCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([TDFSDPMToolCollectionCell class])];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.toolListView sd_triggleWithLoadAnimation];
}

#pragma mark - private
- (void)initializeTools {
    TDFSDPMExtraToolModel *tool = [[TDFSDPMExtraToolModel alloc] init];
    tool.name = @"Wild Pointer Checker";
    tool.toolDescription = @"Help you find out more info about wild pointer causes";
    tool.isOn = [TDFSDPersistenceSetting sharedInstance].allowWildPointerMonitoring;
    tool.realizer = [TDFSDPMWildPointerChecker sharedInstance];
    
    self.toolModels = @[ tool ];
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"Extra Tool Set";
}

- (__kindof UIView *)contentViewForFullScreenConsole {
    return self.toolListView;
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.toolModels.count ?: 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDPMToolCollectionCell *cell = [TDFSDPMToolCollectionCell cellWithCollectionView:collectionView indexPath:indexPath];
    [cell bindWithViewModel:self.toolModels[indexPath.row]];
    @weakify(self)
    cell.toolSwitchDidChangeHandler = ^(NSIndexPath *indexPath, BOOL isOn) {
        @strongify(self)
        TDFSDPMExtraToolModel *tool = self.toolModels[indexPath.row];
        if (isOn) {
            [self presentLoadingHUDWithText:@"apply to application..." syncTransaction:^NSString *{
                [tool.realizer thaw];
                return @"success";
            }];
        } else {
            [tool.realizer freeze];
        }
        tool.isOn = isOn;
        [TDFSDPersistenceSetting sharedInstance].allowWildPointerMonitoring = isOn;
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - SDFullScreenContentViewEdgeMargin * 2 - 10 - 1, 80);
}

#pragma mark - getter
- (UICollectionView *)toolListView {
    if (!_toolListView) {
        _toolListView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self flowLayout]];
        _toolListView.backgroundColor = [UIColor clearColor];
        _toolListView.showsVerticalScrollIndicator = NO;
        _toolListView.showsHorizontalScrollIndicator = NO;
        _toolListView.scrollEnabled = YES;
        _toolListView.alwaysBounceVertical = YES;
        _toolListView.dataSource = self;
        _toolListView.delegate = self;
    }
    return _toolListView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    CGFloat itemLineMargin = 10;
    CGFloat itemCollectionEdgeMargin = 5;
    flowLayout.minimumLineSpacing = itemLineMargin;
    flowLayout.minimumInteritemSpacing = itemCollectionEdgeMargin;
    flowLayout.sectionInset = UIEdgeInsetsMake(itemLineMargin, itemCollectionEdgeMargin, itemLineMargin, itemCollectionEdgeMargin);
    return flowLayout;
}

@end
