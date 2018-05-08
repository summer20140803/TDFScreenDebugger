//
//  ViewController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/11.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "ViewController.h"
#import "TDFSDPMWildPointerChecker.h"

@interface CustomObject : NSObject

@end

@implementation CustomObject

@end

@interface ViewController ()

@property (nonatomic, unsafe_unretained) CustomObject *obj;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[TDFSDPMWildPointerChecker sharedInstance] thaw];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CustomObject *obj = [[CustomObject alloc] init];
    NSLog(@"%@", obj);
    self.obj = obj;
}

- (IBAction)testAction:(id)sender {
    NSLog(@"%@", self.obj);
}

- (IBAction)testAction2:(id)sender {
}

@end
