//
//  TDFSDLVLogModel.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/5.
//

#import <Foundation/Foundation.h>
#import "TDFSDMessageRemindProtocol.h"

@interface TDFSDLVLogModel : NSObject <TDFSDMessageRemindProtocol>

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *message;

@end
