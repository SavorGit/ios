//
//  PhotoAllViewController.m
//  SavorX
//
//  Created by 郭春城 on 17/3/1.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "PhotoAllViewController.h"
#import "PhotoCollectionViewCell.h"
#import "PhotoManyViewController.h"
#import "GCCUPnPManager.h"
#import "PhotoSliderViewController.h"
#import "OpenFileTool.h"
#import "PhotoTool.h"
#import "SXVideoPlayViewController.h"

#define PhotoCell @"PhotoCell"
@interface PhotoAllViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) PHFetchResult * cameroRoll; //相机胶卷（照片和视频）的数据源
@property (nonatomic, strong) UICollectionView * collectionView; //展示图片列表视图

@property (nonatomic, assign) BOOL isChoose; //记录当前是否是选择状态
@property (nonatomic, assign) BOOL isAllChoose; //记录当前的全选状态
@property (nonatomic, strong) NSMutableArray * selectArray; //记录当前选中的图片
@property (nonatomic, strong) UIView * bottomView; //底部控制栏
@property (nonatomic, strong) UIButton * playButton; //幻灯片按钮

@property (nonatomic, strong) NSTimer * timer; //视图转化更新进度定时器
@property (nonatomic, strong) AVAssetExportSession * session; //当前导出视频的对象

@end

@implementation PhotoAllViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDatas];
    [self setupViews];
}

- (void)setupViews
{
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CollectionViewCellSize;
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.minimumLineSpacing = 3;
    flowLayout.sectionInset = UIEdgeInsetsMake(3, 5, 50, 5);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:PhotoCell];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(startChoose)];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(0);
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 50));
    }];
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame = CGRectMake(0, 0, kScreen_Width, 50);
    self.playButton.backgroundColor = [UIColor clearColor];
    [self.playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.playButton setTitle:@"幻灯片播放" forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(photoArrayToPlay) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.titleLabel.font = [UIFont boldSystemFontOfSize:FontSizeBig];
    [self.bottomView addSubview:self.playButton];
    
    if (self.cameroRoll.count > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:self.cameroRoll.count - 1 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        });
    }
}

- (void)photoArrayToPlay
{
    if (self.selectArray.count == 0) {
        [MBProgressHUD showTextHUDwithTitle:@"请至少选择一张图片"];
        return;
    }
    
    PhotoSliderViewController * third = [[PhotoSliderViewController alloc] init];
    NSMutableArray * array = [NSMutableArray new];
    for (NSIndexPath * indexPath in self.selectArray) {
        [array addObject:[self.cameroRoll objectAtIndex:indexPath.row]];
    }
    [array insertObject:[array lastObject] atIndex:0];
    [array addObject:[array objectAtIndex:1]];
    third.PHAssetSource = array;
    
    [self stopChoose];
    
    if ([GlobalData shared].isBindRD) {
        MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在投屏"];
        [self screenImageWithPHAsset:[array objectAtIndex:1] index:1 success:^(UIImage *result, NSString *keyStr) {
            NSString *asseturlStr = [NSString stringWithFormat:@"%@image?%@", [HTTPServerManager getCurrentHTTPServerIP],keyStr];
            NSDictionary *parameters = @{@"function": @"prepare",
                                         @"action": @"2screen",
                                         @"assettype": @"pic",
                                         @"asseturl": asseturlStr,
                                         @"assetname": keyStr,
                                         @"play": @"0"};
            [SAVORXAPI postWithURL:STBURL parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *result) {
                [hud hideAnimated:NO];
                if ([[result objectForKey:@"result"] integerValue] == 0) {
//                    [[HomeAnimationView animationView] startScreenWithViewController:third];
                    [self.navigationController pushViewController:third animated:YES];
                    [SAVORXAPI successRing];
                }else{
                    [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [hud hideAnimated:NO];
                [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
            }];
        }];
    }else if ([GlobalData shared].isBindDLNA) {
        [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在投屏"];
        [self screenImageWithPHAsset:[array objectAtIndex:1] index:1 success:^(UIImage *result, NSString *keyStr) {
            NSString *asseturlStr = [NSString stringWithFormat:@"%@image?%@", [HTTPServerManager getCurrentHTTPServerIP],keyStr];
            [[GCCUPnPManager defaultManager] setAVTransportURL:asseturlStr Success:^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
//                [[HomeAnimationView animationView] startScreenWithViewController:third];
                [self.navigationController pushViewController:third animated:YES];
                [SAVORXAPI successRing];
            } failure:^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
            }];
        }];
    }else{
//        [[HomeAnimationView animationView] scanQRCode];
    }
}

//开始选择
- (void)startChoose
{
    self.isChoose = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(stopChoose)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(allChoose)];
    
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(-50);
    }];
    
    [self.collectionView reloadData];
}

