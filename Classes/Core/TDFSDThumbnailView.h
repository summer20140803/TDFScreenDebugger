//
//  TDFSDThumbnailView.h
//  TDFScreenDebuggerExample
//
//  Created by 开不了口的猫 on 2017/9/12.
//  Copyright © 2017年 TDF. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RACSubject;

@interface TDFSDThumbnailView : UIView

@property (nonatomic, strong) RACSubject *tapProxy;
@property (nonatomic, strong) RACSubject *longPressProxy;

@end
