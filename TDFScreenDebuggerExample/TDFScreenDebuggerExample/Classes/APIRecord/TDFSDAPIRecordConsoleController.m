//
//  TDFSDAPIRecordConsoleController.m
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/14.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import "TDFSDAPIRecordConsoleController.h"
#import "TDFSDAPIRecorder.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "TDFSDAPIRecordCharacterizationProtocol.h"

@interface TDFSDAPIRecordConsoleController () <TDFSDFullScreenConsoleControllerInheritProtocol>

@property (nonatomic, strong) UITextView *apiOutputView;

@end

@implementation TDFSDAPIRecordConsoleController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchAlreadyExistRecord];
    [self addAPIRecordPortObserve];
}

#pragma mark - TDFSDFullScreenConsoleControllerInheritProtocol
- (NSString *)titleForFullScreenConsole {
    return @"API Output";
}

- (UIView *)contentViewForFullScreenConsole {
    return self.apiOutputView;
}

#pragma mark - getter
- (UITextView *)apiOutputView {
    if (!_apiOutputView) {
        _apiOutputView = [[UITextView alloc] init];
        _apiOutputView.backgroundColor = [UIColor clearColor];
        _apiOutputView.editable = NO;
        _apiOutputView.showsVerticalScrollIndicator = YES;
        _apiOutputView.showsHorizontalScrollIndicator = NO;
    }
    return _apiOutputView;
}

#pragma mark - private
- (void)addAPIRecordPortObserve {
    RAC(self.apiOutputView, attributedText) = [RACObserve([TDFSDAPIRecorder sharedInstance], descriptionModels)
    map:^id _Nullable(NSArray<__kindof TDFALBaseModel<TDFSDAPIRecordCharacterizationProtocol> *> *descriptionModels) {
        return [[descriptionModels.rac_sequence
               map:^id _Nullable(__kindof TDFALBaseModel<TDFSDAPIRecordCharacterizationProtocol> * _Nullable descriptionModel) {
                   return descriptionModel.outputCharacterizationString;
               }]
               foldLeftWithStart:[[NSMutableAttributedString alloc] initWithString:@""]
               reduce:^id _Nullable(NSMutableAttributedString * _Nullable accumulator, NSAttributedString * _Nullable value) {
                   return ([accumulator appendAttributedString:value], accumulator);
               }];
    }];
}

- (void)fetchAlreadyExistRecord {
    self.apiOutputView.attributedText = [[[TDFSDAPIRecorder sharedInstance].descriptionModels.rac_sequence
    map:^id _Nullable(__kindof TDFALBaseModel<TDFSDAPIRecordCharacterizationProtocol> * _Nullable descriptionModel) {
        return descriptionModel.outputCharacterizationString;
    }]
    foldLeftWithStart:[[NSMutableAttributedString alloc] initWithString:@""]
    reduce:^id _Nullable(NSMutableAttributedString * _Nullable accumulator, NSAttributedString * _Nullable value) {
        return ([accumulator appendAttributedString:value], accumulator);
    }];
}


@end
