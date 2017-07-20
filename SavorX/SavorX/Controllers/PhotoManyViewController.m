//
//  PhotoManyViewController.m
//  SavorX
//
//  Created by 郭春城 on 17/2/13.
//  Copyright © 2017年 郭春城. All rights reserved.
//


#import "PhotoManyViewController.h"
#import "PhotoManyCollectionViewCell.h"
#import "PhotoHandleView.h"
#import "PhotoManyEditView.h"
#import "GCCUPnPManager.h"
#import "OpenFileTool.h"
#import "RDPhotoTool.h"
#import <Photos/Photos.h>
#import "RDHomeStatusView.h"
#import "RDInteractionLoadingView.h"

#import "GCCGetInfo.h"

#define PhotoManyCell @"PhotoManyCell"

@interface PhotoManyViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, PhotoManyEditViewDelegate>

@property (nonatomic, strong) PHFetchResult * PHAssetSource;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout * flowLayout;
@property (nonatomic, assign) NSInteger index;

//@property (nonatomic, strong) PhotoHandleView * rotateView; //旋转控制按钮
@property (nonatomic, strong) UIButton * rotateView; //旋转控制按钮
@property (nonatomic, strong) UIButton * textView; //文字控制按钮
@property (nonatomic, strong) NSURLSessionDataTask * task;
@property (nonatomic, assign) BOOL isScreen;

@end

@implementation PhotoManyViewController

- (instancetype)initWithPHAssetSource:(id)source andIndex:(NSInteger)index
{
    if (self = [super init]) {
        self.PHAssetSource = source;
        self.title = @"我的照片";
        self.index = index;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    
    [SAVORXAPI postUMHandleWithContentId:@"home_pic" key:nil value:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)setupViews
{
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.itemSize = CGSizeMake(kMainBoundsWidth, kMainBoundsHeight - kNaviBarHeight - kStatusBarHeight);
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight - kNaviBarHeight - kStatusBarHeight) collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[PhotoManyCollectionViewCell class] forCellWithReuseIdentifier:PhotoManyCell];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.scrollsToTop = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self dataSourceCount] * 50 + self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    self.rotateView = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rotateView setImage:[UIImage imageNamed:@"xaunzhuan"] forState:UIControlStateNormal];
    [self.rotateView setTitle:@"旋转" forState:UIControlStateNormal];
    [self.rotateView setBackgroundColor:[kThemeColor colorWithAlphaComponent:.94f]];
    [self.rotateView addTarget:self action:@selector(rotateImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rotateView];
    [self.rotateView setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [self.rotateView setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.rotateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth / 2, 50));
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    self.textView = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.textView setImage:[UIImage imageNamed:@"wenzi"] forState:UIControlStateNormal];
    [self.textView setTitle:@"文字" forState:UIControlStateNormal];
    [self.textView setBackgroundColor:[kThemeColor colorWithAlphaComponent:.94f]];
    [self.textView addTarget:self action:@selector(addTextOnImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.textView];
    [self.textView setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [self.textView setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth / 2, 50));
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    UIView * lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.textView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(-10);
        make.width.mas_equalTo(.5f);
    }];
    
    if ([GlobalData shared].isBindRD) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出投屏" style:UIBarButtonItemStyleDone target:self action:@selector(stopScreenImage:)];
        self.isScreen = YES;
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenCurrentImage)];
        [SAVORXAPI showConnetToTVAlert:@"photo"];
        self.isScreen = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenCurrentImage) name:RDDidBindDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenBeQiutWithBox) name:RDBoxQuitScreenNotification object:nil];
}

- (void)screenBeQiutWithBox
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenCurrentImage)];
    self.isScreen = NO;
}

