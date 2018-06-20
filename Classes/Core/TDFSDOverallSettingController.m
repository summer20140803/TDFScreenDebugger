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
#import "TDFSDSettingOptionPickerCell.h"
#import "TDFSDWildPointerChecker.h"
#import "UICollectionView+ScreenDebugger.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface TDFSDOverallSettingController () <TDFSDFullScreenConsoleControllerInheritProtocol,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UITableViewDataSource,
UITableViewDelegate,
SDSettingCollectionCellOptionPickerDelegate>

@property (nonatomic, strong) UICollectionView *settingListView;
@property (nonatomic, strong) NSArray<TDFSDSettingCollectionViewModel *> *settingItems;

@property (nonatomic, strong) UITableView *optionPickerView;
@property (nonatomic, strong) UIControl *pickerMaskView;
@property (nonatomic, strong) NSArray *currentPickerOptions;
@property (nonatomic, assign) NSUInteger currentPickerIndex;

@end

@implementation TDFSDOverallSettingController

static const CGFloat kSDSettingOptionPickerCellHeight  =  40.0f;

- (void)viewDidLoad {
    [self initializeSettings];
    [self.settingListView registerClass:[TDFSDSettingCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([TDFSDSettingCollectionCell class])];
    [super viewDidLoad];
    [self layoutPageSubviews];
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
    return SD_STRING(@"Debugger Settings");
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
                                             [self presentLoadingHUDWithText:SD_STRING(@"save to sandbox...") syncTransaction:^NSString *{
                                                 [NSKeyedArchiver archiveRootObject:weak_setting toFile:SD_OVERALL_SETTING_CACHE_FIFLE_PATH];
                                                 return SD_STRING(@"success");
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

#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.currentPickerOptions.count ?: 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TDFSDSettingOptionPickerCell *cell = [TDFSDSettingOptionPickerCell cellWithTableView:tableView indexPath:indexPath];
    TDFSDSettingCollectionViewModel *item = self.settingItems[self.currentPickerIndex];
    @weakify(self)
    [cell bindWithOptionTitle:SD_STRING(item.optionalValues[indexPath.section]) optionDidPickHandler:^(NSIndexPath *indexPath, NSString *pickValue) {
        @strongify(self)
        updateSettingValueWithIndex(pickValue, self.currentPickerIndex);
        [self popPickerView];
        [self.settingListView sd_safeReloadDataIfUseCustomLayout];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSDSettingOptionPickerCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

#pragma mark - SDSettingCollectionCellOptionPickerDelegate
- (void)pickerButtonDidClickWithIndexPath:(NSIndexPath *)indexPath {
    self.currentPickerIndex = indexPath.row;
    [self pushPickerViewWithIndexPath:indexPath];
}

- (void)switchValueDidChangeManually:(BOOL)isOn withIndexPath:(NSIndexPath *)indexPath {
    updateSettingValueWithIndex(@(isOn), indexPath.row);
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

- (UITableView *)optionPickerView {
    if (!_optionPickerView) {
        _optionPickerView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _optionPickerView.backgroundColor = [UIColor clearColor];
        _optionPickerView.showsHorizontalScrollIndicator = NO;
        _optionPickerView.showsVerticalScrollIndicator = NO;
        _optionPickerView.dataSource = self;
        _optionPickerView.delegate = self;
        _optionPickerView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _optionPickerView;
}

- (UIControl *)pickerMaskView {
    if (!_pickerMaskView) {
        _pickerMaskView = [[UIControl alloc] init];
        _pickerMaskView.hidden = YES;
        [_pickerMaskView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
        @weakify(self)
        [[_pickerMaskView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self popPickerView];
        }];
    }
    return _pickerMaskView;
}

#pragma mark - private
- (void)layoutPageSubviews {
    [self.view addSubview:self.pickerMaskView];
    [self.view addSubview:self.optionPickerView];
    [self.pickerMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.optionPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_right);
        make.width.equalTo(@100);
        make.centerY.equalTo(self.view);
        make.height.equalTo(@0);
    }];
}

- (void)pushPickerViewWithIndexPath:(NSIndexPath *)indexPath {
    self.pickerMaskView.hidden = NO;
    
    TDFSDSettingCollectionViewModel *item = self.settingItems[indexPath.row];
    CGFloat height = item.optionalValues.count * (kSDSettingOptionPickerCellHeight + 10);
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (height > screenHeight) {
        [self.optionPickerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(screenHeight));
        }];
        self.optionPickerView.scrollEnabled = YES;
    } else {
        [self.optionPickerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(height));
        }];
        self.optionPickerView.scrollEnabled = NO;
    }
    [self.optionPickerView.superview layoutIfNeeded];
    
    self.currentPickerOptions = item.optionalValues;
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.pickerMaskView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.50f]];
        [self.optionPickerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_right).with.offset(-100);
        }];
        [self.optionPickerView.superview layoutIfNeeded];
    } completion:nil];
    
    [self.optionPickerView reloadData];
}

- (void)popPickerView {
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.pickerMaskView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
        [self.optionPickerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_right).with.offset(0);
        }];
        [self.optionPickerView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.pickerMaskView.hidden = YES;
    }];
}

