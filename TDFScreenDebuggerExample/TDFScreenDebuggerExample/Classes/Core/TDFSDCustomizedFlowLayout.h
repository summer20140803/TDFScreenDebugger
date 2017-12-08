//
//  TDFSDCustomizedFlowLayout.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/26.
//
//

#import <UIKit/UIKit.h>


@interface TDFSDCustomizedFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGFloat damping;    // default is 0.7
@property (nonatomic, assign) CGFloat frequency;  // default is 1.0

/** 
 when you reload collection, be sure to invoke this method before your reload method
 if not clear all exist behaviors and cache visibleIndexPaths, may lead to crash
 */
- (void)resetLayout;

@end

