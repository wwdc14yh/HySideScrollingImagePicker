# HySideScrollingImagePicker

![image](https://raw.githubusercontent.com/wwdc14/HySideScrollingImagePicker/FixBranch/HySideScrollingImagePicker/Untitled.gif)

### Example【示例】
```objc
    HySideScrollingImagePicker *hy = [[HySideScrollingImagePicker alloc] initWithCancelStr:@"取消" otherButtonTitles:@[@"拍摄",@"从相册选择",@"更多"]];
    hy.isMultipleSelection = false;
    
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
    [self.view insertSubview:hy atIndex:[[self.view subviews] count]];
    
```

### 显示自定义ActionSheet
```objc
    HyActionSheet *action = [[HyActionSheet alloc] initWithCancelStr:@"取消" otherButtonTitles:@[@"退出登录",@"test",@"ABC",@"BCD"] AttachTitle:@"退出登录后不会删除任何历史数据, 下次登录依然可以使用本账号"];
    
    [action ChangeTitleColor:[UIColor redColor] AndIndex:1];
    
    [self.view addSubview:action];
    
    [action ButtonIndex:^(NSInteger Buttonindex) {
       
        NSLog(@"index--%ld",Buttonindex);
        
    }];
```
# Bugs
* 已修复Block不存在导致crash
* 已修复CollectionView多选重用,导致得到的数据混乱bug
* 修复BUG:获取系统图片,图片过多的时候会崩溃.

## 期待
* 如果在使用过程中遇到BUG，希望你能Issues我
* 将模仿进行到底,让更多新手开发者了解比较酷的界面实现思路... 
* 如果觉得好用请Star!
* 谢谢!
