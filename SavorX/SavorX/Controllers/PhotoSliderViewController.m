//
//  PhotoSliderViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/9/5.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "PhotoSliderViewController.h"
#import "ShowPhotoCollectionViewCell.h"
#import "OpenFileTool.h"
#import "PhotoTool.h"
#import "GCCUPnPManager.h"
#import "HomeAnimationView.h"

#define SliderCell @"SliderCell"

@interface PhotoSliderViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView * collectionView; //当前展示图片视图
@property (nonatomic, strong) PHImageRequestOptions * option; //图片导出参数
@property (nonatomic, strong) NSURLSessionDataTask * task; //当前网络任务
@property (nonatomic, strong) UIView * bottomView; //下方旋转按钮
@property (nonatomic, assign) NSInteger currentIndex; //记录当前下标
@property (nonatomic, strong) NSTimer * timer; //幻灯片播放的定时器
@property (nonatomic, assign) BOOL isScreen; //是否是在线状态

@property (nonatomic, strong) UILabel * indexLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIButton * playButton;
@property (nonatomic, strong) UILabel * statusLabel;
@property (nonatomic, strong) UIButton * firstTimeButton;
@property (nonatomic, strong) UIButton * secondTimeButton;
@property (nonatomic, strong) UIButton * thirdTimeButton;
@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic, assign) BOOL isBoxQiut;

@end

@implementation PhotoSliderViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.timeLong = 5;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的照片";
    
    self.view.backgroundColor = VCBackgroundColor;
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(kScreen_Width, kScreen_Height - 64);
    flowLayout.minimumLineSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - NavHeight) collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[ShowPhotoCollectionViewCell class] forCellWithReuseIdentifier:SliderCell];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    self.currentIndex = 1;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    //导出图片的参数
    self.option = [PHImageRequestOptions new];
    //self.option.synchronous = YES; //开启线程同步
    self.option.resizeMode = PHImageRequestOptionsResizeModeExact; //标准的图片尺寸
    //self.option.version = PHImageRequestOptionsVersionCurrent; //获取用户操作的图片
    self.option.networkAccessAllowed = YES; //允许访问iCloud
    self.option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat; //高质量
    
    [self setupBottomView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenCurrentImage) name:RDDidBindDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidQiutWithBox) name:RDBoxQuitScreenNotification object:nil];
}

- (void)rightItemDidClickedToScreenImage
{
    self.isBoxQiut = NO;
    [self screenCurrentImage];
}

- (void)screenDidQiutWithBox
{
    self.playButton.selected = NO;
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.timer invalidate];
    self.timer = nil;
    self.isScreen = NO;
    self.isBoxQiut = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemDidClickedToScreenImage)];
    self.seriesId = [Helper getTimeStamp];
    self.statusLabel.text = @"幻灯片";
}

