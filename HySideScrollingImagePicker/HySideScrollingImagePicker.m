//
//  HySideScrollingImagePicker.m
//  TestProject
//
//  Created by Apple on 15/6/25.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "HySideScrollingImagePicker.h"
#import "SideScrollingLayout.h"
#import "HCollectionViewCell.h"
#import "SideScrollingCheckCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "AssetsLibraryD.h"


#define kImageSpacing 5.0f
#define kCollectionViewHeight 178.0f
#define kSubTitleHeight 65.0f
#define ItemHeight 50.0f
#define H [UIScreen mainScreen].bounds.size.height
#define W [UIScreen mainScreen].bounds.size.width
#define Color [UIColor colorWithRed:26/255.0f green:178.0/255.0f blue:10.0f/255.0f alpha:1]
#define Spacing 7.0f
#define KMaxSize CGSizeMake(W-20, 100)


@interface HySideScrollingImagePicker ()<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate>

{
    UIWindow *window;
}

@property (nonatomic,copy)NSString *cancelStr;

@property (nonatomic,strong)NSArray *ButtonTitles;

@property (nonatomic,weak) UIView * BottomView;

@property (nonatomic,weak)UICollectionView *CollectionView;

@property (nonatomic, strong) NSMapTable *indexPathToCheckViewTable;

@property (nonatomic,strong) NSMutableArray *allArr;

@property (nonatomic, strong) NSMutableArray *selectedIndexes;

@property (nonatomic,strong)NSIndexPath	* lastIndexPath;

@property (nonatomic,strong)NSMutableArray *assetsGroups;

@property (nonatomic,retain)NSMutableArray *IndexPathArr;

@property (retain, nonatomic) AssetsLibraryD *assets;

@end

@interface Window : UIWindow

@property (nonatomic, weak)   UIView  *rootView;

@end

@implementation Window

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end

@implementation HySideScrollingImagePicker

-(instancetype) initWithCancelStr:(NSString *)str otherButtonTitles:(NSArray *)Titles{
    
    self = [super init];
    if (self) {
        _cancelStr = str;
        _ButtonTitles = Titles;
        [self loadData];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarOrientationChange:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    [self adaptUIBaseOnOriention];//比如改变self.frame
}

-(void)adaptUIBaseOnOriention
{
    CGFloat height = ((ItemHeight+0.5f)+Spacing) + (_ButtonTitles.count * (ItemHeight+0.5f)) + kCollectionViewHeight;
    UIView *TopView = [self viewWithTag:999];
    [TopView setFrame:CGRectMake(0, 0, W, H - height)];
    if (height > H) {
        [_BottomView setFrame:CGRectMake(0, 0, W, H)];
        NSLog(@"%f",CGRectGetMaxY(_CollectionView.frame));
        CGFloat He = H - (CGRectGetMaxY(_CollectionView.frame) + Spacing*2);
        CGFloat BtnH = He / ((_ButtonTitles.count)+1);
        UIButton *Cancebtn = (UIButton *)[self viewWithTag:100];
        [Cancebtn setFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - BtnH, W, BtnH)];
        for (NSString *Title in _ButtonTitles) {
            NSInteger index = [_ButtonTitles indexOfObject:Title];
            
            UIButton *btn = (UIButton *)[_BottomView viewWithTag:(index + 100)+1];
            CGFloat Y = (BtnH *index) + (CGRectGetMaxY(_CollectionView.frame) +Spacing);
            [btn setFrame:CGRectMake(0, Y, W, BtnH)];
            UIView *lin = [btn viewWithTag:(index + 1010)+1];
            [lin setFrame:CGRectMake(0, CGRectGetHeight(btn.bounds) - 0.5f, W, 0.5f)];
        }
        return;
    }
    [_BottomView setFrame:CGRectMake(0, H - height, W, height)];
    UIButton *Cancebtn = (UIButton *)[self viewWithTag:100];
    [Cancebtn setFrame:CGRectMake(0, CGRectGetHeight(_BottomView.bounds) - ItemHeight, W, ItemHeight)];
    for (NSString *Title in _ButtonTitles) {
        NSInteger index = [_ButtonTitles indexOfObject:Title];
        
        UIButton *btn = (UIButton *)[_BottomView viewWithTag:(index + 100)+1];
        CGFloat hei = (50 * _ButtonTitles.count)+Spacing;
        CGFloat y = (CGRectGetMinY(Cancebtn.frame) + (index * (ItemHeight))) - hei;
        [btn setFrame:CGRectMake(0, y, W, ItemHeight)];
        UIView *lin = [btn viewWithTag:(index + 1010)+1];
        [lin setFrame:CGRectMake(0, CGRectGetHeight(btn.bounds) - 0.5f, W, 0.5f)];
    }
}

- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

-(void)LoadUI{
    self.selectedIndexes = [NSMutableArray array];
    /*self*/
    [self setFrame:CGRectMake(0, 0, W, H)];
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    [self setBackgroundColor:[UIColor clearColor]];
    /*end*/
    
    /*buttomView*/
    UIView *ButtomView;
    UIView *TopView;
    NSInteger Ids = 0;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统
    if (version >= 8.0f) {
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        ButtomView = [[UIVisualEffectView alloc] initWithEffect:blur];
        
    }else if(version >= 7.0f){
        
        ButtomView = [[UIToolbar alloc] init];
        
    }else{
        
        ButtomView = [[UIView alloc] init];
        Ids = true;
        
    }
    if (Ids == 1) {
        ButtomView.backgroundColor = [UIColor colorWithRed:223.0f/255.0f green:226.0f/255.f blue:236.0f/255.0f alpha:1];
    }
    CGFloat height = ((ItemHeight+0.5f)+Spacing) + (_ButtonTitles.count * (ItemHeight+0.5f)) + kCollectionViewHeight;
    
    [ButtomView setFrame:CGRectMake(0, H, W, height)];
    _BottomView = ButtomView;
    ButtomView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:ButtomView];
    
    TopView = [[UIView alloc] init];
    TopView.backgroundColor = [UIColor clearColor];
    [TopView setTag:999];
    [TopView setFrame:CGRectMake(0, 0, W, H)];
    TopView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [self addSubview:TopView];
    /*end*/
    
    /*CanceBtn*/
    UIButton *Cancebtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [Cancebtn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5f]];
    [Cancebtn setFrame:CGRectMake(0, CGRectGetHeight(ButtomView.bounds) - ItemHeight, W, ItemHeight)];
    [Cancebtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [Cancebtn setTitle:_cancelStr forState:UIControlStateNormal];
    [Cancebtn addTarget:self action:@selector(SelectedButtons:) forControlEvents:UIControlEventTouchUpInside];
    [Cancebtn addTarget:self action:@selector(scaleToSmall:)
  forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [Cancebtn addTarget:self action:@selector(scaleAnimation:)
  forControlEvents:UIControlEventTouchUpInside];
    [Cancebtn addTarget:self action:@selector(scaleToDefault:)
  forControlEvents:UIControlEventTouchDragExit];
    [Cancebtn setTag:100];
    Cancebtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [_BottomView addSubview:Cancebtn];
    /*end*/
    
    /*Items*/
    for (NSString *Title in _ButtonTitles) {
        
        NSInteger index = [_ButtonTitles indexOfObject:Title];
        
        UIButton *btn = [[UIButton alloc] init];
        [btn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5f]];
        
        CGFloat hei = (50 * _ButtonTitles.count)+Spacing;
        CGFloat y = (CGRectGetMinY(Cancebtn.frame) + (index * (ItemHeight))) - hei;
        
        [btn setFrame:CGRectMake(0, y, W, ItemHeight)];
        [btn setTag:(index + 100)+1];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:Title forState:UIControlStateNormal];
        [btn titleLabel].font = [UIFont systemFontOfSize:15.0f];
        [btn addTarget:self action:@selector(SelectedButtons:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(scaleToSmall:)
       forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [btn addTarget:self action:@selector(scaleAnimation:)
       forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(scaleToDefault:)
       forControlEvents:UIControlEventTouchDragExit];
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        [_BottomView addSubview:btn];
        if ((index+1) == _ButtonTitles.count) {
            break;
        }
        UIView *lin = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(btn.bounds) - 0.5f, W, 0.5f)];
        lin.backgroundColor = [UIColor colorWithRed:228.0f/255 green:229.0f/255 blue:230.f/255 alpha:1];
        [lin setTag:(index + 1010)+1];
        lin.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        [btn addSubview:lin];
    }
    /*END*/
    
    /*CollectionView*/
    
    // Configure the flow layout
    SideScrollingLayout *flow = [[SideScrollingLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumInteritemSpacing = kImageSpacing;
    
    // Configure the collection view
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.allowsMultipleSelection = YES;
    collectionView.allowsSelection = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.collectionViewLayout = flow;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [collectionView registerClass:[HCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [collectionView registerClass:[SideScrollingCheckCell class] forSupplementaryViewOfKind:@"check" withReuseIdentifier:@"CheckCell"];
    collectionView.contentInset = UIEdgeInsetsMake(0, 6, 0, 6);
    
    [ButtomView addSubview:collectionView];
    self.CollectionView = collectionView;
    
    self.CollectionView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.indexPathToCheckViewTable = [NSMapTable strongToWeakObjectsMapTable];
    
    [self.CollectionView setFrame:CGRectMake(0, 5, W, kCollectionViewHeight-10)];
    
    UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.CollectionView.bounds)/2 - 10 , CGRectGetHeight(self.CollectionView.bounds)/2 - 10, 20, 20)];
    act.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [act setTag:10101];
    [act startAnimating];
    [self.CollectionView addSubview:act];
    
    /*enb*/
    typeof(self) __weak weak = self;
    __block BOOL stop = true;
    
    [_assets GetPhotosBlock:^(NSArray *ImgsData) {
       
        if (stop) {
            weak.allArr = [NSMutableArray arrayWithArray:ImgsData];
            [weak.CollectionView reloadData];
            [act stopAnimating];
            if (ImgsData.count != 0) {
                stop = FALSE;
            }
        }
        
    }];
    
    [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        [TopView setFrame:CGRectMake(0, 0, W, H - height)];
        [TopView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f]];
        [ButtomView setFrame:CGRectMake(0, H - height, W, height+10)];
        
    } completion:^(BOOL finished) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:weak action:@selector(dismiss:)];
        tap.delegate = self;
        [TopView addGestureRecognizer:tap];
        [ButtomView setFrame:CGRectMake(0, H - height, W, height)];
        [UIView animateWithDuration:0.2 animations:^{
            if (height > H) {
                [weak adaptUIBaseOnOriention];
            }
        }];
    }];
}

