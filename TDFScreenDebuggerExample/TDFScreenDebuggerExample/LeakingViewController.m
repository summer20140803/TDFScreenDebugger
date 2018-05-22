//
//  LeakingViewController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2018/5/18.
//  Copyright © 2018年 TDF. All rights reserved.
//

#import "LeakingViewController.h"

/// 示例一个会导致内存泄漏的自定义的view
@interface CustonView : UIView

@end

@implementation CustonView

- (void)dealloc {
    NSLog(@"CustomView %@ dealloc", self);
}

@end

/// 示例一个单例类
@interface SharedInstanceClass : NSObject

@property (nonatomic, strong) id strongHost;
+ (instancetype)sharedInstance;

@end

@implementation SharedInstanceClass

static SharedInstanceClass *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!sharedInstance) {
        sharedInstance = [super allocWithZone:zone];
    }
    return sharedInstance;
}

@end

/// 示例一个会导致内存泄漏的Controller
@interface LeakingViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CustonView *customView;
//@property (nonatomic, strong) SharedInstanceClass *shared;
@property (nonatomic, strong) id obj;

@end

@implementation LeakingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"leaking controller";
    self.view.backgroundColor = [UIColor yellowColor];
    
    CustonView *customView = [[CustonView alloc] init];
    NSLog(@"customView: %@", customView);
    [self.view addSubview:customView];
    [SharedInstanceClass sharedInstance].strongHost = customView;
//    self.customView = customView;
    
//    self.shared = [SharedInstanceClass sharedInstance];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    NSLog(@"leaking controller (%@) dealloc", self);
}

@end
