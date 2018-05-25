//
//  TDFSDCustomizedFlowLayout.m
//  Pods
//
//  Created by 开不了口的猫 on 2017/9/26.
//
//

#import "TDFSDCustomizedFlowLayout.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface TDFSDCustomizedFlowLayout ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) NSMutableSet *visibleIndexPaths;
@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) CGFloat lastScrollDelta;
@property (nonatomic, assign) CGPoint lastTouchLocation;

@end


@implementation TDFSDCustomizedFlowLayout

static const CGFloat kSDScrollPaddingRect            =  100.0f;
static const CGFloat kSDScrollRefreshThreshold       =  50.0f;
static const CGFloat kSDScrollResistanceCoefficient  =  1 / 600.0f;

- (void)setup{
    self.animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    self.visibleIndexPaths = [NSMutableSet set];
}

- (id)init {
    self = [super init];
    if (self){
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];

    CGPoint contentOffset = self.collectionView.contentOffset;

    // only refresh the set of UIAttachmentBehaviours if we've moved more than the scroll threshold since last load
    if (fabs(contentOffset.y - self.lastContentOffset.y) < kSDScrollRefreshThreshold && self.visibleIndexPaths.count > 0){
        return;
    }
    self.lastContentOffset = contentOffset;

    CGFloat padding = kSDScrollPaddingRect;
    CGRect currentRect = CGRectMake(0, contentOffset.y - padding, self.collectionView.frame.size.width, self.collectionView.frame.size.height + 3 * padding);

    NSArray *itemsInCurrentRect = [super layoutAttributesForElementsInRect:currentRect];
    NSSet *indexPathsInVisibleRect = [NSSet setWithArray:[itemsInCurrentRect valueForKey:@"indexPath"]];

    // remove behaviours that are no longer visible
    [self.animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *behaviour, NSUInteger idx, BOOL *stop) {
        
        NSIndexPath *indexPath = [(UICollectionViewLayoutAttributes *)[[behaviour items] firstObject] indexPath];
        
        BOOL isInVisibleIndexPaths = [indexPathsInVisibleRect member:indexPath] != nil;
        if (!isInVisibleIndexPaths){
            [self.animator removeBehavior:behaviour];
            [self.visibleIndexPaths removeObject:indexPath];
        }
    }];

    // find newly visible indexes
    NSArray *newVisibleItems = [itemsInCurrentRect filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        BOOL isInVisibleIndexPaths = [self.visibleIndexPaths member:item.indexPath] != nil;
        return !isInVisibleIndexPaths;
    }]];

    [newVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {

        CGPoint fixedCenter = CGPointMake(round(attribute.center.x), attribute.center.y);
        UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:attribute attachedToAnchor:fixedCenter];
        spring.length = 0;
        spring.frequency = self.frequency ?: 1;
        spring.damping = self.damping ?: 0.7;
        if (@available(iOS 9.0, *)) {
            spring.frictionTorque = CGFLOAT_MAX;
            spring.attachmentRange = UIFloatRangeZero;
        }
        @weakify(self)
        @weakify(spring)
        spring.action = ^(void){
            @strongify(spring)
            @strongify(self)
            CGFloat delta = fabs(attribute.center.y - spring.anchorPoint.y);
            if (delta <= 1){
                spring.damping = 100;
            } else {
                spring.damping = self.damping ?: 0.7;
            }
        };

        // if our touchLocation is not (0,0), we need to adjust our item's center
        if (self.lastScrollDelta != 0) {
            [self adjustSpring:spring centerForTouchPosition:self.lastTouchLocation scrollDelta:self.lastScrollDelta];
        }
        [self.animator addBehavior:spring];
        [self.visibleIndexPaths addObject:attribute.indexPath];
    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    CGFloat padding = kSDScrollPaddingRect;
    rect.size.height += 3 * padding;
    rect.origin.y -= padding;
    return [self.animator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    id layoutAttributes = [self.animator layoutAttributesForCellAtIndexPath:indexPath];
    if (!layoutAttributes)
        layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    return layoutAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    // https://objccn.io/issue-5-2/

    UIScrollView *scrollView = self.collectionView;
    self.lastScrollDelta = newBounds.origin.y - scrollView.bounds.origin.y;

    self.lastTouchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];

    [self.animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *spring, NSUInteger idx, BOOL *stop) {
        [self adjustSpring:spring centerForTouchPosition:self.lastTouchLocation scrollDelta:self.lastScrollDelta];
        [self.animator updateItemUsingCurrentState:[spring.items firstObject]];
    }];

    return NO;
}

- (void)adjustSpring:(UIAttachmentBehavior *)spring centerForTouchPosition:(CGPoint)touchLocation scrollDelta:(CGFloat)scrollDelta {
    CGFloat distanceFromTouch = fabs(touchLocation.y - spring.anchorPoint.y);
    CGFloat scrollResistance = distanceFromTouch * kSDScrollResistanceCoefficient;

    UICollectionViewLayoutAttributes *item = (UICollectionViewLayoutAttributes *)[spring.items firstObject];
    CGPoint center = item.center;

    CGPoint fixedCenter = CGPointMake(round(center.x), center.y);

    if (self.lastScrollDelta < 0) {
        fixedCenter.y += MAX(self.lastScrollDelta, self.lastScrollDelta * scrollResistance);
    } else {
        fixedCenter.y += MIN(self.lastScrollDelta, self.lastScrollDelta * scrollResistance);
    }

    item.center = CGPointMake(round(fixedCenter.x), fixedCenter.y);
}

- (void)resetLayout {
    [self.animator removeAllBehaviors];
    [self.visibleIndexPaths removeAllObjects];
}


@end


