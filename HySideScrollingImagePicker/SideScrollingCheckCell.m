//
//  SideScrollingCheckCell.m
//  TestProject
//
//  Created by Apple on 15/6/25.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "SideScrollingCheckCell.h"

@interface SideScrollingCheckCell ()

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, assign)BOOL open;

@end

@implementation SideScrollingCheckCell

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(!_open){
        if (hitView == self){
            return nil;
        }else{
            return hitView;
        }
    }
    return hitView;
}

+ (CGSize)defaultSize;
{
    CGSize size = CGSizeMake([UIImage imageNamed:@"ImageResources.bundle/FriendsSendsPicturesSelectBigNIcon.png"].size.width/2, [UIImage imageNamed:@"ImageResources.bundle/FriendsSendsPicturesSelectBigNIcon.png"].size.height/2);
    return size;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.open = YES;
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ImageResources.bundle/FriendsSendsPicturesSelectBigNIcon.png"]];
    [self addSubview:imageView];
    self.imageView = imageView;
    [imageView setFrame:CGRectMake(0, 0, 28, 28)];
}

- (void)setChecked:(BOOL)checked;
{
    if (checked) {
        UIImage *emptyCheckmark = [UIImage imageNamed:@"ImageResources.bundle/FriendsSendsPicturesSelectBigYIcon.png"];
        self.imageView.image = emptyCheckmark;
        
    } else {
        UIImage *fullCheckmark = [UIImage imageNamed:@"ImageResources.bundle/FriendsSendsPicturesSelectBigNIcon.png"];
        self.imageView.image = fullCheckmark;
    }
}

- (void)prepareForReuse
{
    [self setChecked:NO];
}

@end
