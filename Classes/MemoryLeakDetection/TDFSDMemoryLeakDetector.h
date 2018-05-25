//
//  TDFSDMemoryLeakDetector.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/16.
//

#import <Foundation/Foundation.h>
#import "TDFSDFunctionIOControlProtocol.h"

@interface TDFSDMemoryLeakDetector : NSObject <TDFSDFunctionIOControlProtocol>

@property (nonatomic, strong, readonly) NSArray<NSString *> *cacheSingletonClassNames;
@property (nonatomic,   copy) BOOL (^customizedObjectIsLeakingLogicHandler)(id obj);

+ (instancetype)sharedInstance;
- (void)addSingletonClassNameToCache:(NSString *)className;

@end
