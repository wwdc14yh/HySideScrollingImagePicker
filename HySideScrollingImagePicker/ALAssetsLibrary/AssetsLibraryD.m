//
//  AssetsLibraryD.m
//  TestProject
//
//  Created by Apple on 15/6/25.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "AssetsLibraryD.h"
#import <objc/runtime.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AssetsLibraryD()

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@property (assign, nonatomic) BOOL is;

@end

@implementation AssetsLibraryD

-(instancetype) init
{
    self = [super init];
    if (self) {
        _is = true;
    }
    return self;
}

- (NSMutableArray *)assets
{
    if (_assets == nil) {
        _assets = [[NSMutableArray alloc] init];
    }
    return _assets;
}

- (ALAssetsLibrary *)assetsLibrary
{
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

-(void)setUserIsOpen:(UserIsOpen)block
{
    _isopen = block;
    [self getCameraRollImages];
    
}

-(void)UpDataBlock:(UpDataBlock)block{

    _GetImageBlock = block;
    _assets = [@[] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        ALAssetsLibrary *assetsLibrary = [AssetsLibraryD defaultAssetsLibrary];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                *stop = true;
            }
            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result) {
                    [self.assets insertObject:result atIndex:0];
                }
            };
            if (self.GetImageBlock) {
                self.GetImageBlock(_assets);
                NSLog(@"_assets---%ld",_assets.count);
            }
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
            [group setAssetsFilter:onlyPhotosFilter];
            [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
            
        } failureBlock:^(NSError *error) {
            NSLog(@"Error loading images %@", error);
        }];
        
    });
    
}

- (void)getCameraRollImages {
    
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            if (*stop) {
                //点击“好”回调方法:这里是重点
                NSLog(@"好");
                if (_isopen) {
                    if (_is) {
                        _isopen(true);
                        _is = false;
                    }
                }
                return;
                
            }
            *stop = TRUE;
            
        } failureBlock:^(NSError *error) {
            
            //点击“不允许”回调方法:这里是重点
            NSLog(@"不允许");
            if (_isopen) {
                if (_is) {
                    _isopen(false);
                    _is = false;
                }
            }
            
        }];
    
    
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}


@end
