//
//  ViewController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/11.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "ViewController.h"
#import "TDFSDPMWildPointerChecker.h"

@interface ViewController ()

@property (nonatomic, unsafe_unretained) id obj;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSObject *obj = [[NSObject alloc] init];
    self.obj = obj;
    obj = nil;
}

- (IBAction)testAction:(id)sender {
    [[TDFSDPMWildPointerChecker sharedInstance] log];
}

- (IBAction)testAction2:(id)sender {
//    NSLog(@"%@", self.obj);
    [[TDFSDPMWildPointerChecker sharedInstance] killZombieProxiesInPool];
}

@end