static id settingValueForIndexPath(NSIndexPath *indexPath) {
    TDFSDPersistenceSetting *ps = [TDFSDPersistenceSetting sharedInstance];
    switch (indexPath.row) {
        case 0:{
            switch (ps.messageRemindType) {
                case SDMessageRemindTypeAPIRecord:{
                    return SD_STRING(@"api record");
                } break;
                case SDMessageRemindTypeSystemLog:{
                    return SD_STRING(@"system log");
                } break;
            }
        } break;
        case 1:{ return @(ps.allowCatchAPIRecordFlag); } break;
        case 2:{ return @(ps.allowMonitorSystemLogFlag); } break;
        case 3:{ if (@available(iOS 10_0, *)) { return @(ps.limitSizeOfSingleSystemLogMessageData).stringValue; }} break;
        case 4:{ return @(ps.allowCrashCaptureFlag); } break;
        case 5:{ return @(ps.needCacheCrashLogToSandBox); } break;
        case 6:{ return @(ps.isSafeModeForCrashCapture); } break;
        case 7:{ return @(ps.allowUILagsMonitoring); } break;
        case 8:{ return [NSString stringWithFormat:@"%.2f", ps.tolerableLagThreshold]; } break;
        case 9:{ return @(ps.allowApplicationCPUMonitoring); } break;
        case 10:{ return @(ps.allowApplicationMemoryMonitoring); } break;
        case 11:{ return @(ps.allowScreenFPSMonitoring); } break;
        case 12:{ return @(ps.fpsWarnningThreshold).stringValue; } break;
        case 13:{ return @(ps.allowWildPointerMonitoring); } break;
        case 14:{ return @(ps.maxZombiePoolCapacity).stringValue; } break;
        case 15:{ return @(ps.allowMemoryLeaksDetectionFlag); } break;
        case 16:{
            switch (ps.memoryLeakingWarningType) {
                case SDMLDWarnningTypeAlert:{
                    return SD_STRING(@"alert");
                } break;
                case SDMLDWarnningTypeConsole:{
                    return SD_STRING(@"console");
                } break;
                case SDMLDWarnningTypeException:{
                    return SD_STRING(@"exception");
                } break;
            }
        } break;
    }
    return nil;
}

static void updateSettingValueWithIndex(id newValue, NSInteger index) {
    TDFSDPersistenceSetting *ps = [TDFSDPersistenceSetting sharedInstance];
    switch (index) {
        case 0:{
            if ([newValue isEqualToString:SD_STRING(@"api record")]) {
                ps.messageRemindType = SDMessageRemindTypeAPIRecord;
            } else if ([newValue isEqualToString:SD_STRING(@"system log")]) {
                ps.messageRemindType = SDMessageRemindTypeSystemLog;
            }
        } break;
        case 1:{ ps.allowCatchAPIRecordFlag = [newValue boolValue]; } break;
        case 2:{ ps.allowMonitorSystemLogFlag = [newValue boolValue]; } break;
        case 3:{ if (@available(iOS 10_0, *)) { ps.limitSizeOfSingleSystemLogMessageData = [(NSString *)newValue integerValue]; }} break;
        case 4:{ ps.allowCrashCaptureFlag = [newValue boolValue]; } break;
        case 5:{ ps.needCacheCrashLogToSandBox = [newValue boolValue]; } break;
        case 6:{ ps.isSafeModeForCrashCapture = [newValue boolValue]; } break;
        case 7:{ ps.allowUILagsMonitoring = [newValue boolValue]; } break;
        case 8:{ ps.tolerableLagThreshold = [(NSString *)newValue doubleValue]; } break;
        case 9:{ ps.allowApplicationCPUMonitoring = [newValue boolValue]; } break;
        case 10:{ ps.allowApplicationMemoryMonitoring = [newValue boolValue]; } break;
        case 11:{ ps.allowScreenFPSMonitoring = [newValue boolValue]; } break;
        case 12:{ ps.fpsWarnningThreshold = [(NSString *)newValue integerValue]; } break;
        case 13:{
            ps.allowWildPointerMonitoring = [newValue boolValue];
            if ([newValue boolValue]) {
                [[TDFSDWildPointerChecker sharedInstance] thaw];
            } else  {
                [[TDFSDWildPointerChecker sharedInstance] freeze];
            }
        } break;
        case 14:{ ps.maxZombiePoolCapacity = [newValue integerValue]; } break;
        case 15:{ ps.allowMemoryLeaksDetectionFlag = [newValue boolValue]; } break;
        case 16:{
            if ([newValue isEqualToString:SD_STRING(@"alert")]) {
                ps.memoryLeakingWarningType = SDMLDWarnningTypeAlert;
            } else if ([newValue isEqualToString:SD_STRING(@"console")]) {
                ps.memoryLeakingWarningType = SDMLDWarnningTypeConsole;
            } else if ([newValue isEqualToString:SD_STRING(@"exception")]) {
                ps.memoryLeakingWarningType = SDMLDWarnningTypeException;
            }
        } break;
    }
}

@end
