//
//  TDFSDPMUILagComponentModel.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/13.
//

#import <Foundation/Foundation.h>
#import "TDFSDMessageRemindProtocol.h"

@interface TDFSDPMUILagComponentModel : NSObject <TDFSDMessageRemindProtocol>

@property (nonatomic, strong) NSDate   *occurTime;
@property (nonatomic,   copy) NSString *callStackInfo;

@end
