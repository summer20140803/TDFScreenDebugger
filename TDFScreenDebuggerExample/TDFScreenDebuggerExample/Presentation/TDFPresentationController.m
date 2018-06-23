//
//  TDFPresentationController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2018/6/21.
//  Copyright © 2018年 TDF. All rights reserved.
//

#import "TDFPresentationController.h"
#import "TDFCrashDemoPage.h"
#import <Masonry/Masonry.h>

@interface TDFPresentationController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *demoPageVCNames;
@property (nonatomic, strong) NSArray *demoPageVCTitles;
@property (nonatomic, strong) UITableView *demoListView;

@end

@implementation TDFPresentationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"TDFScreenDebugger Demo";
    
    self.demoPageVCNames = @[ @"TDFAppleSystemLogDemoPage",
                              @"TDFCrashDemoPage",
                              @"TDFPerformanceDemoPage",
                              @"TDFMemoryLeakingDemoPage",
                              @"TDFWildPointerErrorDemoPage" ];
    self.demoPageVCTitles = self.demoPageVCNames;
    
    [self.view addSubview:self.demoListView];
    [self.demoListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    TDFCrashDemoPage *p = [[TDFCrashDemoPage alloc] init];
    [self presentViewController:p animated:YES completion:nil];
}

#pragma mark - getter
- (UITableView *)demoListView {
    if (!_demoListView) {
        _demoListView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _demoListView.backgroundColor = [UIColor clearColor];
        _demoListView.showsHorizontalScrollIndicator = NO;
        _demoListView.showsVerticalScrollIndicator = NO;
        _demoListView.dataSource = self;
        _demoListView.delegate = self;
        _demoListView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _demoListView;
}

#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoPageVCNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = self.demoPageVCTitles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Class pageClass = NSClassFromString(self.demoPageVCNames[indexPath.row]);
    UIViewController *page = [[pageClass alloc] init];
    page.title = self.demoPageVCTitles[indexPath.row];
    [self.navigationController pushViewController:page animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

@end
