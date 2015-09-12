//
//  ViewController.m
//  HySideScrollingImagePicker
//
//  Created by Apple on 15/6/30.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "ViewController.h"
#import "ParallAxTableViewCells.h"
#import "HySideScrollingImagePicker.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *TableView;

@property (retain, nonatomic) NSMutableArray *DataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _DataSource = [NSMutableArray array];
    
    _TableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *titleArr = @[@"ImagePicker",@"ActionSheet"];
    for (NSString *title in titleArr) {
        NSInteger index = [titleArr indexOfObject:title];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        CGFloat W = [UIScreen mainScreen].bounds.size.width / titleArr.count;
        [button setFrame:CGRectMake(index * W, 20, W, 40)];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.view addSubview:button];
        if (index != 1) {
            [button addTarget:self action:@selector(ImagePicker:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [button addTarget:self action:@selector(ActionSheet:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (CGPoint)createEndPointWithRadius:(CGFloat)itemExpandRadius andAngel:(CGFloat)angel
{
    return CGPointMake(self.view.bounds.size.width/2 - (self.view.bounds.size.width/4)/2 - cos(angel * M_PI/180) * itemExpandRadius,
                       
                       self.view.center.y - sin(angel * M_PI/180) * itemExpandRadius);
}

- (void)ImagePicker:(UIButton *)sender {
    
    HySideScrollingImagePicker *hy = [[HySideScrollingImagePicker alloc] initWithCancelStr:@"取消" otherButtonTitles:@[@"拍摄",@"从相册选择",@"更多"]];
    hy.isMultipleSelection = true;
    
    typeof(self) weak = self;
    
    [hy SeletedImages:^(NSArray *GetImages, NSInteger Buttonindex) {
       
        NSMutableArray *INDEXPaths = [NSMutableArray array];
        for (id OBJ in _DataSource) {
            NSInteger INDEX = [_DataSource indexOfObject:OBJ];
            [INDEXPaths addObject:[NSIndexPath indexPathForRow:INDEX inSection:0]];
        }
        [_DataSource removeAllObjects];
        [weak.TableView deleteRowsAtIndexPaths:INDEXPaths withRowAnimation:UITableViewRowAnimationRight];
        
        for (ALAsset *asset in GetImages) {
            NSInteger index = [GetImages indexOfObject:asset];
            UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            NSString *String = [NSString stringWithFormat:@"fileName:%@ \n Date:%@",asset.defaultRepresentation.filename,[asset valueForProperty: ALAssetPropertyDate]];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:image forKey:@"image"];
            [dict setObject:String forKey:@"string"];
            [weak.DataSource addObject:dict];
            [weak.TableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        }
        
        if (_DataSource.count != 0) {
            [UIView animateWithDuration:0.2 animations:^{
                [weak.TableView setAlpha:1.0f];
            }];
        }else{
            [UIView animateWithDuration:0.2 animations:^{
                [weak.TableView setAlpha:0.0f];
            }];
        }
    }];
}

- (void)ActionSheet:(UIButton *)sender {
    
    HyActionSheet *action = [[HyActionSheet alloc] initWithCancelStr:@"取消" otherButtonTitles:@[@"退出登录",@"test",@"ABC",@"BCD",] AttachTitle:@"退出登录后不会删除任何历史数据, 下次登录依然可以使用本账号"];
    
    [action ChangeTitleColor:[UIColor redColor] AndIndex:1];
    
    [action ButtonIndex:^(NSInteger Buttonindex) {
       
        NSLog(@"index--%ld",Buttonindex);
        
    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return PARALLAXCELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_DataSource count];
}

static NSString *cellIdentifier = @"cellIdentifier";
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ParallAxTableViewCells *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ParallAxTableViewCells alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
        
    UIImage *image = [[_DataSource objectAtIndex:indexPath.row] objectForKey:@"image"];
    NSString *str = [[_DataSource objectAtIndex:indexPath.row] objectForKey:@"string"];
    
    [cell.TitleOne setText:str];
    [cell setParallaxImageViewWithImage:image onTableView:tableView toView:self.view atRows:indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.parallaxImageView.image = image;
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    NSArray *visibleCells = [self.TableView visibleCells];
    
    for (ParallAxTableViewCells *cell in visibleCells) {
        [cell cellOnTableView:self.TableView didScrollOnView:self.view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
