//
//  ViewController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/11.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "ViewController.h"
#import "LeakingViewController.h"
#import "TDFSDManager.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface CustomObject : NSObject

@end

@implementation CustomObject

@end

@interface ViewController ()

@property (nonatomic, unsafe_unretained) CustomObject *obj;
@property (nonatomic, strong) UIView *cusview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    self.cusview = [[UIView alloc] init];
    self.cusview.backgroundColor = [UIColor blueColor];
    self.cusview.frame = CGRectMake(200, 400, 100, 100);
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToQuickLaunch)];
    longpress.minimumPressDuration = 1.5;
    [self.cusview addGestureRecognizer:longpress];
    [self.view addSubview:self.cusview];
    
    // add quick launch..
    [[TDFSDManager manager] registerQuickLaunchGesture:longpress forSubTool:SDSubToolTypeCrashCaptor];
}

- (void)longPressToQuickLaunch {
    NSLog(@"OJBK");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}

- (IBAction)testAction:(id)sender {
//    NSLog(@"%@", self.obj);
    NSMutableArray *a = @[].mutableCopy;
    NSObject *obj = nil;
    [a addObject:obj];
}

- (IBAction)testAction2:(id)sender {
    LeakingViewController *leakingVC = [[LeakingViewController alloc] init];
    [self presentViewController:leakingVC animated:YES completion:nil];
}

@end