-(AssetsLibraryD *)assets
{
    if (!_assets) {
        _assets = [[AssetsLibraryD alloc] init];
    }
    return _assets;
}

-(void)loadData{

    typeof(self) __weak weak = self;
    _assets = [self assets];
    [_assets setUserIsOpen:^(BOOL is) {
        
        if (!is) {
            return ;
        }
        _IndexPathArr = [NSMutableArray array];
        [weak LoadUI];
        [weak addSubview];
        NSLog(@"end");
    }];
}

-(void)addSubview
{
    UIViewController *toVC = [self appRootViewController];
    if (toVC.tabBarController != nil) {
        [toVC.tabBarController.view addSubview:self];
    }else if (toVC.navigationController != nil){
        [toVC.navigationController.view addSubview:self];
    }else{
        [toVC.view addSubview:self];
    }
}

-(void)scaleToSmall:(UIButton *)btn{
    
    [UIView animateWithDuration:0.2 animations:^{
        [btn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.0f]];
    }];
    
}

- (void)scaleAnimation:(UIButton *)btn{

    [UIView animateWithDuration:0.2 animations:^{
        [btn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.0f]];
    }];
    
}

- (void)scaleToDefault:(UIButton *)btn{

    [UIView animateWithDuration:0.2 animations:^{
        [btn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5f]];
    }];
    
}

-(void)SelectedButtons:(UIButton *)btns{
    
    typeof(self) __weak weak = self;
    [self DismissBlock:^(BOOL Complete) {
        
        weak.SeletedImages(weak.selectedIndexes,btns.tag-100);
        
    }];
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return MIN(100, _allArr.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    HCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    id asset = [_allArr objectAtIndex:indexPath.row];
    
    //UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    
    cell.asset = asset;
    //cell.imageView.image = image;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{
    SideScrollingCheckCell *checkView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CheckCell" forIndexPath:indexPath];
    [self.indexPathToCheckViewTable setObject:checkView forKey:indexPath];
    
    if ([self.IndexPathArr containsObject:indexPath]) {
        [checkView setChecked:YES];
    }else{
        [checkView setChecked:FALSE];
    }
    return checkView;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    //[collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionRight];
    [self toggleSelectionAtIndexPath:indexPath];
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self toggleSelectionAtIndexPath:indexPath];

}