- (void)setupBottomView
{
    self.bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(100);
    }];
    
    UIView * downView = [[UIView alloc] initWithFrame:CGRectZero];
    downView.backgroundColor = [UIColorFromRGB(0x202020) colorWithAlphaComponent:.94f];
    [self.bottomView addSubview:downView];
    [downView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.text = @"正在播放图片";
    [downView addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    self.indexLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.indexLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
    self.indexLabel.textColor = [UIColor whiteColor];
    self.indexLabel.text = [NSString stringWithFormat:@"1/%ld", self.PHAssetSource.count - 2];
    [downView addSubview:self.indexLabel];
    [self.indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.equalTo(self.statusLabel.mas_right).offset(10);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage imageNamed:@"slider_bofang"] forState:UIControlStateSelected];
    [self.playButton setImage:[UIImage imageNamed:@"slider_zanting"] forState:UIControlStateNormal];
    self.playButton.selected = YES;
    [self.playButton addTarget:self action:@selector(playButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    }];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMainBoundsWidth - 80 - 50, 60, 50, 30)];
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.text = [NSString stringWithFormat:@"%lds", self.timeLong];
    self.timeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.timeLabel.layer.borderWidth = 1.f;
    self.timeLabel.layer.cornerRadius = 15;
    self.timeLabel.layer.masksToBounds = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeLabelBeClicked)];
    tap.numberOfTapsRequired = 1;
    self.timeLabel.userInteractionEnabled = YES;
    [self.timeLabel addGestureRecognizer:tap];
    
    self.firstTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.secondTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.thirdTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSArray * array = @[self.thirdTimeButton, self.secondTimeButton, self.firstTimeButton];
    for (UIButton * button in array) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColorFromRGB(0x202020) colorWithAlphaComponent:.7f]];
        button.frame = CGRectMake(self.timeLabel.frame.origin.x - 30, 15, 32, 32);
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 1.f;
        button.layer.cornerRadius = 16.f;
        button.layer.masksToBounds = YES;
        [button addTarget:self action:@selector(timeButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.hidden = YES;
        [self.bottomView addSubview:button];
    }
    
    [self.firstTimeButton setTitle:@"3s" forState:UIControlStateNormal];
    self.firstTimeButton.tag = 3;
    [self.secondTimeButton setTitle:@"10s" forState:UIControlStateNormal];
    self.secondTimeButton.tag = 10;
    [self.thirdTimeButton setTitle:@"20s" forState:UIControlStateNormal];
    self.thirdTimeButton.tag = 20;
    
    [self.bottomView addSubview:self.timeLabel];
    
    if ([GlobalData shared].isBindRD || [GlobalData shared].isBindDLNA) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出投屏"  style:UIBarButtonItemStyleDone target:self action:@selector(stopScreenImage:)];
        self.isScreen = YES;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeLong target:self selector:@selector(scrollPhotos) userInfo:nil repeats:YES];
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemDidClickedToScreenImage)];
        [SAVORXAPI showConnetToTVAlert:@"sliderPhoto"];
        self.isScreen = NO;
        self.playButton.selected = NO;
        self.statusLabel.text = @"幻灯片";
    }
}

- (void)timeLabelBeClicked
{
    if (self.isAnimation) {
        return;
    }
    
    self.isAnimation = YES;
    if (self.firstTimeButton.isHidden) {
        self.firstTimeButton.hidden = NO;
        self.secondTimeButton.hidden = NO;
        self.thirdTimeButton.hidden = NO;
        [UIView animateWithDuration:.15f animations:^{
            self.secondTimeButton.frame = CGRectMake(self.timeLabel.origin.x + 10, 0, 32, 32);
        } completion:^(BOOL finished) {
            
        }];
        [UIView animateWithDuration:.07f animations:^{
            self.thirdTimeButton.frame = CGRectMake(self.timeLabel.origin.x + 10, 0, 32, 32);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.08f animations:^{
                self.thirdTimeButton.frame = CGRectMake(self.timeLabel.origin.x + self.timeLabel.frame.size.width, 15, 30, 30);
            } completion:^(BOOL finished) {
                self.isAnimation = NO;
            }];
        }];
    }else{
        [UIView animateWithDuration:.08f animations:^{
            self.thirdTimeButton.frame = CGRectMake(self.timeLabel.origin.x + 10, 0, 32, 32);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.07f animations:^{
                self.thirdTimeButton.frame = CGRectMake(self.timeLabel.frame.origin.x - 30, 15, 32, 32);
                self.secondTimeButton.frame = CGRectMake(self.timeLabel.frame.origin.x - 30, 15, 32, 32);
            } completion:^(BOOL finished) {
                self.firstTimeButton.hidden = YES;
                self.secondTimeButton.hidden = YES;
                self.thirdTimeButton.hidden = YES;
                self.isAnimation = NO;
            }];
        }];
    }
}

