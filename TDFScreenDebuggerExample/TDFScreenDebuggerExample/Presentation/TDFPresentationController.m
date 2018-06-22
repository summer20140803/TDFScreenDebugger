//
//  TDFPresentationController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2018/6/21.
//  Copyright © 2018年 TDF. All rights reserved.
//

#import "TDFPresentationController.h"
#import <Masonry/Masonry.h>

@interface TDFPresentationController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *demoPageVCNames;
@property (nonatomic, strong) NSArray *demoPageVCTitles;
@property (nonatomic, strong) UITableView *demoListView;

@end

@implementation TDFPresentationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.demoPageVCNames = @[];
    self.demoPageVCTitles = @[];
    
    [self.view addSubview:self.demoListView];
}

#pragma mark - getter
- (UITableView *)demoListView {
    if (!_demoListView) {
        _demoListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _demoListView.backgroundColor = [UIColor clearColor];
        _demoListView.showsHorizontalScrollIndicator = NO;
        _demoListView.showsVerticalScrollIndicator = NO;
        _demoListView.dataSource = self;
        _demoListView.delegate = self;
        _demoListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _demoListView;
}


#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}


@end
