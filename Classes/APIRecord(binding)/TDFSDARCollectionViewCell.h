//
//  TDFSDARCollectionViewCell.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/27.
//
//

#import <UIKit/UIKit.h>
@class TDFSDARCollectionViewModel;

@interface TDFSDARCollectionViewCell : UICollectionViewCell

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
- (void)bindWithViewModel:(TDFSDARCollectionViewModel *)viewModel;

@end
