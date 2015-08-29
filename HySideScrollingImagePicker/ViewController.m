//
//  ViewController.m
//  HySideScrollingImagePicker
//
//  Created by Apple on 15/6/30.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "ViewController.h"
#import "HySideScrollingImagePicker.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *Image;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)ImagePicker:(UIButton *)sender {
    
    HySideScrollingImagePicker *hy = [[HySideScrollingImagePicker alloc] initWithCancelStr:@"取消" otherButtonTitles:@[@"拍摄",@"从相册选择",@"更多"]];
    hy.isMultipleSelection = false;
    
    hy.SeletedImages = ^(NSArray *GetImages, NSInteger Buttonindex){
        
        if (GetImages.count != 0) {
            //取原图
            ALAsset *asset = [GetImages objectAtIndex:0];
            UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            self.Image.image = image;
        }
        
    };
    [self.view insertSubview:hy atIndex:[[self.view subviews] count]];
}

- (IBAction)ActionSheet:(UIButton *)sender {
    
    HyActionSheet *action = [[HyActionSheet alloc] initWithCancelStr:@"取消" otherButtonTitles:@[@"退出登录",@"test",@"ABC",@"BCD"] AttachTitle:@"退出登录后不会删除任何历史数据, 下次登录依然可以使用本账号,退出登录后不会删除任何历史数据, 下次登录依然可以使用本账号,退出登录后不会删除任何历史数据, 下次登录依然可以使用本账号,退出登录后不会删除任何历史数据, 下次登录依然可以使用本账号,退出登录后不会删除任何历史数据, 下次登录依然可以使用本账号,退出登录后不会删除任何历史数据, 下次登录依然可以使用本账号"];
    
    [action ChangeTitleColor:[UIColor redColor] AndIndex:1];
    
    [self.view addSubview:action];
    
    action.ButtonIndex = ^(NSInteger Buttonindex){
    
        NSLog(@"index--%ld",Buttonindex);
    
    };
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
