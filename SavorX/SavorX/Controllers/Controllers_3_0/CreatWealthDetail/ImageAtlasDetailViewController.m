//
//  ImageAtlasDetailViewController.m
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/5.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import "ImageAtlasDetailViewController.h"
#import "Masonry.h"
#import "DDPhotoScrollView.h"
#import "DDPhotoDescView.h"
#import "UIView+Additional.h"
#import "ImageAtlasScrollView.h"
#import "HotPopShareView.h"
#import "HSPicDetailRequest.h"
#import "ImageAtlasDetailModel.h"
#import "HSIsOrCollectionRequest.h"
#import "HSGetCollectoinStateRequest.h"
#import "RDLogStatisticsAPI.h"

@interface ImageAtlasDetailViewController ()<UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) UIImageView *topView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) ImageAtlasScrollView *imageScrollView;
@property (nonatomic, strong) DDPhotoDescView *photoDescView;
@property (nonatomic, strong) DDPhotoScrollView *photoScrollView;
@property (nonatomic, strong) UIButton *collectBtn;
@property (nonatomic, assign) BOOL isComplete; //内容是否阅读完整

@property (nonatomic, assign) BOOL isDisappear;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong)NSMutableArray *imageDatas;
@property (nonatomic, strong)NSArray *imageArr;
@property (nonatomic, strong)NSMutableArray *scrollObjecArr;
@property (assign, nonatomic) NSUInteger currentImageIndex;

@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isPortrait;

@end

@implementation ImageAtlasDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = VCBackgroundColor;
    
    self.isPortrait = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _isComplete = NO;
    self.scrollObjecArr = [[NSMutableArray alloc] initWithCapacity:100];
    self.imageDatas = [[NSMutableArray alloc] initWithCapacity:100];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    [self.view addSubview:self.topView];
    //2650
    [self requestWithContentId:self.imgAtlModel.artid];
}

- (void)requestWithContentId:(NSString *)contentId{

    self.isReady = NO;
    [self showLoadingView];
    HSPicDetailRequest * request = [[HSPicDetailRequest alloc] initWithContentId:contentId];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self hiddenLoadingView];
        
        if ([response objectForKey:@"result"]) {
            NSArray *resultArr = [response objectForKey:@"result"];
            if (resultArr && resultArr.count > 0) {
                for (int i = 0; i < resultArr.count; i ++) {
                    ImageAtlasDetailModel *imageAtlModel = [[ImageAtlasDetailModel alloc] initWithDictionary:resultArr[i]];
                    [self.imageDatas addObject:imageAtlModel];
                }
                [self creatSubViews];
            }else{
                [self showNoDataViewInView:self.view noDataType:kNoDataType_NotFound];
                [self hiddenToolView];
                [self.view bringSubviewToFront:self.topView];
            }
        }else{
            [self showNoDataViewInView:self.view noDataType:kNoDataType_NotFound];
            [self hiddenToolView];
            [self.view bringSubviewToFront:self.topView];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self showNoDataViewInView:self.view noDataType:kNoDataType_NotFound];
        [self hiddenToolView];
        [self.view bringSubviewToFront:self.topView];
        [self hiddenLoadingView];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self showNoNetWorkView:NoNetWorkViewStyle_Load_Fail];
        [self.view bringSubviewToFront:self.topView];
        [self hiddenLoadingView];
    }];
}

- (void)hiddenToolView
{
    if ([self.topView viewWithTag:101]) {
        [[self.topView viewWithTag:101] setHidden:YES];
    }
    if ([self.topView viewWithTag:102]){
        [[self.topView viewWithTag:102] setHidden:YES];
    }
}

- (void)showToolView
{
    if ([self.topView viewWithTag:101]) {
        [[self.topView viewWithTag:101] setHidden:NO];
    }
    if ([self.topView viewWithTag:102]){
        [[self.topView viewWithTag:102] setHidden:NO];
    }
}

- (void)retryToGetData
{
    [self hideNoNetWorkView];
    [self requestWithContentId:self.imgAtlModel.artid];
}