//全选
- (void)allChoose
{
    NSInteger maxNum = self.cameroRoll.count > 50 ? 50 : self.cameroRoll.count;
    
    NSInteger i = 0;
    while (i < maxNum) {
        if (self.selectArray.count > 49) {
            break;
        }
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:self.cameroRoll.count - 1 - i inSection:0];
        
        i++;
        
        PHAsset * asset = [self.cameroRoll objectAtIndex:indexPath.row];
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            if (maxNum + 1 > self.cameroRoll.count) {
                continue;
            }
            maxNum++;
            continue;
        }
        
        if (![self.selectArray containsObject:indexPath]) {
            [self.selectArray addObject:indexPath];
        }
    }
    
    self.isAllChoose = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消全选" style:UIBarButtonItemStyleDone target:self action:@selector(cancleAllChoose)];
    [self.collectionView reloadData];
}

//取消全选
- (void)cancleAllChoose
{
    [self.selectArray removeAllObjects];
    self.isAllChoose = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(allChoose)];
    [self.collectionView reloadData];
}

//停止选择
- (void)stopChoose
{
    self.isChoose = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(startChoose)];
    [self.selectArray removeAllObjects];
    
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(0);
    }];
    
    [self setNavBackArrow];
    
    [self.collectionView reloadData];
}

- (void)setupDatas
{
    self.selectArray = [NSMutableArray new];
    
    PHAssetCollection * collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    self.cameroRoll = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.cameroRoll.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCell forIndexPath:indexPath];
    
    PHAsset * asset = [self.cameroRoll objectAtIndex:indexPath.row];
    [cell reloadViewWithAsset:asset andIsChoose:self.isChoose];
    
    if ([self.selectArray containsObject:indexPath]) {
        [cell photoDidBeSelected:YES];
    }else{
        [cell photoDidBeSelected:NO];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell * cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.isChoose) {
        
        if (cell.mediaType == PHAssetMediaTypeImage) { //是照片类型
            
            if (self.selectArray.count > 49 && !cell.isChoosed) {
                [MBProgressHUD showTextHUDwithTitle:@"最多只能选择50张"];
                return;
            }
            
            [cell photoDidBeSelected:!cell.isChoosed];
            if (cell.isChoosed) {
                [self.selectArray addObject:indexPath];
            }else{
                [self.selectArray removeObject:indexPath];
                if (self.isAllChoose) {
                    self.isAllChoose = NO;
                    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(allChoose)];
                }
            }
            
        }else if (cell.mediaType == PHAssetMediaTypeVideo) { //是视频类型
            
        }
        
    }else{
        
        if (cell.mediaType == PHAssetMediaTypeImage) { //是照片类型
            
            MBProgressHUD * hud;
            
            if ([GlobalData shared].isBindRD || [GlobalData shared].isBindDLNA) {
                hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在投屏"];
            }else{
                hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在加载"];
            }
            
            //不是选择状态
            [self screenImageWithPHAsset:[self.cameroRoll objectAtIndex:indexPath.row] index:indexPath.row success:^(UIImage *result, NSString *keyStr) {
                
                PhotoManyViewController * vc = [[PhotoManyViewController alloc] initWithPHAssetSource:self.cameroRoll andIndex:indexPath.row];
                
                if ([GlobalData shared].isBindRD) {
                    
                    NSString *asseturlStr = [NSString stringWithFormat:@"%@image?%@", [HTTPServerManager getCurrentHTTPServerIP],keyStr];
                    NSDictionary *parameters = @{@"function": @"prepare",
                                                 @"action": @"2screen",
                                                 @"assettype": @"pic",
                                                 @"asseturl": asseturlStr,
                                                 @"assetname": keyStr,
                                                 @"play": @"0"};
                    [SAVORXAPI postWithURL:STBURL parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *result) {
                        [hud hideAnimated:NO];
                        if ([[result objectForKey:@"result"] integerValue] == 0) {
                            [self.navigationController pushViewController:vc animated:YES];
//                            [[HomeAnimationView animationView] startScreenWithViewController:vc];
                            [SAVORXAPI successRing];
                        }else{
                            [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
                        }
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        [hud hideAnimated:NO];
                        [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
                    }];
                }else if ([GlobalData shared].isBindDLNA){
                    NSString *asseturlStr = [NSString stringWithFormat:@"%@image?%@", [HTTPServerManager getCurrentHTTPServerIP],keyStr];
                    [[GCCUPnPManager defaultManager] setAVTransportURL:asseturlStr Success:^{
                        [hud hideAnimated:NO];
                        [self.navigationController pushViewController:vc animated:YES];
//                        [[HomeAnimationView animationView] startScreenWithViewController:vc];
                        [SAVORXAPI successRing];
                    } failure:^{
                        [hud hideAnimated:NO];
                        [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
                    }];
                }else{
                    [hud hideAnimated:NO];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
        }else if (cell.mediaType == PHAssetMediaTypeVideo) { //是视频类型
            [self playVideoWithAsset:[self.cameroRoll objectAtIndex:indexPath.row]];
        }
        
    }
}

//投屏某一张图片
- (void)screenImageWithPHAsset:(PHAsset *)asset index:(NSInteger)index success:(void (^)(UIImage * result, NSString * keyStr))success
{
    //导出图片的参数
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = YES; //开启线程同步
    option.resizeMode = PHImageRequestOptionsResizeModeExact; //标准的图片尺寸
    option.version = PHImageRequestOptionsVersionCurrent; //获取用户操作的图片
    option.networkAccessAllowed = YES; //允许访问iCloud
    option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat; //高质量
    
    //机顶盒输出尺寸为1920*1080，为了更好的用户效果，这里对图片进行相应的转换
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
    NSString * keyStr = asset.localIdentifier;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [OpenFileTool writeImageToSysImageCacheWithImage:result andName:keyStr handle:^(NSString *keyStr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(result, keyStr);
            });
        }];
    }];
}

