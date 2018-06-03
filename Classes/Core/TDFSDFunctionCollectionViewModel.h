//
//  TDFSDFunctionCollectionViewModel.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/26.
//
//

#import <Foundation/Foundation.h>
#import "TDFSDFunctionModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDFunctionCollectionViewModel : NSObject

@property (nonatomic, weak) TDFSDFunctionModel *function;
@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, assign, readonly) CGFloat cellWidth;
@property (nonatomic, strong) RACCommand *jumpCommand;

@end