- (void)creatSubViews{
    
    [self initInfoConfig];
    
    [self.view addSubview:self.imageScrollView];
    [self.imageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
    if (self.topView != nil) {
        [self.topView removeFromSuperview];
        self.topView = nil;
    }
    [self showToolView];
    [self.view addSubview:self.topView];
    [self addObserver:self forKeyPath:@"currentPage" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
    
    self.isReady = YES;
    
    if (_photoDescView != nil) {
        [_photoDescView removeFromSuperview];
    }
    ImageAtlasDetailModel *tmpModel = self.imageDatas[0];
    _photoDescView = [[DDPhotoDescView alloc] initWithDesc:tmpModel.atext index:0 totalCount:self.imageDatas.count];
    [self.view addSubview:_photoDescView];
    [_photoDescView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,_photoDescView.height));
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
    
}

- (void)initInfoConfig{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orieChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillDidBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActivePlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (ImageAtlasScrollView *)imageScrollView
{
    if (_imageScrollView == nil) {
        _imageScrollView = [[ImageAtlasScrollView alloc] initWithFrame:CGRectZero];
        _imageScrollView.contentSize = CGSizeMake(self.imageDatas.count * kMainBoundsWidth, kMainBoundsHeight *2);
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        // 切换的动画效果
        _imageScrollView.effect = JT3DScrollViewEffectNone;
        _imageScrollView.clipsToBounds = YES;
        _imageScrollView.delegate = self;
        
        // 设置小ScrollView（装载imageView的scrollView）
        for (int i = 0; i < self.imageDatas.count; i++) {
            
            ImageAtlasDetailModel *tmpModel = self.imageDatas[i];
            NSString *urlStr = tmpModel.pic_url;
            _photoScrollView = [[DDPhotoScrollView alloc] initWithFrame:CGRectZero urlString:urlStr];
            [_imageScrollView addSubview:_photoScrollView];
            [_scrollObjecArr addObject:_photoScrollView];
            [_photoScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(kMainBoundsWidth * i);
            }];
            
            // singleTapBlock回调：让所有UI，除了图片，全部消失
            __weak typeof(self) weakSelf = self;
            _photoScrollView.singleTapBlock = ^{
                // 如果已经消失，就出现
                if (weakSelf.isDisappear == YES) {
                    // 如果是竖屏状态
                    if (self.isPortrait == YES) {
                        [SAVORXAPI postUMHandleWithContentId:@"page_pic_vertical_show" key:nil value:nil];
                    }else{
                        [SAVORXAPI postUMHandleWithContentId:@"page_pic_landscape_show" key:nil value:nil];
                    }
                    [weakSelf.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (![obj isKindOfClass:[ImageAtlasScrollView class]]) {
                            [UIView animateWithDuration:0.5 animations:^{
                                obj.alpha = 1;
                                weakSelf.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:230/255.0 blue:223/255.0 alpha:1.0];
                            } completion:^(BOOL finished) {
                                obj.userInteractionEnabled = YES;
                            }];
                        }
                    }];
                    weakSelf.isDisappear = NO;
                    [weakSelf setNeedsStatusBarAppearanceUpdate];
                } else {
                    // 如果是竖屏状态
                    if (self.isPortrait == YES) {
                        [SAVORXAPI postUMHandleWithContentId:@"page_pic_vertical_hide" key:nil value:nil];
                    }else{
                        [SAVORXAPI postUMHandleWithContentId:@"page_pic_landscape_hide" key:nil value:nil];
                    }
                    // 消失
                    [weakSelf.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (![obj isKindOfClass:[ImageAtlasScrollView class]]) {
                            [UIView animateWithDuration:0.5 animations:^{
                                obj.alpha = 0;
                                weakSelf.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:230/255.0 blue:223/255.0 alpha:1.0];
                            } completion:^(BOOL finished) {
                                obj.userInteractionEnabled = NO;
                            }];
                        }
                    }];
                    weakSelf.isDisappear = YES;
                    [weakSelf setNeedsStatusBarAppearanceUpdate];
                }
            };
        }
    }
    return _imageScrollView;
}

#pragma mark - UIScrollViewDelegate
 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
     
     [self setValue:@(_imageScrollView.currentPage) forKey:@"currentPage"];
     
 }

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.isDisappear == NO) {
        [self wipeUp];
    }

    CGFloat offsetY = scrollView.contentOffset.y;
    NSLog(@"---%f",offsetY);
    if (offsetY >=  - 64) {
        CGFloat alpha = MIN(1, (offsetY)/kMainBoundsHeight);
        [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:alpha]];
//        [[UIApplication sharedApplication].keyWindow setAlpha:alpha];
//        [self.navigationController.navigationBar cnSetBackgroundColor:[color colorWithAlphaComponent:alpha]];
        
//        _descriptionView.alpha = 1 - alpha;
    } else {
        CGFloat alpha = MIN(1, (offsetY)/kMainBoundsHeight);
        [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:alpha]];