- (void)toggleSelectionAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *Ti = (UIButton *)[_BottomView viewWithTag:101];
    
    HCollectionViewCell *cell = (HCollectionViewCell *)[self.CollectionView cellForItemAtIndexPath:indexPath];
    SideScrollingCheckCell *checkmarkView = [self.indexPathToCheckViewTable objectForKey:indexPath];
    
    if (_isMultipleSelection) {
        
        // Manage internal selection state
        if ([self.IndexPathArr containsObject:indexPath]) {

            [_selectedIndexes removeObject:cell.asset];
            [_IndexPathArr removeObject:indexPath];
            [cell setSelected:NO];
            [checkmarkView setChecked:NO];
            
        } else {
            
            [self.selectedIndexes addObject:cell.asset];
            [cell setSelected:YES];
            [checkmarkView setChecked:YES];
            [_IndexPathArr addObject:indexPath];
        }
        
    }else{
        
        [self.selectedIndexes addObject:cell.asset];
        [cell setSelected:YES];
        [checkmarkView setChecked:YES];
        typeof(self) __weak weak = self;
        [self DismissBlock:^(BOOL Complete) {
            weak.SeletedImages(self.selectedIndexes,MAXFLOAT);
        }];
        
    }
    if (self.selectedIndexes.count == 0) {
        
        [Ti setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [Ti setTitle:[_ButtonTitles objectAtIndex:Ti.tag-101] forState:UIControlStateNormal];
        
    }else{
        
        [Ti setTitle:[NSString stringWithFormat:@"选择(%ld张)",self.selectedIndexes.count] forState:UIControlStateNormal];
        [Ti setTitleColor:Color forState:UIControlStateNormal];
        
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    id asset = [_allArr objectAtIndex:indexPath.row];
    static UIImage *image = nil;
    
    if ([asset isKindOfClass:[ALAsset class]]) {
        
        image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
        
    }else if ([asset isKindOfClass:[PHAsset class]]){
        CGFloat scale = [UIScreen mainScreen].scale;
        PHAsset *PHAsset = asset;
        NSLog(@"scale-%f",scale);
        PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
        [imageManager requestImageForAsset:PHAsset targetSize:CGSizeMake(PHAsset.pixelWidth / scale, PHAsset.pixelHeight * scale) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                image = result;
            }
        }];
    }
    
    UIImage *imageAtPath = image;
    
    CGFloat imageHeight = imageAtPath.size.height;
    CGFloat viewHeight = collectionView.bounds.size.height;
    CGFloat scaleFactor = viewHeight/imageHeight;
    
    CGSize scaledSize = CGSizeApplyAffineTransform(imageAtPath.size, CGAffineTransformMakeScale(scaleFactor, scaleFactor));
    return scaledSize;
}

-(void)DismissBlock:(CompleteAnimationBlock)block{
    
    //typeof(self) __weak weak = self;
    CGFloat height = ((ItemHeight+0.5f)+Spacing) + (_ButtonTitles.count * (ItemHeight+0.5f)) + kCollectionViewHeight;
    UIView *TopView = [self viewWithTag:999];
    typeof(self) __block weak = self;
    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [TopView setFrame:CGRectMake(0, 0, W, H)];
        [TopView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f]];
        [weak.BottomView setFrame:CGRectMake(0, H, W, height)];
        
    } completion:^(BOOL finished) {
        
        block(finished);
        [weak removeFromSuperview];
        
    }];
    
}

-(void)SeletedImages:(SeletedImages)SeletedImage{

    _SeletedImages = SeletedImage;
}

