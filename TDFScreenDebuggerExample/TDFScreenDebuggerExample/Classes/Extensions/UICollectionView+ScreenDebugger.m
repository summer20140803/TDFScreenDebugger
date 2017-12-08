//
//  UICollectionView+ScreenDebugger.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/26.
//
//

#import "UICollectionView+ScreenDebugger.h"
#import "TDFSDCustomizedFlowLayout.h"

@implementation UICollectionView (ScreenDebugger)

- (void)sd_triggleWithLoadAnimation {

    NSArray<UICollectionViewCell *> *visibleCells = self.visibleCells;
    
    NSArray *sortedVisibleCells = [visibleCells sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSIndexPath *path1 = [self indexPathForCell:obj1];
        NSIndexPath *path2 = [self indexPathForCell:obj2];
        return [path1 compare:path2];
    }];
    
    [sortedVisibleCells enumerateObjectsUsingBlock:^(UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.backgroundView.alpha = 0;
        obj.contentView.alpha = 0;
        obj.transform = CGAffineTransformMakeTranslation(0, 80);
        
        [UIView animateWithDuration:1.2f delay:0.08f * (idx + 1) usingSpringWithDamping:0.6f initialSpringVelocity:0
                         options:UIViewAnimationOptionCurveEaseInOut |
                                 UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             obj.backgroundView.alpha = 0.35;
                             obj.contentView.alpha = 1;
                             obj.transform = CGAffineTransformIdentity;
                         } completion:nil];
    }];
}

- (void)sd_safeReloadDataIfUseCustomLayout {
    if ([self.collectionViewLayout isKindOfClass:[TDFSDCustomizedFlowLayout class]]) {
        
        // when you reload collection, be sure to invoke this method before your reload method
        // if not clear all exist behaviors and cache visibleIndexPaths, may lead to crash
        [(TDFSDCustomizedFlowLayout *)self.collectionViewLayout resetLayout];
        
        [self reloadData];
    }
}

@end
