//
//  TDFSDOverallSettingController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/14.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDOverallSettingController.h"
#import "TDFSDSettingCollectionCell.h"
#import "TDFSDPersistenceSetting.h"
#import "TDFSDCustomizedFlowLayout.h"
#import "TDFSDSettingCollectionViewModel.h"
#import "UICollectionView+ScreenDebugger.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDOverallSettingController () <TDFSDFullScreenConsoleControllerInheritProtocol,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
SDSettingCollectionCellOptionPickerDelegate>

@property (nonatomic, strong) UICollectionView *settingListView;
@property (nonatomic, strong) NSArray<TDFSDSettingCollectionViewModel *> *settingItems;
@property (nonatomic, strong) UITableView *optionPickerView;

@end

@implementation TDFSDOverallSettingController

- (void)viewDidLoad {
    [self initializeSettings];
    [self.settingListView registerClass:[TDFSDSettingCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([TDFSDSettingCollectionCell class])];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.settingListView sd_triggleWithLoadAnimation];
}

- (void)initializeSettings {
    self.settingItems = [[[[TDFSDPersistenceSetting sharedInstance] settingList].rac_sequence map:^id _Nullable(NSDictionary<NSString *, id> * _Nullable value) {
        TDFSDSettingCollectionViewModel *viewModel = [[TDFSDSettingCollectionViewModel alloc] initWithSettingDictionary:value];
        return viewModel;
    }] array];
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"Debugger Settings";
}

- (UIView *)contentViewForFullScreenConsole {
    return self.settingListView;
}

- (NSArray<TDFSDFunctionMenuItem *> *)functionMenuItemsForFullScreenConsole {
    if (!self.menuItems) {
        __weak TDFSDPersistenceSetting *weak_setting = [TDFSDPersistenceSetting sharedInstance];
        @weakify(self)
        return @[ [TDFSDFunctionMenuItem itemWithImage:SD_BUNDLE_IMAGE(@"icon_screenDebugger_update_setting")
                                         actionHandler:^(TDFSDFunctionMenuItem *item) {
                                             @strongify(self)
                                             [self presentLoadingHUDWithText:@"save to sandbox..." syncTransaction:^NSString *{
                                                 [NSKeyedArchiver archiveRootObject:weak_setting toFile:SD_OVERALL_SETTING_CACHE_FIFLE_PATH];
                                                 return @"success";
                                             }];
                                         }] ];
    }
    return self.menuItems;
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.settingItems.count ?: 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDSettingCollectionCell *cell = [TDFSDSettingCollectionCell cellWithCollectionView:collectionView indexPath:indexPath type:self.settingItems[indexPath.row].type];
    cell.optionDelegate = self;
    [cell renderWithTitle:self.settingItems[indexPath.row].settingTitle description:self.settingItems[indexPath.row].settingDescription settingOptionValue:settingValueForIndexPath(indexPath)];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDSettingCollectionViewModel *viewModel = self.settingItems[indexPath.row];
    return CGSizeMake(viewModel.cellWidth, viewModel.cellHeight);
}

#pragma mark - SDSettingCollectionCellOptionPickerDelegate
- (void)pickerButtonDidClickWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了选择按钮");
}

- (void)switchValueDidChangeManually:(BOOL)isOn withIndexPath:(NSIndexPath *)indexPath {
    updateSettingValueWithIndexPath(@(isOn), indexPath);
}

#pragma mark - getter
- (UICollectionView *)settingListView {
    if (!_settingListView) {
        _settingListView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self flowLayout]];
        _settingListView.backgroundColor = [UIColor clearColor];
        _settingListView.showsVerticalScrollIndicator = NO;
        _settingListView.showsHorizontalScrollIndicator = NO;
        _settingListView.scrollEnabled = YES;
        _settingListView.alwaysBounceVertical = YES;
        _settingListView.dataSource = self;
        _settingListView.delegate = self;
    }
    return _settingListView;
}

