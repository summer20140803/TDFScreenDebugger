//
//  TDFSDFunctionIOControlProtocol.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/14.
//

#import <Foundation/Foundation.h>

@protocol TDFSDFunctionIOControlProtocol <NSObject>

@required
- (void)thaw;
- (void)freeze;

@end
