//
//  TDFSDCCCollectionViewCell.h
//  TDFScreenDebugger
//
//  Created by 开不了口的猫 on 2017/10/31.
//

#import <UIKit/UIKit.h>
@class TDFSDCCCollectionViewModel;

@interface TDFSDCCCollectionViewCell : UICollectionViewCell

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
- (void)bindWithViewModel:(TDFSDCCCollectionViewModel *)viewModel;

@end