//        [[UIApplication sharedApplication].keyWindow setAlpha:0];
//        [self.navigationController.navigationBar cnSetBackgroundColor:[color colorWithAlphaComponent:0]];
    }
    if (scrollView.contentOffset.y == 0){
        self.view.backgroundColor = VCBackgroundColor;
    }
}
//完成拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    NSLog(@"ContentOffset  x is  %f,yis %f",scrollView.contentOffset.x,scrollView.contentOffset.y);
    NSLog(@"scrollViewDidEndDragging");
    if (scrollView.contentOffset.y > 200) {
        
    }else if (scrollView.contentOffset.y == 0){
        self.view.backgroundColor = VCBackgroundColor;
    }
}

- (void)wipeUp{
    
//    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f]];
//    [[UIApplication sharedApplication].keyWindow setAlpha:0.2];
    
    self.isDisappear = YES;
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[ImageAtlasScrollView class]]) {
            [UIView animateWithDuration:0.5 animations:^{
                obj.alpha = 0;
                self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:230/255.0 blue:223/255.0 alpha:1.0];
            } completion:^(BOOL finished) {
                obj.userInteractionEnabled = NO;
            }];
        }
    }];
}

//-(void)dismissViewWithAnimationDuration:(float)duration{
//    
//    [UIView animateWithDuration:duration animations:^{
//        
//        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
//        ImageAtlasScrollView.bottom = keyWindow.top;
//        
//    } completion:^(BOOL finished) {
//        
//        [ImageAtlasScrollView removeFromSuperview];
//        
//    }];
//}

#pragma mark - KVO
static int temp = -1;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    int newIndex = [change[@"new"] intValue];
    
    // 防止重复赋值，只有发生变化了才进行下一步操作。
    if (temp == newIndex) {
        return;
    } else {
        temp = newIndex;
        _currentIndex = newIndex;
    }
    // 如果已经消失了，就不展现描述文本了。
    if (_isDisappear == YES) {return;}
    // 先remove, 再加入
    [_photoDescView removeFromSuperview];
    ImageAtlasDetailModel *tmpModel = self.imageDatas[newIndex];
    
    _photoDescView = [[DDPhotoDescView alloc] initWithDesc:tmpModel.atext index:newIndex totalCount:self.imageDatas.count];
    [self.view addSubview:_photoDescView];
    [_photoDescView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,_photoDescView.height));
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
    
    //完整阅读图集，写日志
    if (newIndex == self.imageDatas.count - 1) {
        if (_isComplete == NO) {
            [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_COMPELETE type:RDLOGTYPE_CONTENT model:self.imgAtlModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
            _isComplete = YES;
    }
    }
}

#pragma mark - getter
- (UIView *)topView
{
    if (_topView == nil) {
        
        _topView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _topView.userInteractionEnabled = YES;
        _topView.contentMode = UIViewContentModeScaleToFill;
        _topView.backgroundColor = kThemeColor;
        [self.view addSubview:_topView];
        [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 64));
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(5,20, 40, 44)];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateSelected];
        [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_backButton];
        
        UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [shareBtn setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
        [shareBtn setImage:[UIImage imageNamed:@"icon_collect_yes"] forState:UIControlStateSelected];
        shareBtn.tag = 101;
        [shareBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:shareBtn];
        [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 44));
            make.top.mas_equalTo(20);
            make.right.mas_equalTo(- 15);
        }];
        
        _collectBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_collectBtn setImage:[UIImage imageNamed:@"icon_collect"] forState:UIControlStateNormal];
        [_collectBtn setImage:[UIImage imageNamed:@"icon_collect_yes"] forState:UIControlStateSelected];
        [_collectBtn addTarget:self action:@selector(collectAction) forControlEvents:UIControlEventTouchUpInside];
        _collectBtn.tag = 102;
        [_topView addSubview:_collectBtn];
        [_collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 44));
            make.top.mas_equalTo(20);
            make.right.mas_equalTo(- 65);
        }];
        
        _collectBtn.userInteractionEnabled = NO;
        HSGetCollectoinStateRequest * stateRequest = [[HSGetCollectoinStateRequest alloc] initWithArticleID:self.imgAtlModel.artid];
        [stateRequest sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            _collectBtn.userInteractionEnabled = YES;
            NSInteger collect = [[[response objectForKey:@"result"] objectForKey:@"state"] integerValue];
            // 设置收藏按钮状态
            if (collect == 1) {
                _collectBtn.selected = YES;
            }else{
                _collectBtn.selected = NO;
            }
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
        
        if (self.imgAtlModel.collected == 1) {
            _collectBtn.selected = YES;
        }
    }
    return _topView;
}

#pragma mark -分享点击
- (void)shareAction{
    
    [SAVORXAPI postUMHandleWithContentId:@"details_page_share" key:nil value:nil];
    HotPopShareView *shareView = [[HotPopShareView alloc] initWithModel:self.imgAtlModel andVC:self andCategoryID:self.categoryID andSourceId:0];
    [self.view addSubview:shareView];
}

