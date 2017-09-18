//
//  TDFSDPersistenceSetting.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SDMessageRemindType) {
    SDMessageRemindTypeAPIRecord   = 0,
};

@interface TDFSDPersistenceSetting : NSObject

@property (nonatomic, assign) SDMessageRemindType messageRemindType;

+ (instancetype)sharedInstance;

@end
