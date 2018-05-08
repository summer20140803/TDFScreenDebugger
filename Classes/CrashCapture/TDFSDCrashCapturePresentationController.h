//
//  TDFSDCrashCapturePresentationController.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/16.
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC/ReactiveObjC.h>
@class TDFSDCCCrashModel;

@interface TDFSDCrashCapturePresentationController : UIViewController

@property (nonatomic, strong) TDFSDCCCrashModel *crashInfo;
@property (nonatomic, strong) RACSubject *exportProxy;
@property (nonatomic, strong) RACSubject *terminateProxy;

@end
