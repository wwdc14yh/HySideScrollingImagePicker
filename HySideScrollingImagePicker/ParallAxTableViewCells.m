//
//  ParallAxTableViewCells.m
//  Opening The Eyes
//
//  Created by Hy_Mac on 15/4/24.
//  Copyright (c) 2015年 Hy_Mac. All rights reserved.
//

#import "ParallAxTableViewCells.h"
@implementation ParallAxTableViewCells{
    UIView *cellView;
    UILabel *Lable2;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    if (SCREEN_WIDTH == 320.0f) {
     cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200.0f)];
        self.TitleOne = [[UILabel alloc]initWithFrame:CGRectMake(0 , 0 ,[UIScreen mainScreen].bounds.size.width ,200)];
    }else{
     cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
        self.TitleOne = [[UILabel alloc]initWithFrame:CGRectMake(0 , 0 ,[UIScreen mainScreen].bounds.size.width ,300)];
    }
    [cellView setClipsToBounds:YES];
    
    self.parallaxImageView = [[UIImageView alloc] init];
    [self.parallaxImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.parallaxImageView.frame = cellView.frame;
    [self.contentView addSubview:cellView];
    
    [cellView addSubview:self.parallaxImageView];
    self.TitleOne.textColor = [UIColor whiteColor];
    //[self.TitleOne setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.TitleOne.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f];
    self.TitleOne.textAlignment = NSTextAlignmentCenter;
    self.TitleOne.font = [UIFont fontWithName:@"TrebuchetMS-Regular" size:16];
    self.TitleOne.numberOfLines = 0;
    [cellView addSubview:self.TitleOne];
}

//计算初始位置
- (void)setParallaxImageViewWithImage:(UIImage *)image onTableView:(UITableView *)tableView toView:(UIView *)view atRows:(NSInteger)row {
    

    //self.parallaxImageView.image = Nil;
    //self.parallaxImageView.alpha = 0.0f;
    CGRect rectInSuperview;
    CGFloat startY ;
    CGFloat imageTargetHeight = image.size.height * (SCREEN_WIDTH / image.size.width)+100 ;
    if (SCREEN_WIDTH == 320.0f) {
        rectInSuperview = CGRectMake(0, row*PARALLAXCELL_HEIGHT1, SCREEN_WIDTH, PARALLAXCELL_HEIGHT);
        startY = imageTargetHeight - PARALLAXCELL_HEIGHT1;
        
    }else{
        rectInSuperview = CGRectMake(0, row*PARALLAXCELL_HEIGHT, SCREEN_WIDTH, PARALLAXCELL_HEIGHT);
        startY = imageTargetHeight - PARALLAXCELL_HEIGHT;
    }
    
    //计算cell的下边框的y值在view中的比例
    CGFloat ratio = (CGRectGetMinY(rectInSuperview)+CGRectGetHeight(rectInSuperview)) / (view.frame.size.height + CGRectGetHeight(rectInSuperview));
    
    CGFloat move = ratio * startY;
    
    //self.parallaxImageView.image = image;
    [self.parallaxImageView setFrame:CGRectMake(0, -startY + move, SCREEN_WIDTH, imageTargetHeight)];
}

//计算移动中的位置
- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view
{
    
    //原理公式：cell的图片位置 ／ cell图片可以滑动的总长  ＝  cell在table中的位置 ／ cell 可滑动总长
    //获得cell在table中的位置
    CGRect rectInSuperview = [tableView convertRect:self.frame toView:view];
    
    //计算cell的下边框的y值在view中移动的比例
    CGFloat ratio = (CGRectGetMinY(rectInSuperview)+CGRectGetHeight(rectInSuperview)) / (view.frame.size.height + CGRectGetHeight(rectInSuperview));
    
    //计算图片的起始位置，并且这个位置图片y值的范围应该在-startY和0之间
    CGFloat startY = CGRectGetHeight(self.parallaxImageView.frame) - CGRectGetHeight(self.frame);
    
    CGFloat move = ratio * startY;
    
    //获得cell图片的位置
    CGRect imageRect = self.parallaxImageView.frame;
    imageRect.origin.y = -startY + move;
    self.parallaxImageView.frame = imageRect;
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        [self.TitleOne setAlpha:0.0f];
//        
//    }];
//    
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        [self.TitleOne setAlpha:1.0f];
//        
//    }];
//    
//}
//
//-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        [self.TitleOne setAlpha:1.0f];
//        
//    }];
//    
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        [self.TitleOne setAlpha:1.0f];
//        
//    }];
//    
//}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

@implementation Button

-(instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        [self addTarget:self action:@selector(scaleToSmall)
//       forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
//        [self addTarget:self action:@selector(scaleAnimation)
//       forControlEvents:UIControlEventTouchUpInside];
//        [self addTarget:self action:@selector(scaleToDefault)
//       forControlEvents:UIControlEventTouchDragExit];
//        [self addTarget:self action:@selector(Up) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

-(void)Up{

    [UIView animateWithDuration:0.3 animations:^{
        
        [self setAlpha:1.0f];
        
    }];
    
}

- (void)scaleToSmall
{
    [UIView animateWithDuration:0.3 animations:^{
        
        [self setAlpha:0.0f];
        
    }];
}

- (void)scaleAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        
        [self setAlpha:1.0f];
        
    }];
}

- (void)scaleToDefault
{
    [UIView animateWithDuration:0.3 animations:^{
        
        [self setAlpha:1.0f];
        
    }];
}

@end
