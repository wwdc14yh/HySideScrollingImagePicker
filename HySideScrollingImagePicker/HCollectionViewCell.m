//
//  HCollectionViewCell.m
//  TestProject
//
//  Created by Apple on 15/6/25.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "HCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation HCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.layer.cornerRadius = 1.0f;
    imageView.layer.masksToBounds = true;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(imageView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views]];
}

-(void) setAsset:(id)asset
{
    static UIImage *image = nil;
    _asset = asset;
    if ([_asset isKindOfClass:[ALAsset class]]) {
    
        image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
        
    }else if ([_asset isKindOfClass:[PHAsset class]]){
        
        PHAsset *PHAsset = _asset;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.normalizedCropRect = CGRectMake(0, 0, PHAsset.pixelWidth, PHAsset.pixelHeight);
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.networkAccessAllowed = YES;
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //self.progressView.progress = progress;
                //self.progressView.hidden = (progress <= 0.0 || progress >= 1.0);
                NSLog(@"progress--%f",progress);
            });
        };
        
        [[PHImageManager defaultManager] requestImageForAsset:PHAsset targetSize:CGSizeMake(PHAsset.pixelWidth, PHAsset.pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
           
            if (result) {
                image = result;
            }
            
        }];
//        PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
//        [imageManager requestImageForAsset:PHAsset targetSize:CGSizeMake(PHAsset.pixelWidth, PHAsset.pixelHeight) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            
//
//            if (result) {
//                image = result;
//            }
//        }];
    }
    [self SetImage:image];
}

-(void)SetImage:(UIImage *)image
{
    _imageView.image = image;
}

- (void)prepareForReuse
{
    [self setSelected:NO];
}

@end
