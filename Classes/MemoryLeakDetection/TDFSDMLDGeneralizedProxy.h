//
//  TDFSDMLDGeneralizedProxy.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/5/16.
//

#import <Foundation/Foundation.h>

@interface TDFSDMLDGeneralizedProxy : NSObject

@property (nonatomic, weak, readonly) id weakTarget;
@property (nonatomic, weak) id  weakTargetOwner;
@property (nonatomic, weak) id  weakResponder;

// for NSObject instances
@property (nonatomic, copy) NSString *weakTargetOwnerName;

// for UIView instances
@property (nonatomic, copy) NSString *weakViewControllerOwnerClassName;
@property (nonatomic, copy) NSString *weakViewControllerOwnerTitle;

+ (instancetype)proxyWithTarget:(id)target;

@end
