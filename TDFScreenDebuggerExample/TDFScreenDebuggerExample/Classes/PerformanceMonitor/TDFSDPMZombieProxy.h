//
//  TDFSDPMZombieProxy.h
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2018/4/4.
//  Copyright © 2018年 TDF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDFSDPMZombieProxy : NSProxy

@property (nonatomic, assign) Class originClass;

@end
