//
//  PhotoListViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/9.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "PhotoListViewController.h"
#import "PhotoTool.h"
#import "OpenFileTool.h"
#import "PhotoSliderViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PhotoListCollectionViewCell.h"
#import "GCCUPnPManager.h"
#import "HomeAnimationView.h"
#import "PhotoManyViewController.h"

#define PhotoListCollection @"PhotoListCollection"

@interface PhotoListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView * collectionView; //展示图片列表视图
@property (nonatomic, strong) PHImageRequestOptions *option; //当前页面的图片导出参数
@property (nonatomic, assign) BOOL isChooseStatus; //当前是否在选择状态
@property (nonatomic, strong) UIView * bottomView; //底部控制栏
@property (nonatomic, assign) BOOL isAllChoose; //是否是全选
@property (nonatomic, strong) UIButton * playButton; //幻灯片按钮
@property (nonatomic, strong) NSMutableArray * selectArray; //选择的数组

@end

@implementation PhotoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
}

//初始化界面
- (void)createUI
{
    self.view.backgroundColor = VCBackgroundColor;
    self.selectArray = [NSMutableArray new];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemDidClicked)];
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CollectionViewCellSize;
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.minimumLineSpacing = 3;
    flowLayout.sectionInset = UIEdgeInsetsMake(3, 5, 50, 5);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - NavHeight) collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[PhotoListCollectionViewCell class] forCellWithReuseIdentifier:PhotoListCollection];
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
    
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:self.PHAssetSource.count - 1 inSection:0];
    if (self.PHAssetSource.count > 0) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }
}

//右上方导航栏按钮被点击
- (void)rightButtonItemDidClicked
{
    if (self.isChooseStatus) {
        [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_photo_cancel_select" key:nil value:nil];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemDidClicked)];
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_bottom).offset(0);
        }];
        self.isChooseStatus = NO;
        self.isAllChoose = NO;
        [self.selectArray removeAllObjects];
    }else{
        [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_photo_select" key:nil value:nil];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemDidClicked)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(allChoose)];
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_bottom).offset(-50);
        }];
        self.isChooseStatus = YES;
    }
    [self.collectionView reloadData];
}

//全选动作触发
- (void)allChoose
{
    [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_photo_select_all" key:nil value:nil];
    NSInteger maxNum = self.PHAssetSource.count > 50 ? 50 : self.PHAssetSource.count;
    for (NSInteger i = 0; i < maxNum; i++) {
        if (self.selectArray.count > 49) {
            break;
        }
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:self.PHAssetSource.count - 1 - i inSection:0];
        if ([self.selectArray containsObject:indexPath]) {
            if (maxNum + 1 > self.PHAssetSource.count) {
                continue;
            }
            maxNum++;
            continue;
        }
        [self.selectArray addObject:indexPath];
    }
    self.isAllChoose = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消全选" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAllChoose)];
    [self.collectionView reloadData];
}

