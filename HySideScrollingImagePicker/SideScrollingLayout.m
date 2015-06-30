//
//  SideScrollingLayout.m
//  TestProject
//
//  Created by Apple on 15/6/25.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "SideScrollingLayout.h"
#import "SideScrollingCheckCell.h"

#define kHorizontalCheckmarkInset 4.0
#define kVericalCheckmarkInset 2.0

@implementation SideScrollingLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect;
{
    NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    // Add our supplementary views, thet checkmark views
    for (UICollectionViewLayoutAttributes *attrs in [attributes copy]) {
        [attributes addObject:[self layoutAttributesForSupplementaryViewOfKind:@"check" atIndexPath:attrs.indexPath]];
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    // Capture some commonly used variables...
    CGRect collectionViewBounds = self.collectionView.bounds;
    CGFloat collectionViewXOffset = self.collectionView.contentOffset.x;
    
    UICollectionViewLayoutAttributes *cellAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    UICollectionViewLayoutAttributes *checkAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    checkAttributes.size = CGSizeMake(28, 28);
    checkAttributes.zIndex = 100;
    
    CGFloat checkVerticalCenter = checkAttributes.size.height/2+3;
    
    checkAttributes.center = (CGPoint){
        CGRectGetMaxX(cellAttributes.frame) - kHorizontalCheckmarkInset - checkAttributes.size.width/2,
        checkVerticalCenter
    };
    
    // If the left side of the check view isn't visible, but the relative cell view is, move the check to the left so it is also visible.
    CGFloat leftSideOfCell = CGRectGetMinX(cellAttributes.frame);
    CGFloat rightSideOfVisibleArea = collectionViewXOffset + CGRectGetWidth(collectionViewBounds);
    if (leftSideOfCell < rightSideOfVisibleArea && CGRectGetMaxX(checkAttributes.frame) >= rightSideOfVisibleArea) {
        checkAttributes.center = (CGPoint){
            rightSideOfVisibleArea - checkAttributes.size.width/2,
            checkVerticalCenter
        };
    }
    
    // Never let the left side of the check view be less than the left side of the cell plus padding.
    if (CGRectGetMinX(checkAttributes.frame) < leftSideOfCell + kHorizontalCheckmarkInset) {
        checkAttributes.center = (CGPoint) {
            leftSideOfCell + kHorizontalCheckmarkInset + checkAttributes.size.width/2,
            checkVerticalCenter
        };
    }
    
    //checkAttributes.center = CGPointMake(checkAttributes.center.x, checkAttributes.size.height/2+10);
    
    return checkAttributes;
}

@end
