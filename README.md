# HySideScrollingImagePicker
[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-ObjC-brightgreen.svg?style=flat)](https://developer.apple.com/Objective-C)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://mit-license.org)

![image](https://raw.githubusercontent.com/wwdc14/HySideScrollingImagePicker/FixBranch/HySideScrollingImagePicker/Untitled.gif)

### Example【示例】

# Pop Up Photos Selection Controls【弹出照片选择控件】
```objc
    [HySideScrollingImagePicker ClassMethodsCancelStr:@"取消" otherButtonTitles:@[@"拍摄",@"从相册选择",@"更多"] isMultipleSelection:false SeletedImages:^(NSArray *GetImages, NSInteger Buttonindex) {
        //do what you want...
    }];
```
# Pop Up Custom Action Sheet【弹出底部选择框】
```objc
    HyActionSheet *action = [[HyActionSheet alloc] initWithCancelStr:@"取消" otherButtonTitles:@[@"退出登录",@"test",@"ABC",@"BCD"] AttachTitle:@"退出登录后不会删除任何历史数据, 下次登录依然可以使用本账号"];
    //改变其中一条title颜色
    [action ChangeTitleColor:[UIColor redColor] AndIndex:1];
    //Block回调
    [action ButtonIndex:^(NSInteger Buttonindex) {
        //do what you want...
    }];
```

# Fix Bugs
* 已修复Block不存在导致crash
* 已修复CollectionView多选重用,导致得到的数据混乱bug
* 修复BUG:获取系统图片,图片过多的时候会崩溃.
* 针对屏幕旋转做了支持 - Made support for screen rotation 感谢[@mythodeia](https://github.com/mythodeia)指出
* 修复iOS 9预览照片不显示bug

## 期待
* 如果在使用过程中遇到BUG，希望你能Issues我
* 将模仿进行到底,让更多新手开发者了解比较酷的界面实现思路... 
* 如果觉得好用请Star!
* 谢谢!