- (void)timeButtonDidClicked:(UIButton *)button
{
    self.timeLong = button.tag;
    switch (button.tag) {
        case 3:
            [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_switch_time" key:@"slide_to_screen_switch_time" value:@"3"];
            [self.firstTimeButton setTitle:@"5s" forState:UIControlStateNormal];
            self.firstTimeButton.tag = 5;
            [self.secondTimeButton setTitle:@"10s" forState:UIControlStateNormal];
            self.secondTimeButton.tag = 10;
            [self.thirdTimeButton setTitle:@"20s" forState:UIControlStateNormal];
            self.thirdTimeButton.tag = 20;
            break;
            
        case 5:
            [self.firstTimeButton setTitle:@"3s" forState:UIControlStateNormal];
            self.firstTimeButton.tag = 3;
            [self.secondTimeButton setTitle:@"10s" forState:UIControlStateNormal];
            self.secondTimeButton.tag = 10;
            [self.thirdTimeButton setTitle:@"20s" forState:UIControlStateNormal];
            self.thirdTimeButton.tag = 20;
            break;
            
        case 10:
            [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_switch_time" key:@"slide_to_screen_switch_time" value:@"10"];
            [self.firstTimeButton setTitle:@"3s" forState:UIControlStateNormal];
            self.firstTimeButton.tag = 3;
            [self.secondTimeButton setTitle:@"5s" forState:UIControlStateNormal];
            self.secondTimeButton.tag = 5;
            [self.thirdTimeButton setTitle:@"20s" forState:UIControlStateNormal];
            self.thirdTimeButton.tag = 20;
            break;
            
        case 20:
            [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_switch_time" key:@"slide_to_screen_switch_time" value:@"20"];
            [self.firstTimeButton setTitle:@"3s" forState:UIControlStateNormal];
            self.firstTimeButton.tag = 3;
            [self.secondTimeButton setTitle:@"5s" forState:UIControlStateNormal];
            self.secondTimeButton.tag = 5;
            [self.thirdTimeButton setTitle:@"10s" forState:UIControlStateNormal];
            self.thirdTimeButton.tag = 10;
            break;
            
        default:
            break;
    }
    
    self.timeLabel.text = [NSString stringWithFormat:@"%lds", self.timeLong];
    [self timeLabelBeClicked];
    if (self.playButton.isSelected == NO) {
        return;
    }
    
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:self.timeLong target:self selector:@selector(scrollPhotos) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)playButtonDidClicked:(UIButton *)button
{
    button.selected = !button.isSelected;
    if (button.isSelected) {
        [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_play" key:nil value:nil];
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer invalidate];
        //播放
        self.timer = [NSTimer timerWithTimeInterval:self.timeLong target:self selector:@selector(scrollPhotos) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        self.statusLabel.text = @"正在播放图片";
    }else{
        //暂停
        [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_pause" key:nil value:nil];
        [self.timer invalidate];
        self.statusLabel.text = @"已暂停";
    }
}

- (void)stopScreenImage:(BOOL)fromHomeType
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.playButton.selected = NO;
    [self.timer invalidate];
    self.timer = nil;
    self.isScreen = NO;
    if (self.task) {
        [self.task cancel];
    }
    [SAVORXAPI ScreenDemandShouldBackToTVWithSuccess:^{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemDidClickedToScreenImage)];
        self.seriesId = [Helper getTimeStamp];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.statusLabel.text = @"幻灯片";
        [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_exit" key:nil value:nil];
        if (fromHomeType == YES) {
            [SAVORXAPI postUMHandleWithContentId:@"home_quick_back" key:@"home_quick_back" value:@"success"];
        }
    } failure:^{
        self.isScreen = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (fromHomeType == YES) {
            [SAVORXAPI postUMHandleWithContentId:@"home_quick_back" key:@"home_quick_back" value:@"fail"];
        }
    }];
}

- (void)screenCurrentImage
{
    if (![GlobalData shared].isBindRD && ![GlobalData shared].isBindDLNA) {
        [[HomeAnimationView animationView] scanQRCode];
        return;
    }
    
    if (self.isBoxQiut) {
        return;
    }
    
    self.playButton.selected = YES;
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:self.timeLong target:self selector:@selector(scrollPhotos) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [[HomeAnimationView animationView] startScreenWithViewController:self];
    self.isScreen = YES;
    self.statusLabel.text = @"正在播放图片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出投屏"  style:UIBarButtonItemStyleDone target:self action:@selector(stopScreenImage:)];
    
    if ([GlobalData shared].isBindRD || [GlobalData shared].isBindDLNA) {
        PHAsset * asset = [self.PHAssetSource objectAtIndex:self.currentIndex];
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
        NSString * name = asset.localIdentifier;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            if ([GlobalData shared].isBindRD) {
                [[PhotoTool sharedInstance] compressImageWithImage:result finished:^(NSData *minData, NSData *maxData) {
                    [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:3 isThumbnail:YES rotation:0 seriesId:self.seriesId force:0 success:^{
                        
                        [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:3 isThumbnail:NO rotation:0 seriesId:self.seriesId force:0 success:^{
                            
                        } failure:^{
                            
                        }];
                        
                    } failure:^{
                        self.playButton.selected = NO;
                        [self.timer invalidate];
                        self.timer = nil;
                        self.isScreen = NO;
                        if (self.task) {
                            [self.task cancel];
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
                        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemDidClickedToScreenImage)];
                        self.statusLabel.text = @"幻灯片";
                    }];
                }];
            }else if ([GlobalData shared].isBindDLNA) {
                [OpenFileTool writeImageToSysImageCacheWithImage:result andName:name handle:^(NSString *keyStr) {
                    [self screenDLNAImageWithKeyStr:keyStr];
                }];
            }
        }];
    }
}

