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

@end

@implementation AssetsLibraryD

static AssetsLibraryD *sharedAccountManagerInstance = nil;

+(AssetsLibraryD  *)sharedManager{
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

-(instancetype) init{
    
    self = [super init];
    if (self) {
        
        [self getCameraRollImages];
        
    }
    
    return self;
}


- (void)getCameraRollImages {
    _assets = [@[] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        ALAssetsLibrary *assetsLibrary = [AssetsLibraryD defaultAssetsLibrary];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                *stop = true;
            }
            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    
                    if (self.assets.count >= 100) {
                        *stop = true;
                        return ;
                    }
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
