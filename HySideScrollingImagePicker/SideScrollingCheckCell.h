//
//  SideScrollingCheckCell.h
//  TestProject
//
//  Created by Apple on 15/6/25.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideScrollingCheckCell : UICollectionReusableView

+ (CGSize)defaultSize;
- (void)setChecked:(BOOL)checked;

@end
