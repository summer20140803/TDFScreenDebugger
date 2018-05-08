//
//  TDFSDPMUILagCollectionViewModel.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/29.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "TDFSDPMUILagComponentModel.h"

@interface TDFSDPMUILagCollectionViewModel : NSObject

@property (nonatomic, strong) TDFSDPMUILagComponentModel *lagModel;
@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, assign, readonly) CGFloat cellWidth;

@end