- (void)cancelAllChoose
{
    if (self.selectArray.count > 0) {
        [self.selectArray removeAllObjects];
    }
    self.isAllChoose = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(allChoose)];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.PHAssetSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoListCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoListCollection forIndexPath:indexPath];
    
    PHAsset * asset = [self.PHAssetSource objectAtIndex:indexPath.row];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CollectionViewCellSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [cell.bgImageView setImage:result];
    }];
    
    if (self.isChooseStatus) {
        [cell setSelectedStatus:YES];
        if ([self.selectArray containsObject:indexPath]) {
            [cell changeSelectedTo:YES];
        }else{
            [cell changeSelectedTo:NO];
        }
    }else{
        [cell setSelectedStatus:NO];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isChooseStatus){
        //如果当前是在选择状态
        PhotoListCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoListCollection forIndexPath:indexPath];
        if ([self.selectArray containsObject:indexPath]) {
            [self.selectArray removeObject:indexPath];
            [cell changeSelectedTo:NO];
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            if (self.isAllChoose) {
                self.isAllChoose = NO;
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(allChoose)];
            }
        }else{
            if (self.selectArray.count > 49) {
                [MBProgressHUD showTextHUDwithTitle:@"最多只能选择50张"];
                return;
            }
            [self.selectArray addObject:indexPath];
            [cell changeSelectedTo:YES];
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }else{
        MBProgressHUD * hud;
        
        if ([GlobalData shared].isBindRD || [GlobalData shared].isBindDLNA) {
            hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在投屏"];
        }else{
            hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在加载"];
        }
        
        if ([GlobalData shared].isBindRD) {
            
            PHAsset * asset = [self.PHAssetSource objectAtIndex:indexPath.row];
            NSString * name = asset.localIdentifier;
            [[PhotoTool sharedInstance] getImageFromPHAssetSourceWithAsset:asset success:^(UIImage *result) {
                
                PhotoManyViewController * vc = [[PhotoManyViewController alloc] initWithPHAssetSource:self.PHAssetSource andIndex:indexPath.row];
                
                [[PhotoTool sharedInstance] compressImageWithImage:result finished:^(NSData *minData, NSData *maxData) {
                    
                    [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:1 isThumbnail:YES rotation:0 seriesId:nil success:^{
                        [hud hideAnimated:NO];
                        [self.navigationController pushViewController:vc animated:YES];
                        [HomeAnimationView animationView].currentImage = result;
                        [[HomeAnimationView animationView] startScreenWithViewController:vc];
                        [SAVORXAPI successRing];
                        
                        [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_play" key:nil value:nil];
                        [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:1 isThumbnail:NO rotation:0 seriesId:nil success:^{
                            
                        } failure:^{
                            
                        }];
                        
                    } failure:^{
                        [hud hideAnimated:NO];
                    }];
                    
                }];
                
            }];
            return;
        }
        
        //不是选择状态
        [self screenImageWithPHAsset:[self.PHAssetSource objectAtIndex:indexPath.row] index:indexPath.row success:^(UIImage *result, NSString *keyStr) {
            
            PhotoManyViewController * vc = [[PhotoManyViewController alloc] initWithPHAssetSource:self.PHAssetSource andIndex:indexPath.row];
            if ([GlobalData shared].isBindDLNA){
                NSString *asseturlStr = [NSString stringWithFormat:@"%@image?%@", [HTTPServerManager getCurrentHTTPServerIP],keyStr];
                [[GCCUPnPManager defaultManager] setAVTransportURL:asseturlStr Success:^{
                    [hud hideAnimated:NO];
                    [self.navigationController pushViewController:vc animated:YES];
                    [HomeAnimationView animationView].currentImage = result;
                    [[HomeAnimationView animationView] startScreenWithViewController:vc];
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
    }
}

//多选图片进行幻灯片操作
- (void)photoArrayToPlay
{
    if (self.selectArray.count == 0) {
        [MBProgressHUD showTextHUDwithTitle:@"请至少选择一张图片"];
        return;
    }
    
    PhotoSliderViewController * third = [[PhotoSliderViewController alloc] init];
    NSMutableArray * array = [NSMutableArray new];
    for (NSIndexPath * indexPath in self.selectArray) {
        [array addObject:[self.PHAssetSource objectAtIndex:indexPath.row]];
    }
    [array insertObject:[array lastObject] atIndex:0];
    [array addObject:[array objectAtIndex:1]];
    third.PHAssetSource = array;
    
    [self rightButtonItemDidClicked];
    
    if ([GlobalData shared].isBindRD) {
        MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在投屏"];
        PHAsset * asset = [third.PHAssetSource objectAtIndex:1];
        NSString * name = asset.localIdentifier;
        
        [[PhotoTool sharedInstance] getImageFromPHAssetSourceWithAsset:asset success:^(UIImage *result) {
            
            [[PhotoTool sharedInstance] compressImageWithImage:result finished:^(NSData *minData, NSData *maxData) {
                
                [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:1 isThumbnail:YES rotation:0 seriesId:nil success:^{
                    
                    // 获取第一张幻灯片图片，回传
                    [HomeAnimationView animationView].currentImage = result;
                    [hud hideAnimated:NO];
                    [[HomeAnimationView animationView] startScreenWithViewController:third];
                    [self.navigationController pushViewController:third animated:YES];
                    [SAVORXAPI successRing];
                    
                    [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:1 isThumbnail:NO rotation:0 seriesId:nil success:^{
                        
                    } failure:^{
                        
                    }];
                    
                } failure:^{
                    [hud hideAnimated:NO];
                }];
                
            }];
            
        }];
    }else if ([GlobalData shared].isBindDLNA) {
        [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在投屏"];
        [self screenImageWithPHAsset:[array objectAtIndex:1] index:1 success:^(UIImage *result, NSString *keyStr) {
            NSString *asseturlStr = [NSString stringWithFormat:@"%@image?%@", [HTTPServerManager getCurrentHTTPServerIP],keyStr];
            [[GCCUPnPManager defaultManager] setAVTransportURL:asseturlStr Success:^{
                // 获取第一张幻灯片图片，回传
                [HomeAnimationView animationView].currentImage = result;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [[HomeAnimationView animationView] startScreenWithViewController:third];
                [self.navigationController pushViewController:third animated:YES];
                [SAVORXAPI successRing];
            } failure:^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
            }];
        }];
    }else{
        [self.navigationController pushViewController:third animated:YES];
    }
}

//投屏某一张图片
- (void)screenImageWithPHAsset:(PHAsset *)asset index:(NSInteger)index success:(void (^)(UIImage * result, NSString * keyStr))success
{
    [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_click_item" key:nil value:nil];
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

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_back_album" key:nil value:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [OpenFileTool deleteFileSubPath:SystemImage];
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
