//
//  ViewController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/11.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"触摸keyWindow的子view");
}

@end
