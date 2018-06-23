//
//  TDFPerformanceDemoPage.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2018/6/21.
//  Copyright © 2018年 TDF. All rights reserved.
//

#import "TDFPerformanceDemoPage.h"
#import <Masonry/Masonry.h>

@interface TDFPerformanceDemoPage () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *lagListView;

@end

@implementation TDFPerformanceDemoPage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.lagListView];
    [self.lagListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - getter
- (UITableView *)lagListView {
    if (!_lagListView) {
        _lagListView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _lagListView.backgroundColor = [UIColor clearColor];
        _lagListView.showsHorizontalScrollIndicator = NO;
        _lagListView.showsVerticalScrollIndicator = NO;
        _lagListView.dataSource = self;
        _lagListView.delegate = self;
        _lagListView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _lagListView;
}


#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1000;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellReuseIdentifier = indexPath.row % 5 == 0 ? @"lagCellIdentifier" : @"normalCellIdentifier";
    NSString *cellLabelText = [cellReuseIdentifier substringToIndex:cellReuseIdentifier.length-@"Identifier".length];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    cell.textLabel.text = cellLabelText;
    if (indexPath.row % 5 == 0) {
        usleep(120*1000);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