- (void)screenCurrentImage
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (![GlobalData shared].isBindRD) {
        [[RDHomeStatusView defaultView] scanQRCode];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return;
    }
    RDInteractionLoadingView * hud = [[RDInteractionLoadingView alloc] initWithView:self.view title:@"正在投屏"];
    PhotoManyCollectionViewCell * cell = [self currentCell];
    NSInteger index = [self pageControlIndexWithCurrentCellIndex:[self currentIndex]];
    PHAsset * asset = [self.PHAssetSource objectAtIndex:index];
    NSString * name = asset.localIdentifier;
    if (cell.hasEdit) {
        
        if ([GlobalData shared].isBindRD) {
            [RDPhotoTool compressImageWithImage:[cell getCellEditImage] finished:^(NSData *minData, NSData *maxData) {
                
                [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:1 isThumbnail:YES rotation:0 seriesId:nil force:0 success:^{
                    
                    [hud hidden];
                    [[RDHomeStatusView defaultView] startScreenWithViewController:self withStatus:RDHomeStatus_Photo];
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出投屏" style:UIBarButtonItemStyleDone target:self action:@selector(stopScreenImage:)];
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    self.isScreen = YES;
                    
                    [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:1 isThumbnail:NO rotation:0 seriesId:nil force:0 success:^{
                        
                    } failure:^{
                        
                    }];
                    
                    
                } failure:^{
                    [hud hidden];
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    self.isScreen = NO;
                }];
            }];
        }
    }else{
        [self getImageFromPHAssetSourceWithIndex:[self pageControlIndexWithCurrentCellIndex:[self currentIndex]] success:^(UIImage *result) {
            if ([GlobalData shared].isBindRD) {
                [RDPhotoTool compressImageWithImage:result finished:^(NSData *minData, NSData *maxData) {
                    
                    [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:1 isThumbnail:YES rotation:0 seriesId:nil force:0 success:^{
                        
                        [hud hidden];
                        [[RDHomeStatusView defaultView] startScreenWithViewController:self withStatus:RDHomeStatus_Photo];
                        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出投屏" style:UIBarButtonItemStyleDone target:self action:@selector(stopScreenImage:)];
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                        self.isScreen = YES;
                        
                        [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:1 isThumbnail:NO rotation:0 seriesId:nil force:0 success:^{
                            
                        } failure:^{
                            
                        }];
                        
                        
                    } failure:^{
                        [hud hidden];
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                        self.isScreen = NO;
                    }];
                }];
            }
        }];
    }
}

- (void)stopScreenImage:(BOOL)fromHomeType
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SAVORXAPI ScreenDemandShouldBackToTVWithSuccess:^{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(screenCurrentImage)];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.isScreen = NO;
        [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_exit_screen" key:nil value:nil];
        if (fromHomeType == YES) {
            [SAVORXAPI postUMHandleWithContentId:@"home_quick_back" key:@"home_quick_back" value:@"success"];
        }
    } failure:^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.isScreen = YES;
        if (fromHomeType == YES) {
            [SAVORXAPI postUMHandleWithContentId:@"home_quick_back" key:@"home_quick_back" value:@"fail"];
        }
    }];
}

- (void)rotateImage
{
    [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_rotating" key:nil value:nil];
    if ([GlobalData shared].isBindRD && self.isScreen) {
        
        self.rotateView.userInteractionEnabled = NO;
        [SAVORXAPI rotateWithURL:STBURL success:^(NSURLSessionDataTask *task, NSDictionary *result) {
            if ([[result objectForKey:@"result"] integerValue] == 0){
                [self currentCellImageShouldRotate];
            }else{
                [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"info"]];
            }
            self.rotateView.userInteractionEnabled = YES;
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
            self.rotateView.userInteractionEnabled = YES;
        }];
    }else{
        [self currentCellImageShouldRotate];
    }
}

- (void)currentCellImageShouldRotate
{
    PhotoManyCollectionViewCell * cell = [self currentCell];
    if (cell.hasEdit) {
        [cell setCellEditImage:[self rotateImageTo:UIImageOrientationRight withImage:[cell getCellEditImage]]];
    }else{
        [cell setCellRealImage:[self rotateImageTo:UIImageOrientationRight withImage:[cell getCellRealImage]]];
    }
    cell.Orientation += 90;
    if (cell.Orientation >= 360) {
        cell.Orientation = 0;
    }
}