- (TDFSDCustomizedFlowLayout *)flowLayout {
    TDFSDCustomizedFlowLayout *flowLayout = [[TDFSDCustomizedFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    CGFloat itemLineMargin = 15;
    CGFloat itemCollectionEdgeMargin = 5;
    flowLayout.minimumLineSpacing = itemLineMargin;
    flowLayout.minimumInteritemSpacing = itemCollectionEdgeMargin;
    flowLayout.sectionInset = UIEdgeInsetsMake(itemLineMargin, itemCollectionEdgeMargin, itemLineMargin, itemCollectionEdgeMargin);
    return flowLayout;
}

#pragma mark - private
static id settingValueForIndexPath(NSIndexPath *indexPath) {
    TDFSDPersistenceSetting *ps = [TDFSDPersistenceSetting sharedInstance];
    switch (indexPath.row) {
        case 0:{
            switch (ps.messageRemindType) {
                case SDMessageRemindTypeAPIRecord:{
                    return @"api record";
                } break;
                case SDMessageRemindTypeSystemLog:{
                    return @"system log";
                } break;
            }
        } break;
        case 1:{ return @(ps.allowCatchAPIRecordFlag); } break;
        case 2:{ return @(ps.allowMonitorSystemLogFlag); } break;
        case 3:{ return @(ps.limitSizeOfSingleSystemLogMessageData).stringValue; } break;
        case 4:{ return @(ps.allowCrashCaptureFlag); } break;
        case 5:{ return @(ps.needCacheCrashLogToSandBox); } break;
        case 6:{ return @(ps.allowUILagsMonitoring); } break;
        case 7:{ return [NSString stringWithFormat:@"%.1f", ps.tolerableLagThreshold]; } break;
        case 8:{ return @(ps.allowApplicationCPUMonitoring); } break;
        case 9:{ return @(ps.allowApplicationMemoryMonitoring); } break;
        case 10:{ return @(ps.allowScreenFPSMonitoring); } break;
        case 11:{ return @(ps.fpsWarnningThreshold).stringValue; } break;
        case 12:{ return @(ps.allowWildPointerMonitoring); } break;
    }
    return nil;
}

static void updateSettingValueWithIndexPath(id newValue, NSIndexPath *indexPath) {
    TDFSDPersistenceSetting *ps = [TDFSDPersistenceSetting sharedInstance];
    switch (indexPath.row) {
        case 0:{
            if ([newValue isEqualToString:@"api record"]) {
                ps.messageRemindType = SDMessageRemindTypeAPIRecord;
            } else if ([newValue isEqualToString:@"system log"]) {
                ps.messageRemindType = SDMessageRemindTypeSystemLog;
            }
        } break;
        case 1:{ ps.allowCatchAPIRecordFlag = [newValue boolValue]; } break;
        case 2:{ ps.allowMonitorSystemLogFlag = [newValue boolValue]; } break;
        case 3:{ ps.limitSizeOfSingleSystemLogMessageData = [newValue integerValue]; } break;
        case 4:{ ps.allowCrashCaptureFlag = [newValue boolValue]; } break;
        case 5:{ ps.needCacheCrashLogToSandBox = [newValue boolValue]; } break;
        case 6:{ ps.allowUILagsMonitoring = [newValue boolValue]; } break;
        case 7:{ ps.tolerableLagThreshold = [newValue doubleValue]; } break;
        case 8:{ ps.allowApplicationCPUMonitoring = [newValue boolValue]; } break;
        case 9:{ ps.allowApplicationMemoryMonitoring = [newValue boolValue]; } break;
        case 10:{ ps.allowScreenFPSMonitoring = [newValue boolValue]; } break;
        case 11:{ ps.fpsWarnningThreshold = [newValue integerValue]; } break;
        case 12:{ ps.allowWildPointerMonitoring = [newValue boolValue]; } break;
    }
}

@end
