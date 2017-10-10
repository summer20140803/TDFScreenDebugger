//
//  UICollectionView+ScreenDebugger.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/26.
//
//

#import <UIKit/UIKit.h>

@interface UICollectionView (ScreenDebugger)

- (void)sd_triggleWithLoadAnimation;

- (void)sd_safeReloadDataIfUseCustomLayout;

@end
