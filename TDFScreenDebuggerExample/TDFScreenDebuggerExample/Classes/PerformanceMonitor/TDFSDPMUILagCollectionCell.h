//
//  TDFSDPMUILagCollectionCell.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/12/29.
//

#import <UIKit/UIKit.h>
#import "TDFSDPMUILagCollectionViewModel.h"

@interface TDFSDPMUILagCollectionCell : UICollectionViewCell

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
- (void)bindWithViewModel:(TDFSDPMUILagCollectionViewModel *)viewModel;

@end
