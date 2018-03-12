//
//  TDFSDPMWildPointerChecker.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/2.
//

#import <Foundation/Foundation.h>
#import "TDFSDFunctionIOControlProtocol.h"

@interface TDFSDPMWildPointerChecker : NSObject <TDFSDFunctionIOControlProtocol>

@property (nonatomic, assign) NSUInteger maxZombieProxyCount;

+ (instancetype)sharedInstance;
- (void)killZombieProxiesInPool;

@end