- (void)addTextOnImage
{
    [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_add_text" key:nil value:nil];
    RDInteractionLoadingView * hud = [[RDInteractionLoadingView alloc] initWithView:self.view title:@"正在投屏"];
    
    PhotoManyCollectionViewCell * cell = [self currentCell];
    
    [self getImageFromPHAssetSourceWithIndex:[self pageControlIndexWithCurrentCellIndex:[self currentIndex]] success:^(UIImage *result) {
        PhotoManyEditView * view = [[PhotoManyEditView alloc] initWithImage:result title:cell.firstText detail:cell.secondText date:cell.thirdText];
        view.delegate = self;
        [hud hidden];
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }];
}

- (void)PhotoManyEditViewDidComposeImage:(UIImage *)image title:(NSString *)title detail:(NSString *)detail date:(NSString *)date
{
    PhotoManyCollectionViewCell * cell = [self currentCell];
    [cell setCellEditImage:image];
    cell.firstText = title;
    cell.secondText = detail;
    cell.thirdText = date;
    
    if (!([title isEqualToString:@"在这里添加文字"] && [detail isEqualToString:@"在这里添加文字"] && [date isEqualToString:@"在这里添加文字"])) {
        [RDPhotoTool saveImageInSystemPhoto:image withAlert:NO];
    }
    
    if ([GlobalData shared].isBindRD) {
        if (self.isScreen) {
            NSInteger index = [self pageControlIndexWithCurrentCellIndex:[self currentIndex]];
            PHAsset * asset = [self.PHAssetSource objectAtIndex:index];
            NSString * name = asset.localIdentifier;
            
            if ([GlobalData shared].isBindRD) {
                [RDPhotoTool compressImageWithImage:image finished:^(NSData *minData, NSData *maxData) {
                    
                    [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:1 isThumbnail:YES rotation:0 seriesId:nil force:0 success:^{
                        
                        [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:1 isThumbnail:NO rotation:0 seriesId:nil force:0 success:^{
                            
                        } failure:^{
                            
                        }];
                        
                    } failure:^{
                        
                    }];
                }];
            }
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self dataSourceCount] * 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoManyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoManyCell forIndexPath:indexPath];
    
    NSInteger index = [self pageControlIndexWithCurrentCellIndex:indexPath.row];
    PHAsset * asset = [self.PHAssetSource objectAtIndex:index];
    CGFloat width = asset.pixelWidth;
    CGFloat height = asset.pixelHeight;
    CGFloat scale = width / height;
    CGFloat tempScale = kScreen_Width / kScreen_Height;
    CGSize size;
    if (scale > tempScale) {
        size = CGSizeMake(kScreen_Width, kScreen_Width / scale);
    }else{
        size = CGSizeMake(kScreen_Height * scale, kScreen_Height);
    }
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [cell setCellRealImage:result];
//        [HomeAnimationView animationView].currentImage = result;
//        [[HomeAnimationView animationView] startScreenWithViewController:self];
    }];
    cell.Orientation = 0;
    cell.firstText = @"";
    cell.secondText = @"";
    cell.thirdText = @"";
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_switch" key:nil value:nil];
    if ([GlobalData shared].isBindRD) {
        if (self.isScreen) {
            PhotoManyCollectionViewCell * cell = [self currentCell];
            NSInteger index = [self pageControlIndexWithCurrentCellIndex:[self currentIndex]];
            PHAsset * asset = [self.PHAssetSource objectAtIndex:index];
            NSString * name = asset.localIdentifier;
            
            if (cell.hasEdit) {
                if ([GlobalData shared].isBindRD) {
                    [RDPhotoTool compressImageWithImage:[cell getCellEditImage] finished:^(NSData *minData, NSData *maxData) {
                        [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:1 isThumbnail:YES rotation:0 seriesId:nil force:0 success:^{
                            [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:1 isThumbnail:NO rotation:0 seriesId:nil force:0 success:^{
                                
                            } failure:^{
                                
                            }];
                            
                        } failure:^{
                            
                        }];
                    }];
                }
                
            }else{
                
                [self getImageFromPHAssetSourceWithIndex:[self pageControlIndexWithCurrentCellIndex:[self currentIndex]] success:^(UIImage *result) {
                    
                    if ([GlobalData shared].isBindRD) {
                        [RDPhotoTool compressImageWithImage:result finished:^(NSData *minData, NSData *maxData) {
                            
                            [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:1 isThumbnail:YES rotation:0 seriesId:nil force:0 success:^{
                                [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:1 isThumbnail:NO rotation:0 seriesId:nil force:0 success:^{
                                    
                                } failure:^{
                                    
                                }];
                                
                            } failure:^{
                                
                            }];
                        }];
                    }
                }];
            }
        }
    }
}

