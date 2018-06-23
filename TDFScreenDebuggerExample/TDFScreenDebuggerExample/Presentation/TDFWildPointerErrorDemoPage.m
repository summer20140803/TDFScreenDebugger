//
//  TDFWildPointerErrorDemoPage.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2018/6/21.
//  Copyright © 2018年 TDF. All rights reserved.
//

#import "TDFWildPointerErrorDemoPage.h"
#import <Masonry/Masonry.h>

@interface TDFWildPointerErrorDemoPage ()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, unsafe_unretained) id unsafeObject;

@end

@implementation TDFWildPointerErrorDemoPage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSObject *obj = [NSObject new];
    self.unsafeObject = obj;
    obj = nil;
    NSLog(@"%@", self.unsafeObject);
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        [_tipLabel setBackgroundColor:[UIColor clearColor]];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.numberOfLines = 1;
        _tipLabel.textColor = [UIColor lightGrayColor];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _tipLabel.text = @"please tap screen to cause a wild pointer error..";
    }
    return _tipLabel;
}

@end