-(void)dismiss:(UITapGestureRecognizer *)tap{
    
    if( CGRectContainsPoint(self.frame, [tap locationInView:_BottomView])) {
        NSLog(@"tap");
    } else{
        
        [self DismissBlock:^(BOOL Complete) {
            
        }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *TopView = [self viewWithTag:999];
    if (touch.view != TopView) {
        return NO;
    }
    
    return YES;
}

-(void)dealloc
{
    NSLog(@"正常释放");
}

-(void)removeFromSuperview{
    _allArr = nil;
    _ButtonTitles = nil;
    _BottomView = nil;
    _CollectionView = nil;
    _assets = nil;
    _assetsGroups = nil;
    _IndexPathArr = nil;
    _lastIndexPath = nil;
    _selectedIndexes = nil;
    _SeletedImages = nil;
    _indexPathToCheckViewTable = nil;
    NSArray *SubViews = [window subviews];
    for (id obj in SubViews) {
        [obj removeFromSuperview];
    }
    [window resignKeyWindow];
    [window removeFromSuperview];
    window = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

-(void)show{
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = UIWindowLevelAlert;
    window.backgroundColor = [UIColor clearColor];
    window.alpha = 1;
    window.hidden = false;
    [window addSubview:self];
}


-(UIViewController *)viewController:(UIView *)view{
    /// Finds the view's view controller.
    // Traverse responder chain. Return first found view controller, which will be the view's view controller.
    UIResponder *responder = view;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: [UIViewController class]])
            return (UIViewController *)responder;
    // If the view controller isn't found, return nil.
    return nil;
}


@end

@class HyActionSheet;

@interface HyActionSheet ()<UIGestureRecognizerDelegate>
{
    UIWindow *window;
}

@property (nonatomic,copy)      NSString *CancelStr;

@property (nonatomic,strong)    NSArray *Titles;

@property (nonatomic,weak)      UIView *ButtomView;

@property (nonatomic,copy)      NSString *AttachTitle;

@end

@implementation HyActionSheet

-(instancetype) initWithCancelStr:(NSString *)str otherButtonTitles:(NSArray *)Titles AttachTitle:(NSString *)AttachTitle{
    
    self = [super init];
    
    if (self) {
        
        _AttachTitle = AttachTitle;
        _CancelStr = str;
        _Titles = Titles;
        [self loadUI];
        [self addSubview];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarOrientationChange:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    
    return self;
}

-(void)addSubview
{
    UIViewController *toVC = [self appRootViewController];
    if (toVC.tabBarController != nil) {
        [toVC.tabBarController.view addSubview:self];
    }else if (toVC.navigationController != nil){
        [toVC.navigationController.view addSubview:self];
    }else{
        [toVC.view addSubview:self];
    }
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    [self adaptUIBaseOnOriention];
}

-(void)adaptUIBaseOnOriention
{
    CGFloat height;
    UIFont *font = [UIFont systemFontOfSize:12.0f];
    if ([self isBlankString:_AttachTitle]) {
        height = ((ItemHeight)+Spacing) + (_Titles.count * (ItemHeight));
    }else{
        CGSize size = [self markGetAuthenticSize:_AttachTitle Font:font MaxSize:KMaxSize];
        height  = ((ItemHeight)+Spacing) + (_Titles.count * (ItemHeight)) + (size.height+50);
    }
    UIView *views = [self viewWithTag:9090];
    UIView *TopView = [self viewWithTag:999];
    [TopView setFrame:CGRectMake(0, 0, W, H - height)];
    if (height > H) {
        [_ButtomView setFrame:CGRectMake(0, 0, W, H)];
        CGFloat He = H - (CGRectGetHeight(views.bounds) + Spacing);
        CGFloat BtnH = He / ((_Titles.count)+1);
        UIButton *Cancebtn = (UIButton *)[self viewWithTag:100];
        [Cancebtn setFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - BtnH, W, BtnH)];
        for (NSString *Title in _Titles) {
            NSInteger index = [_Titles indexOfObject:Title];
            
            UIButton *btn = (UIButton *)[_ButtomView viewWithTag:(index + 100)+1];
            //CGFloat hei = (BtnH * _ButtonTitles.count)+Spacing;
            //CGFloat y = (CGRectGetMinY(Cancebtn.frame) + (index * (BtnH))) - hei;
            CGFloat Y = (BtnH *index) + (CGRectGetHeight(views.bounds));
            [btn setFrame:CGRectMake(0, Y, W, BtnH)];
            UIView *lin = [btn viewWithTag:(index + 1010)+1];
            [lin setFrame:CGRectMake(0, 0.5f, W, 0.5f)];
        }
        return;
    }
    [_ButtomView setFrame:CGRectMake(0, H - height, W, height)];
    UIButton *Cancebtn = (UIButton *)[self viewWithTag:100];
    [Cancebtn setFrame:CGRectMake(0, CGRectGetHeight(_ButtomView.bounds) - ItemHeight, W, ItemHeight)];
    for (NSString *Title in _Titles) {
        NSInteger index = [_Titles indexOfObject:Title];
        
        UIButton *btn = (UIButton *)[_ButtomView viewWithTag:(index + 100)+1];
        CGFloat Y = (ItemHeight *index) + (CGRectGetHeight(views.bounds));
        [btn setFrame:CGRectMake(0, Y, W, ItemHeight)];
        UIView *lin = [btn viewWithTag:(index + 1010)+1];
        [lin setFrame:CGRectMake(0, 0, W, 0.5f)];
    }
}

- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}


