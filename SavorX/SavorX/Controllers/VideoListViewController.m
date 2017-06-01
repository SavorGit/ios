//
//  VideoListViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/11.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "VideoListViewController.h"
#import "VideoCollectionViewCell.h"
#import "SXVideoPlayViewController.h"
#import "PhotoTool.h"
#import "GCCUPnPManager.h"
#import "HomeAnimationView.h"
#import "RDAlertView.h"
#import "RDAlertAction.h"

#define VideoCELL @"VideoCELL"

@interface VideoListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, PhotoToolDelegate>

@property (nonatomic, strong) UICollectionView * collectionView; //视频列表视图
@property (nonatomic, strong) NSTimer * timer; //视图转化更新进度定时器
@property (nonatomic, strong) AVAssetExportSession * session; //当前导出视频的对象

@end

@implementation VideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = VCBackgroundColor;
    [self createCollectionView];
    [MBProgressHUD showCustomLoadingHUDInView:self.view];
    [PhotoTool sharedInstance].delegate = self;
    [[PhotoTool sharedInstance] startLoadVideoAssetCollection];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_list" key:nil value:nil];
}

//创建列表视图
- (void)createCollectionView
{
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CollectionViewCellSize;
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.minimumLineSpacing = 3;
    flowLayout.sectionInset = UIEdgeInsetsMake(3, 5, 3, 5);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - NavHeight) collectionViewLayout:flowLayout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"VideoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:VideoCELL];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.results.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:VideoCELL forIndexPath:indexPath];
    [cell getInfoFromAsset:[self.results objectAtIndex:indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 获得点击图片，回传给缩略图
    VideoCollectionViewCell * tmpcell = (VideoCollectionViewCell *)[self.collectionView  cellForItemAtIndexPath:indexPath];
    [HomeAnimationView animationView].currentImage = tmpcell.bgImage.image;
    
    [self playVideoWithAsset:[self.results objectAtIndex:indexPath.row]];
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
                    
                    [self demandVideoWithMediaPath:asseturlStr asset:asset force:0];
                    
                }else if ([GlobalData shared].isBindDLNA) {
                    [[GCCUPnPManager defaultManager] setAVTransportURL:asseturlStr Success:^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        SXVideoPlayViewController * play = [[SXVideoPlayViewController alloc] init];
                        play.videoUrl = @"video?media-Redianer-TempCache.mp4";
                        play.totalTime = asset.duration;
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [SAVORXAPI successRing];
                        [[HomeAnimationView animationView] startScreenWithViewController:play];
                        [self.navigationController pushViewController:play animated:YES];
                        [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_play" key:nil value:nil];
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

- (void)demandVideoWithMediaPath:(NSString *)mediaPath  asset:(PHAsset *)asset force:(NSInteger)force{
    
    [SAVORXAPI postVideoWithURL:STBURL mediaPath:mediaPath position:@"0" force:force success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        if ([[result objectForKey:@"result"] integerValue] == 0) {
            SXVideoPlayViewController * play = [[SXVideoPlayViewController alloc] init];
            play.videoUrl = @"video?media-Redianer-TempCache.mp4";
            play.totalTime = asset.duration;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [SAVORXAPI successRing];
            [[HomeAnimationView animationView] startScreenWithViewController:play];
            [self.navigationController pushViewController:play animated:YES];
            [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_play" key:nil value:nil];
        }else if ([[result objectForKey:@"result"] integerValue] == 4) {
            
            NSString *infoStr = [result objectForKey:@"info"];
            RDAlertView *alertView = [[RDAlertView alloc] initWithTitle:@"抢投提示" message:[NSString stringWithFormat:@"当前%@正在投屏，是否继续投",infoStr]];
            RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"cancel",@"type" : @"video"}];
            } bold:NO];
            RDAlertAction * actionOne = [[RDAlertAction alloc] initWithTitle:@"继续投屏" handler:^{
                [self demandVideoWithMediaPath:mediaPath asset:asset force:1];
                [SAVORXAPI postUMHandleWithContentId:@"to_screen_competition_hint" withParmDic:@{@"to_screen_competition_hint" : @"ensure",@"type" : @"video"}];
            } bold:NO];
            [alertView addActions:@[action,actionOne]];
            [alertView show];
            
        }
        else{
            [SAVORXAPI showAlertWithMessage:[result objectForKey:@"info"]];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
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

#pragma mark -- PhotoToolDelegate
- (void)PhotoToolDidGetAssetVideo:(NSArray *)results
{
    PHAssetCollection * collection = [results firstObject];
    PHFetchResult * result = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    self.results = result;
    if (result.count == 0) {
        [MBProgressHUD showTextHUDwithTitle:@"没有更多视频"];
    }
    [self.collectionView reloadData];
    if (self.results.count > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.results.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.session cancelExport];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"video_to_screen_back" key:nil value:nil];
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
