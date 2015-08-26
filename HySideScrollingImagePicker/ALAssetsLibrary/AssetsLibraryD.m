//
//  AssetsLibraryD.m
//  TestProject
//
//  Created by Apple on 15/6/25.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "AssetsLibraryD.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface AssetsLibraryD()

@property (nonatomic,strong) NSMutableArray *assets;

@end

@implementation AssetsLibraryD

-(instancetype) init{
    
    self = [super init];
    if (self) {
        
        [self getCameraRollImages];
        
    }
    
    return self;
}


- (void)getCameraRollImages {
    _assets = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    
    
    
    ALAssetsLibrary *assetsLibrary = [AssetsLibraryD defaultAssetsLibrary];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result)
            {
                [tmpAssets addObject:result];
            }
        }];
        
        
        ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                
                //                NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url
                
                //UIImage *image = [UIImage imageWithCGImage:[result aspectRatioThumbnail]];
                //                if (self.assets.count >= 1500) {
                //                    return ;
                //                }
                [self.assets addObject:result];
            }
        };
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
        if (self.GetImageBlock) {
            self.GetImageBlock(_assets);
            NSLog(@"_assets---%ld",_assets.count);
        }
        //[self.collectionView reloadData];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading images %@", error);
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
