//
//  TDFSDCCCollectionViewModel.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/31.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "TDFSDCCCrashModel.h"

@interface TDFSDCCCollectionViewModel : NSObject

@property (nonatomic, strong) TDFSDCCCrashModel *crashModel;
@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, assign, readonly) CGFloat cellWidth;

@end
