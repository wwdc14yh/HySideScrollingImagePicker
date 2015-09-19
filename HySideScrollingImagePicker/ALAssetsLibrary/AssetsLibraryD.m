//
//  AssetsLibraryD.m
//  TestProject
//
//  Created by Apple on 15/6/25.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "AssetsLibraryD.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>
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

-(void)Ios9LoadImageBlock:(UpDataBlock)block{

    typeof(self) __weak weak = self;
    _GetImageBlock = block;
    _assets = [@[] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
        [assetsFetchResults enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset *objs = obj;
                [weak.assets addObject:objs];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weak.GetImageBlock) {
                weak.GetImageBlock(_assets);
            }
        });
    });
}

-(void)UpDataBlock:(UpDataBlock)block{

    typeof(self) __weak weak = self;
    _GetImageBlock = block;
    _assets = [@[] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        ALAssetsLibrary *assetsLibrary = [AssetsLibraryD defaultAssetsLibrary];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            //NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            //NSLog(@"groupName__ %@ ",name);
            //if ([name isEqualToString:@"All Photos"] || [name isEqualToString:@"Camera Roll"]) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    
                    if (result) {
                        [weak.assets insertObject:result atIndex:0];
                    }
                }];
            //}
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(_assets);
                    NSLog(@"_assets---%ld",_assets.count);
                }
            });
        } failureBlock:^(NSError *error) {
            NSLog(@"Error loading images %@", error);
        }];
    });
    
}


-(void)GetPhotosBlock:(UpDataBlock)block
{
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version < 7.0f && version > 9.0f)
    {
        [self UpDataBlock:block];
    }
    else if (version > 8.f && version <= 9.0)
    {
        [self UpDataBlock:block];
        //[self Ios9LoadImageBlock:block];
    }
}

- (void)getCameraRollImages {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
        {
            typeof(self) __weak weak = self;
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                if (*stop) {
                    //点击“好”回调方法:这里是重点
                    NSLog(@"好");
                    if (weak.isopen) {
                        if (weak.is) {
                            weak.isopen(true);
                            weak.is = false;
                        }
                    }
                    return;
                }
                *stop = TRUE;
                
            } failureBlock:^(NSError *error) {
                
                //点击“不允许”回调方法:这里是重点
                NSLog(@"不允许");
                if (weak.isopen) {
                    if (weak.is) {
                        weak.isopen(false);
                        weak.is = false;
                    }
                }
                
            }];
        }
            break;
         case PHAuthorizationStatusRestricted:
        {
            if (self.is) {
                self.isopen(false);
                self.is = false;
            }
        }
            break;
        case PHAuthorizationStatusAuthorized:
        {
            if (self.is) {
                self.isopen(true);
                self.is = true;
            }
        }
            break;
        case PHAuthorizationStatusDenied:
        {
            if (self.is) {
                self.isopen(false);
                self.is = false;
            }
        }
            break;
        default:
            break;
    }
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
