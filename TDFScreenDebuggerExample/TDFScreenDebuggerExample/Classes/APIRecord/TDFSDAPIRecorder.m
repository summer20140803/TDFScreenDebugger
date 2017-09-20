//
//  TDFSDAPIRecorder.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/14.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDAPIRecorder.h"
#import "TDFSDManager.h"
#import "TDFSDAPIRecordConsoleController.h"
#import "TDFALRequestModel+APIRecord.h"
#import <ReactiveObjC/ReactiveObjC.h>


@interface TDFSDAPIRecorder ()

@property (nonatomic, strong, readwrite) NSArray<__kindof TDFALBaseModel *> *descriptionModels;
@property (nonatomic, strong, readwrite) NSArray<TDFALRequestModel *> *requestDesModels;
@property (nonatomic, strong, readwrite) NSArray<TDFALResponseModel *> *responseDesModels;

@end

@implementation TDFSDAPIRecorder

#pragma mark - life cycle
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TDFSDAPIRecorder *recorder = [TDFSDAPIRecorder sharedInstance];
        [TDFAPILogger sharedInstance].requestLogReporter = ^(TDFALRequestModel *requestLogDescription) {
            [recorder storeDescription:requestLogDescription];
        };
        [TDFAPILogger sharedInstance].responseLogReporter = ^(TDFALResponseModel *responseLogDescription) {
            [recorder storeDescription:responseLogDescription];
        };
    });
}

+ (instancetype)sharedInstance {
    static TDFSDAPIRecorder *recorder = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        recorder = [[self alloc] init];
    });
    return recorder;
}

- (instancetype)init {
    if (self = [super init]) {
        self.descriptionModels = @[];
        self.requestDesModels = @[];
        self.responseDesModels = @[];
    }
    return self;
}

#pragma mark - interface methods
- (void)clearAllRecords {
    self.descriptionModels = @[];
    self.requestDesModels = @[];
    self.responseDesModels = @[];
}

#pragma mark - private
- (void)storeDescription:(TDFALBaseModel *)descriptionModel {
    
    NSMutableArray *mutableModels = self.descriptionModels.mutableCopy;
    [mutableModels addObject:descriptionModel];
    self.descriptionModels = mutableModels.copy;
    
    if ([descriptionModel isKindOfClass:[TDFALRequestModel class]]) {
        
        // fix the bug when apiRecordVC is still presented but the messageRemindCount raises
        UIViewController *top = [TDFSDManager manager].screenDebuggerWindow.rootViewController.presentedViewController;
        BOOL apiRecordVCIsPresented = top && [top isKindOfClass:[TDFSDAPIRecordConsoleController class]];
        [(TDFALRequestModel *)descriptionModel setMessageRead:apiRecordVCIsPresented];
        
        NSMutableArray *mutableRequestModels = self.requestDesModels.mutableCopy;
        [mutableRequestModels addObject:descriptionModel];
        self.requestDesModels = mutableRequestModels.copy;
        
    } else if ([descriptionModel isKindOfClass:[TDFALResponseModel class]]) {
        
        NSMutableArray *mutableResponseModels = self.responseDesModels.mutableCopy;
        [mutableResponseModels addObject:descriptionModel];
        self.responseDesModels = mutableResponseModels.copy;
    }
}

@end
