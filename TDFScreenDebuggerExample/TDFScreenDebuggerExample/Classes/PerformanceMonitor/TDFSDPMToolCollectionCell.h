//
//  TDFSDPMToolCollectionCell.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2018/3/6.
//

#import <UIKit/UIKit.h>
#import "TDFSDPMExtraToolModel.h"

@interface TDFSDPMToolCollectionCell : UICollectionViewCell

@property (nonatomic, copy) void (^toolSwitchDidChangeHandler)(NSIndexPath *indexPath, BOOL isOn);

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
- (void)bindWithViewModel:(TDFSDPMExtraToolModel *)viewModel;

@end