-(void)loadUI{
    
    /*self*/
    [self setFrame:CGRectMake(0, 0, W, H)];
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    [self setBackgroundColor:[UIColor clearColor]];
    /*end*/
    
    /*buttomView*/
    UIView *ButtomView;
    UIView *TopView;
    NSInteger Ids = 0;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统
    if (version >= 8.0f) {
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        ButtomView = [[UIVisualEffectView alloc] initWithEffect:blur];
        
    }else if(version >= 7.0f){
        
        ButtomView = [[UIToolbar alloc] init];
        
    }else{
        
        ButtomView = [[UIView alloc] init];
        Ids = true;
        
    }
    if (Ids == 1) {
        ButtomView.backgroundColor = [UIColor colorWithRed:223.0f/255.0f green:226.0f/255.f blue:236.0f/255.0f alpha:1];
    }
    CGFloat height;
    UIFont *font = [UIFont systemFontOfSize:12.0f];
    CGSize size = [self markGetAuthenticSize:_AttachTitle Font:font MaxSize:KMaxSize];
    
    if ([self isBlankString:_AttachTitle]) {
        height = ((ItemHeight)+Spacing) + (_Titles.count * (ItemHeight));
    }else{
        height  = ((ItemHeight)+Spacing) + (_Titles.count * (ItemHeight)) + (size.height+50);
    }
    
    [ButtomView setFrame:CGRectMake(0, H , W, height)];
    _ButtomView = ButtomView;
    ButtomView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:ButtomView];
    
    TopView = [[UIView alloc] init];
    TopView.backgroundColor = [UIColor clearColor];
    [TopView setTag:999];
    [TopView setFrame:CGRectMake(0, 0, W, H)];
    TopView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [self addSubview:TopView];
    /*end*/
    
    /*CanceBtn*/
    UIButton *Cancebtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [Cancebtn setFrame:CGRectMake(0, CGRectGetHeight(ButtomView.bounds) - ItemHeight, W, ItemHeight)];
    [Cancebtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [Cancebtn setTitle:_CancelStr forState:UIControlStateNormal];
    [Cancebtn addTarget:self action:@selector(SelectedButtons:) forControlEvents:UIControlEventTouchUpInside];
    [Cancebtn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.6f]];
    [Cancebtn addTarget:self action:@selector(scaleToSmall:)
       forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [Cancebtn addTarget:self action:@selector(scaleAnimation:)
       forControlEvents:UIControlEventTouchUpInside];
    [Cancebtn addTarget:self action:@selector(scaleToDefault:)
       forControlEvents:UIControlEventTouchDragExit];
    [Cancebtn setTag:100];
    [_ButtomView addSubview:Cancebtn];
    /*end*/
    
    /*Items*/
    for (NSString *Title in _Titles) {
        
        NSInteger index = [_Titles indexOfObject:Title];
        
        UIButton *btn = [[UIButton alloc] init];
        [btn setBackgroundColor:[UIColor whiteColor]];
        
        CGFloat hei = (50 * _Titles.count)+Spacing;
        CGFloat y = (CGRectGetMinY(Cancebtn.frame) + (index * (ItemHeight))) - hei;
        
        [btn setFrame:CGRectMake(0, y, W, ItemHeight)];
        [btn setTag:(index + 100)+1];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:Title forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(SelectedButtons:) forControlEvents:UIControlEventTouchUpInside];
        [btn titleLabel].font = [UIFont systemFontOfSize:15.0f];
        [btn addTarget:self action:@selector(SelectedButtons:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(scaleToSmall:)
      forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [btn addTarget:self action:@selector(scaleAnimation:)
      forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(scaleToDefault:)
      forControlEvents:UIControlEventTouchDragExit];
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        [btn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.6f]];
        
        UIView *lin = [[UIView alloc]initWithFrame:CGRectMake(0, 0, W, 0.5f)];
        lin.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1];
        [_ButtomView addSubview:btn];
        [lin setTag:(index + 1010)+1];
        lin.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        [btn addSubview:lin];
    }
    /*END*/
    
    if ([self isBlankString:_AttachTitle]) {
        
    }else{
        
        UIView *views = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, size.height+50)];
        views.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        
        views.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6f];
        UILabel *AttachTitleView = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, W-20, size.height+50)];
        AttachTitleView.font = font;
        AttachTitleView.textColor = [UIColor grayColor];
        AttachTitleView.text = _AttachTitle;
        AttachTitleView.numberOfLines = 0;
        AttachTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        AttachTitleView.textAlignment = 1;
        [_ButtomView addSubview:views];
        [views addSubview:AttachTitleView];
        [views setTag:9090];
        [self layoutIfNeeded];
    }
    
    typeof(self) __weak weak = self;
    [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        //[weak setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f]];
        [TopView setFrame:CGRectMake(0, 0, W, H - height)];
        [TopView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f]];
        [ButtomView setFrame:CGRectMake(0, H - height, W, height+10)];
        
    } completion:^(BOOL finished) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:weak action:@selector(dismiss:)];
        tap.delegate = self;
        [TopView addGestureRecognizer:tap];
        [ButtomView setFrame:CGRectMake(0, H - height, W, height)];
        [UIView animateWithDuration:0.2 animations:^{
            if (height > H) {
                [weak adaptUIBaseOnOriention];
            }
        }];
    }];
    
}

