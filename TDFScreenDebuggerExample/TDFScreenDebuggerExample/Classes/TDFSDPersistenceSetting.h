//
//  TDFSDPersistenceSetting.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/17.
//
//

#import <Foundation/Foundation.h>
@class TDFSDFunctionModel;

typedef NS_ENUM(NSUInteger, TDFSDMessageRemindType) {
    TDFSDMessageRemindTypeAPIRecord   = 0,
    TDFSDMessageRemindTypeSystemLog   = 1,
};

@interface TDFSDPersistenceSetting : NSObject

@property (nonatomic, assign) TDFSDMessageRemindType messageRemindType;
@property (nonatomic, strong, readonly) NSArray<TDFSDFunctionModel *> *functionList;

+ (instancetype)sharedInstance;

@end
