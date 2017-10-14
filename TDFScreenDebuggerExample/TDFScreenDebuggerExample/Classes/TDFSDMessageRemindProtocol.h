//
//  TDFSDMessageRemindProtocol.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/16.
//
//

#import <Foundation/Foundation.h>

@protocol TDFSDMessageRemindProtocol <NSObject>

@required
- (BOOL)messageIsRead;
- (void)setMessageRead:(BOOL)messageRead;

@end