//通过PHAsset对象播放video
- (void)playVideoWithAsset:(PHAsset *)asset
{
    [MBProgressHUD showProgressLoadingHUDInView:self.view];
    
    __weak typeof(self) weakSelf = self;
    //将对应的PHAsset导出为MP4文件
    [[PhotoTool sharedInstance] exportVideoToMP4WithAsset:asset startHandler:^(AVAssetExportSession *session) {
        weakSelf.session = session;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.timer = [NSTimer timerWithTimeInterval:0.1f target:weakSelf selector:@selector(changeProgress) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:weakSelf.timer forMode:NSRunLoopCommonModes];
        });
        
    } endHandler:^(NSString *url, AVAssetExportSession *session) {
        if (session.status == AVAssetExportSessionStatusCompleted) {
            
            //导出成功进行投屏MP4操作
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showCustomLoadingHUDInView:self.view];
                
                NSString *asseturlStr = [NSString stringWithFormat:@"%@video?media-Redianer-TempCache.mp4", [HTTPServerManager getCurrentHTTPServerIP]];
                if ([GlobalData shared].isBindRD) {
                    NSDictionary *parameters = @{@"function": @"prepare",
                                                 @"action": @"2screen",
                                                 @"assettype": @"video",
                                                 @"asseturl": asseturlStr,
                                                 @"assetname": @"media-Redianer-TempCache.mp4",
                                                 @"play": @"0"};
                    
                    [SAVORXAPI postWithURL:STBURL parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *result) {
                        if ([[result objectForKey:@"result"] integerValue] == 0) {
                            SXVideoPlayViewController * play = [[SXVideoPlayViewController alloc] init];
                            play.videoUrl = @"video?media-Redianer-TempCache.mp4";
                            play.totalTime = asset.duration;
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            [SAVORXAPI successRing];
//                            [[HomeAnimationView animationView] startScreenWithViewController:play];
                            [self.navigationController pushViewController:play animated:YES];
                        }else{
                            [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
                        }
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
                    }];
                }else if ([GlobalData shared].isBindDLNA) {
                    [[GCCUPnPManager defaultManager] setAVTransportURL:asseturlStr Success:^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        SXVideoPlayViewController * play = [[SXVideoPlayViewController alloc] init];
                        play.videoUrl = @"video?media-Redianer-TempCache.mp4";
                        play.totalTime = asset.duration;
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [SAVORXAPI successRing];
//                        [[HomeAnimationView animationView] startScreenWithViewController:play];
                        [self.navigationController pushViewController:play animated:YES];
                    } failure:^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
                    }];
                }else{
                    SXVideoPlayViewController * play = [[SXVideoPlayViewController alloc] init];
                    play.videoUrl = @"video?media-Redianer-TempCache.mp4";
                    play.totalTime = asset.duration;
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.navigationController pushViewController:play animated:YES];
                }
                
            });
        }else if (session.status == AVAssetExportSessionStatusCancelled){
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }else{
            //导出失败进行投屏asset操作
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showTextHUDwithTitle:@"视频导出失败"];
            });
        }
    }];
}

//改变进度
- (void)changeProgress
{
    if (self.session) {
        if (self.session.status == AVAssetExportSessionStatusExporting) {
            [MBProgressHUD HUDForView:self.view].progress = self.session.progress;
            [MBProgressHUD HUDForView:self.view].detailsLabel.text = [NSString stringWithFormat:@"%.1lf%%", self.session.progress * 100];
        }else{
            [self.timer setFireDate:[NSDate distantFuture]];
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer invalidate];
        self.timer = nil;
    }
    [self.session cancelExport];
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