- (PhotoManyCollectionViewCell *)currentCell
{
    PhotoManyCollectionViewCell * cell = (PhotoManyCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[self currentIndex] inSection:0]];
    return cell;
}

- (UIImage *)currentCellRealImage
{
    PhotoManyCollectionViewCell * cell = [self currentCell];
    return [cell getCellRealImage];
}

- (NSInteger)currentIndex
{
    if (self.collectionView.frame.size.width == 0 || self.collectionView.frame.size.height == 0) {
        return 0;
    }
    
    NSInteger index = 0;
    index = (self.collectionView.contentOffset.x + self.flowLayout.itemSize.width * 0.5) / self.flowLayout.itemSize.width;
    
    return MAX(0, index);
}

- (NSInteger)dataSourceCount
{
    PHFetchResult * source = (PHFetchResult *)self.PHAssetSource;
    return source.count;
}

- (NSInteger)pageControlIndexWithCurrentCellIndex:(NSInteger)index
{
    return (NSInteger)index % [self dataSourceCount];
}

- (void)getImageFromPHAssetSourceWithIndex:(NSInteger)index success:(void (^)(UIImage * result))success
{
    //导出图片的参数
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = YES; //开启线程同步
    option.resizeMode = PHImageRequestOptionsResizeModeExact; //标准的图片尺寸
    option.version = PHImageRequestOptionsVersionCurrent; //获取用户操作的图片
    option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat; //高质量
    
    PHAsset * asset = [self.PHAssetSource objectAtIndex:index];
    CGFloat width = asset.pixelWidth;
    CGFloat height = asset.pixelHeight;
    CGFloat scale = width / height;
    CGFloat tempScale = 1920 / 1080.f;
    CGSize size;
    if (scale > tempScale) {
        size = CGSizeMake(1920, 1920 / scale);
    }else{
        size = CGSizeMake(1080 * scale, 1080);
    }
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        PhotoManyCollectionViewCell * cell = [self currentCell];
        switch (cell.Orientation) {
            case 90:
                success([self rotateImageTo:UIImageOrientationRight withImage:result]);
                break;
                
            case 180:
                success([self rotateImageTo:UIImageOrientationDown withImage:result]);
                break;
                
            case 270:
                success([self rotateImageTo:UIImageOrientationLeft withImage:result]);
                break;
                
            default:
                success(result);
                break;
        }
    }];
}

- (UIImage *)rotateImageTo:(UIImageOrientation)orientation withImage:(UIImage *)image
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate =M_PI_2;
            rect =CGRectMake(0,0,image.size.height, image.size.width);
            translateX=0;
            translateY= -rect.size.width;
            scaleY =rect.size.width/rect.size.height;
            scaleX =rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate =3 *M_PI_2;
            rect =CGRectMake(0,0,image.size.height, image.size.width);
            translateX= -rect.size.height;
            translateY=0;
            scaleY =rect.size.width/rect.size.height;
            scaleX =rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate =M_PI;
            rect =CGRectMake(0,0,image.size.width, image.size.height);
            translateX= -rect.size.width;
            translateY= -rect.size.height;
            break;
        default:
            rotate =0.0;
            rect =CGRectMake(0,0,image.size.width, image.size.height);
            translateX=0;
            translateY=0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX,translateY);
    
    CGContextScaleCTM(context, scaleX,scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0,0,rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidBindDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDBoxQuitScreenNotification object:nil];
    NSLog(@"相册投屏释放了");
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_back_list" key:nil value:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
