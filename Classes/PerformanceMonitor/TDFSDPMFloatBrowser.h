//
//  TDFSDPMFloatBrowser.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/21.
//

#import <UIKit/UIKit.h>
@class RACSubject;

typedef NS_ENUM(NSUInteger, SDPMTapZoneType) {
    SDPMTapZoneTypeCPU,
    SDPMTapZoneTypeMemory,
    SDPMTapZoneTypeFPS,
    SDPMTapZoneTypeLag,
    SDPMTapZoneTypeCenter
};

@interface TDFSDPMFloatBrowser : UIControl

@property (nonatomic, strong) RACSubject *longPressProxy;
@property (nonatomic, strong) RACSubject *tapProxy;

@end