#pragma mark -收藏点击
- (void)collectAction{
    
    NSInteger isCollect;
    if (self.collectBtn.selected == YES) {
        isCollect = 0;
    }else{
        isCollect = 1;
    }
    HSIsOrCollectionRequest * request = [[HSIsOrCollectionRequest alloc] initWithArticleId:self.imgAtlModel.artid withState:isCollect];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary *dic = (NSDictionary *)response;
        if ([[dic objectForKey:@"code"] integerValue] == 10000) {
            if (isCollect == 0) {
                self.imgAtlModel.collected = 0;
                [MBProgressHUD showSuccessHUDInView:self.view title:@"取消成功"];
                [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"success"];
            }else{
                self.imgAtlModel.collected = 1;
                [MBProgressHUD showSuccessHUDInView:self.view title:@"收藏成功"];
                [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"success"];
            }
            self.collectBtn.selected = !self.collectBtn.selected;
        }
        
        [GlobalData shared].isCollectAction = YES;
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        if (isCollect == 0) {
            [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"fail"];
        }else{
            [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"fail"];
        }
        [MBProgressHUD showTextHUDwithTitle:@"收藏失败" delay:1.f];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        if (isCollect == 0) {
            [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"fail"];
        }else{
            [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"fail"];
        }
        [MBProgressHUD showTextHUDwithTitle:@"收藏失败" delay:1.f];
    }];
}

#pragma mark -backButtonClick
- (void)backButtonClick
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -旋转屏幕调整布局
// 旋转屏幕通知处理
- (void)orieChanged
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
    
        _isPortrait = YES;
        [SAVORXAPI postUMHandleWithContentId:@"page_pic_landscape_rotate" key:nil value:nil];
        
        [self.imageScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        self.imageScrollView.width = kMainBoundsWidth;
        self.imageScrollView.contentOffset = CGPointMake(_currentIndex *kMainBoundsWidth, 0);
        _imageScrollView.contentSize = CGSizeMake(self.imageDatas.count * kMainBoundsWidth, kMainBoundsHeight);
        
        [_topView setImage:[UIImage new]];
        _topView.backgroundColor = kThemeColor;
        [_topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 64));
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        
        for (int i = 0; i < self.scrollObjecArr.count; i++) {
            DDPhotoScrollView *phoScrollView = (DDPhotoScrollView *)self.scrollObjecArr[i];
            [phoScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(kMainBoundsWidth * i);
            }];
        }

    }else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){

        _isPortrait = NO;
        [SAVORXAPI postUMHandleWithContentId:@"page_pic_vertical_rotate" key:nil value:nil];
        
        [self.imageScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        self.imageScrollView.width = kMainBoundsWidth;
        self.imageScrollView.contentOffset = CGPointMake(_currentIndex *kMainBoundsWidth, 0);
        _imageScrollView.contentSize = CGSizeMake(self.imageDatas.count * kMainBoundsWidth, kMainBoundsHeight);
        
        [_topView setImage:[UIImage imageNamed:@"quanpingmc"]];
        [_topView setBackgroundColor:[UIColor clearColor]];
        [_topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 85));
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];

        for (int i = 0; i < self.scrollObjecArr.count; i++) {
            DDPhotoScrollView *phoScrollView = (DDPhotoScrollView *)self.scrollObjecArr[i];
            [phoScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(kMainBoundsWidth * i);
            }];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_START type:RDLOGTYPE_CONTENT model:self.imgAtlModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
    [SAVORXAPI postUMHandleWithContentId:@"details_page" key:@"details_page" value:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [HSPicDetailRequest cancelRequest];
    [super viewDidDisappear:animated];
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_END type:RDLOGTYPE_CONTENT model:self.imgAtlModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
    [SAVORXAPI postUMHandleWithContentId:@"details_page_back" key:nil value:nil];
}

//app进入后台运行
- (void)appWillDidBackground{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_END type:RDLOGTYPE_CONTENT model:self.imgAtlModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

//app进入前台运行
- (void)appBecomeActivePlayground{
    [RDLogStatisticsAPI RDItemLogAction:RDLOGACTION_START type:RDLOGTYPE_CONTENT model:self.imgAtlModel categoryID:[NSString stringWithFormat:@"%ld", self.categoryID]];
}

- (BOOL)prefersStatusBarHidden
{
    return self.isDisappear;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.isReady) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)dealloc
{
    temp = -1;
    if (self.isReady) {
        [self removeObserver:self forKeyPath:@"currentPage"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
