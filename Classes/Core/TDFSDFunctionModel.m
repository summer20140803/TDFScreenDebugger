//
//  TDFSDFunctionModel.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/21.
//
//

#import "TDFSDFunctionModel.h"

@implementation TDFSDFunctionModel

- (NSString *)description {
    return [NSString stringWithFormat:@"\n%@\n%@\n%@\n", self.functionName, self.functionDescription, self.quickLaunchDescrition];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"\n%@\n%@\n%@\n", self.functionName, self.functionDescription, self.quickLaunchDescrition];
}

@end