//图片滑动切换
- (void)scrollPhotos
{
    [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_switch_item" key:nil value:nil];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    self.currentIndex += 1;
    if (self.currentIndex == self.PHAssetSource.count - 1) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
        self.currentIndex = 1;
        [self stopScreenImage:nil];
        [MBProgressHUD showTextHUDwithTitle:@"幻灯片播放已经结束"];
        self.playButton.selected = NO;
    }else if (self.currentIndex == 0){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.PHAssetSource.count - 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        self.currentIndex = self.PHAssetSource.count - 2;
    }
    
    self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.currentIndex, self.PHAssetSource.count - 2];
    if (self.isScreen) {
        if ([GlobalData shared].isBindRD || [GlobalData shared].isBindDLNA) {
            PHAsset * asset = [self.PHAssetSource objectAtIndex:self.currentIndex];
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
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                NSString * name = asset.localIdentifier;
                if ([GlobalData shared].isBindRD) {
                    [[PhotoTool sharedInstance] compressImageWithImage:result finished:^(NSData *minData, NSData *maxData) {
                        [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:3 isThumbnail:YES rotation:0 seriesId:self.seriesId force:0 success:^{
                            
                            [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:3 isThumbnail:NO rotation:0 seriesId:self.seriesId force:0 success:^{
                                
                            } failure:^{
                                
                            }];
                            
                        } failure:^{
                            self.playButton.selected = NO;
                            [self.timer invalidate];
                            self.timer = nil;
                            self.isScreen = NO;
                            if (self.task) {
                                [self.task cancel];
                            }
                            [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
                            [MBProgressHUD showTextHUDwithTitle:@"幻灯片投屏失败" delay:1.5f];
                            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemDidClickedToScreenImage)];
                            self.statusLabel.text = @"幻灯片";
                        }];
                    }];
                }else if ([GlobalData shared].isBindDLNA) {
                    [OpenFileTool writeImageToSysImageCacheWithImage:result andName:name handle:^(NSString *keyStr) {
                        [self screenDLNAImageWithKeyStr:keyStr];
                    }];
                }
            }];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.PHAssetSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShowPhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SliderCell forIndexPath:indexPath];
    PHAsset * asset = [self.PHAssetSource objectAtIndex:indexPath.row];
    CGFloat width = asset.pixelWidth;
    CGFloat height = asset.pixelHeight;
    CGFloat scale = width / height;
    CGFloat tempScale = kScreen_Width / kScreen_Height - NavHeight;
    CGSize size;
    if (scale > tempScale) {
        size = CGSizeMake(kScreen_Width, kScreen_Width / scale);
    }else{
        size = CGSizeMake((kScreen_Height - NavHeight) * scale, kScreen_Height - NavHeight);
    }
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [cell.photoImage setImage:result];
    }];
    cell.photoImage.transform = CGAffineTransformMakeRotation(0);
    cell.isLandSpace = NO;
    
    return cell;
}