-(void)scaleToSmall:(UIButton *)btn{
    
    [UIView animateWithDuration:0.2 animations:^{
        [btn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.0f]];
    }];
    
}

- (void)scaleAnimation:(UIButton *)btn{
    
    [UIView animateWithDuration:0.2 animations:^{
        [btn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.0f]];
    }];
    
}

- (void)scaleToDefault:(UIButton *)btn{
    
    [UIView animateWithDuration:0.2 animations:^{
        [btn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.6f]];
    }];
    
}

-(void)SelectedButtons:(UIButton *)btns{
    
    typeof(self) __weak weak = self;
    [self DismissBlock:^(BOOL Complete) {
        
        if (!weak.ButtonIndex) {
            return ;
        }
        weak.ButtonIndex(btns.tag-100);
        
    }];
    
    
}

-(void) ChangeTitleColor:(UIColor *)color AndIndex:(NSInteger )index{
    
    UIButton *btn = (UIButton *)[_ButtomView viewWithTag:index + 100];
    [btn setTitleColor:color forState:UIControlStateNormal];
    
}

-(void)ButtonIndex:(SeletedButtonIndex)ButtonIndex{

    _ButtonIndex = ButtonIndex;
    
}

-(void)dismiss:(UITapGestureRecognizer *)tap{
    
    if( CGRectContainsPoint(self.frame, [tap locationInView:_ButtomView])) {
        NSLog(@"tap");
    } else{
        
        [self DismissBlock:^(BOOL Complete) {
            
        }];
    }
}

-(void)DismissBlock:(CompleteAnimationBlock)block{
    
    
    typeof(self) __weak weak = self;
    CGFloat height = ((ItemHeight+0.5f)+Spacing) + (_Titles.count * (ItemHeight+0.5f)) + kCollectionViewHeight;
    UIView *TopView = [self viewWithTag:999];
    
    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        [TopView setFrame:CGRectMake(0, 0, W, H)];
        [TopView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f]];
        
        [_ButtomView setFrame:CGRectMake(0, H, W, height)];
        
    } completion:^(BOOL finished) {
        
        block(finished);
        [weak removeFromSuperview];
        
    }];
    
}

- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

-(void)show{
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = UIWindowLevelAlert;
    window.backgroundColor = [UIColor clearColor];
    window.alpha = 1;
    window.hidden = false;
    [window addSubview:self];
}

-(void)dealloc{
    NSLog(@"正常释放");
}

-(void)removeFromSuperview{
    NSArray *SubViews = [self subviews];
    for (id obj in SubViews) {
        [obj removeFromSuperview];
    }
    [window resignKeyWindow];
    [window removeFromSuperview];
    window = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
    NSLog(@"不能正常结束?");
}

-(CGSize)markGetAuthenticSize:(NSString *)text Font:(UIFont *)font MaxSize:(CGSize)size{
    
    //获取当前那本属性
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    //实际尺寸
    CGSize actualSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
    return actualSize;
    
}

@end
