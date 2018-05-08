//
//  TDFSDFunctionCollectionViewCell.h
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/20.
//
//

#import <UIKit/UIKit.h>
@class TDFSDFunctionCollectionViewModel;

@interface TDFSDFunctionCollectionViewCell : UICollectionViewCell

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
- (void)bindWithViewModel:(TDFSDFunctionCollectionViewModel *)viewModel;

@end