//视图开始交互
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timer invalidate];
    NSInteger itemIndex = (scrollView.contentOffset.x + kScreen_Width * 0.5) / kScreen_Width;
    
    if (itemIndex == self.PHAssetSource.count - 1) {
        itemIndex = 1;
    }else if (itemIndex == 0){
        itemIndex = self.PHAssetSource.count - 2;
    }
    
    self.currentIndex = itemIndex;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.currentIndex, self.PHAssetSource.count - 2];
}

//视图结束滑动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger itemIndex = (scrollView.contentOffset.x + kScreen_Width * 0.5) / kScreen_Width;
    if (itemIndex == self.PHAssetSource.count - 1) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        itemIndex = 1;
    }else if (itemIndex == 0){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.PHAssetSource.count - 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        itemIndex = self.PHAssetSource.count - 2;
    }
    self.currentIndex = itemIndex;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.currentIndex, self.PHAssetSource.count - 2];
    
    if (self.PHAssetSource > 0 && self.playButton.isSelected) {
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer invalidate];
        self.timer = [NSTimer timerWithTimeInterval:self.timeLong target:self selector:@selector(scrollPhotos) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        self.statusLabel.text = @"正在播放图片";
        self.playButton.selected = YES;
    }
    if (self.isScreen) {
        if ([GlobalData shared].isBindRD || [GlobalData shared].isBindDLNA) {
            PHAsset * asset = [self.PHAssetSource objectAtIndex:itemIndex];
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
            NSString * name = asset.localIdentifier;
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                if ([GlobalData shared].isBindRD) {
                    [[PhotoTool sharedInstance] compressImageWithImage:result finished:^(NSData *minData, NSData *maxData) {
                        [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:3 isThumbnail:YES rotation:0 seriesId:self.seriesId force:0 success:^{
                            
                            [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:3 isThumbnail:NO rotation:0 seriesId:self.seriesId force:0 success:^{
                                
                            } failure:^{
                                
                            }];
                            
                        } failure:^{
                            self.playButton.selected = NO;
                            [self.timer invalidate];
                            self.timer = nil;
                            self.isScreen = NO;
                            if (self.task) {
                                [self.task cancel];
                            }
                            [[NSNotificationCenter defaultCenter] postNotificationName:RDQiutScreenNotification object:nil];
                            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投屏" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemDidClickedToScreenImage)];
                            self.statusLabel.text = @"幻灯片";
                        }];
                    }];
                }else if ([GlobalData shared].isBindDLNA) {
                    [OpenFileTool writeImageToSysImageCacheWithImage:result andName:name handle:^(NSString *keyStr) {
                        [self screenDLNAImageWithKeyStr:keyStr];
                    }];
                }
            }];
        }
    }
}

//投屏DLNA图片
- (void)screenDLNAImageWithKeyStr:(NSString *)keyStr
{
    NSString *asseturlStr = [NSString stringWithFormat:@"%@image?%@", [HTTPServerManager getCurrentHTTPServerIP],keyStr];
    [[GCCUPnPManager defaultManager] setAVTransportURL:asseturlStr Success:^{
        
    } failure:^{
        
    }];
}

- (void)shouldRelease
{
    if (self.task) {
        [self.task cancel];
    }
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (!self.isScreen) {
        [self shouldRelease];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidBindDeviceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDBoxQuitScreenNotification object:nil];
    [self.timer invalidate];
    self.timer = nil;
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
