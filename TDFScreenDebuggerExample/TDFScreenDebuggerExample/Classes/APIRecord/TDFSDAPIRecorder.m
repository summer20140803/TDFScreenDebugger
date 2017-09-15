//
//  TDFSDAPIRecorder.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/14.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDAPIRecorder.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDAPIRecorder ()

@property (nonatomic, strong, readwrite) NSArray<__kindof TDFALBaseModel *> *descriptionModels;

@end

@implementation TDFSDAPIRecorder

#pragma mark - life cycle
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

        @weakify(self)
        [TDFAPILogger sharedInstance].requestLogReporter = ^(TDFALRequestModel *requestLogDescription) {
            @strongify(self)
            [self storeDescription:requestLogDescription];
        };
        [TDFAPILogger sharedInstance].responseLogReporter = ^(TDFALResponseModel *responseLogDescription) {
            @strongify(self)
            [self storeDescription:responseLogDescription];
        };
    }
    return self;
}

#pragma mark - interface methods
- (void)clearAllRecords {
    self.descriptionModels = @[];
}

#pragma mark - private
- (void)storeDescription:(TDFALBaseModel *)descriptionModel {
    NSMutableArray *mutableModels = self.descriptionModels.mutableCopy;
    [mutableModels addObject:descriptionModel];
    self.descriptionModels = mutableModels.copy;
}

@end
