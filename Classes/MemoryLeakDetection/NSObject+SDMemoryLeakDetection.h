//
//  NSObject+SDMemoryLeakDetection.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/16.
//

#import <Foundation/Foundation.h>
#import "TDFSDMLDGeneralizedProtocol.h"
@class TDFSDMLDGeneralizedProxy;

@interface NSObject (SDMemoryLeakDetection) <TDFSDMLDGeneralizedProtocol>

@property (nonatomic, strong, readonly) TDFSDMLDGeneralizedProxy *mld_proxy;

- (void)trackAllStrongPropsLeaks:(int)level;

@end
