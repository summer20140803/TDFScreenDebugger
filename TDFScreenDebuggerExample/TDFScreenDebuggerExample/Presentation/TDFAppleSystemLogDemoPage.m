//
//  TDFAppleSystemLogDemoPage.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2018/6/21.
//  Copyright © 2018年 TDF. All rights reserved.
//

#import "TDFAppleSystemLogDemoPage.h"
#import <Masonry/Masonry.h>

@interface TDFAppleSystemLogDemoPage ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *printButton;

@end

@implementation TDFAppleSystemLogDemoPage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.textField];
    [self.view addSubview:self.printButton];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(100);
        make.left.equalTo(self.view).with.offset(44);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@40);
    }];
    [self.printButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-100);
        make.left.equalTo(self.view).with.offset(100);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@40);
    }];
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.placeholder = @"enter any words you want..";
        _textField.borderStyle = UITextBorderStyleRoundedRect;
    }
    return _textField;
}

- (UIButton *)printButton {
    if (!_printButton) {
        _printButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_printButton setBackgroundColor:[UIColor blueColor]];
        _printButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _printButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [_printButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_printButton setTitle:@"NSLog to print" forState:UIControlStateNormal];
        [_printButton.layer setCornerRadius:10.];
        [_printButton.layer masksToBounds];
        [_printButton addTarget:self action:@selector(nslogToPrint:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _printButton;
}

#pragma mark - event
- (void)nslogToPrint:(UIButton *)sender {
    NSLog(@"%@", self.textField.text);
    self.textField.text = @"";
    [sender setBackgroundColor:[UIColor grayColor]];
    [sender setTitle:@"print done!" forState:UIControlStateNormal];
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sender setBackgroundColor:[UIColor blueColor]];
        [sender setTitle:@"NSLog to print" forState:UIControlStateNormal];
        sender.enabled = YES;
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
