//
//  TDFSDPMExtraToolModel.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/6.
//

#import <Foundation/Foundation.h>
#import "TDFSDFunctionIOControlProtocol.h"

@interface TDFSDPMExtraToolModel : NSObject

@property (nonatomic,   copy) NSString *name;
@property (nonatomic,   copy) NSString *toolDescription;
@property (nonatomic, assign) BOOL isOn;

@property (nonatomic,   weak) id<TDFSDFunctionIOControlProtocol> realizer;

@end
