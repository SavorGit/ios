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
#import "HotPopShareView.h"
#import "HSPicDetailRequest.h"
#import "ImageAtlasDetailModel.h"
#import "HSIsOrCollectionRequest.h"
#import "HSGetCollectoinStateRequest.h"
#import "RDLogStatisticsAPI.h"
#import "ImageAtlasCollectViewCell.h"
#import "HSImTeRecommendRequest.h"
#import "WebViewController.h"
#import "ImageTextDetailViewController.h"

@interface ImageAtlasDetailViewController ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) UIImageView *topView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) DDPhotoDescView *photoDescView;
@property (nonatomic, strong) DDPhotoScrollView *photoScrollView;
@property (nonatomic, strong) UIButton *collectBtn;
@property (nonatomic, assign) BOOL isComplete; //内容是否阅读完整

@property (nonatomic, assign) BOOL isDisappear;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) NSMutableArray *imageDatas;
@property (nonatomic, strong) NSArray *imageArr;
@property (nonatomic, strong) NSMutableArray *scrollObjecArr;
@property (assign, nonatomic) NSUInteger currentImageIndex;

@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isPortrait;
@property (nonatomic, assign) BOOL isComeBack;
@property (nonatomic, assign) BOOL isYChange;
//用来禁止45度滑动
@property (nonatomic, assign) CGPoint scrollViewStartPosPoint;
@property (nonatomic, assign) int     scrollDirection;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *recoLabel;
@property (nonatomic, strong) UIView *lineViewOne;
@property (nonatomic, strong) UIView *lineViewTwo;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ImageAtlasDetailViewController

- (instancetype)initWithCategoryID:(NSInteger)categoryID model:(CreateWealthModel *)model
{
    if (self = [super init]) {
        self.categoryID = categoryID;
        self.imgAtlModel = model;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = VCBackgroundColor;
    
    [GlobalData shared].isImageAtlas = YES;
    self.isPortrait = YES;
    self.isComeBack = YES;
    _isComplete = NO;
    _isPortrait = YES;
    _scrollDirection = 0;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.scrollObjecArr = [[NSMutableArray alloc] initWithCapacity:100];
    self.imageDatas = [[NSMutableArray alloc] initWithCapacity:100];
    self.dataSource = [[NSMutableArray alloc] initWithCapacity:100];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    [self.view addSubview:self.topView];

    [self requestWithContentId:self.imgAtlModel.artid];
    [self setUpDatas];
}

- (void)requestWithContentId:(NSString *)contentId{

    self.isReady = NO;
    [self showLoadingView];
    HSPicDetailRequest * request = [[HSPicDetailRequest alloc] initWithContentId:contentId];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self hiddenLoadingView];
        
        [self.imageDatas removeAllObjects];
        
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
        if ([[response objectForKey:@"code"] integerValue] == 19002) {
            [self showNoDataViewInView:self.view noDataType:kNoDataType_NotFound];
        }else{
            [self showNoNetWorkViewInView:self.view];
        }
        [self hiddenToolView];
        [self.view bringSubviewToFront:self.topView];
        [self hiddenLoadingView];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self showNoNetWorkView:NoNetWorkViewStyle_Load_Fail];
        [self.view bringSubviewToFront:self.topView];
        [self hiddenLoadingView];
    }];
}

#pragma mark -  请求图集推荐数据
- (void)setUpDatas{
    
    HSImTeRecommendRequest * request = [[HSImTeRecommendRequest alloc] initWithArticleId:self.imgAtlModel.artid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.dataSource removeAllObjects];
        
        NSDictionary *dic = (NSDictionary *)response;
        NSArray *resultArr = [dic objectForKey:@"result"];
        
        for (int i = 0; i < resultArr.count; i ++) {
            CreateWealthModel *welthModel = [[CreateWealthModel alloc] initWithDictionary:resultArr[i]];
            [self.dataSource addObject:welthModel];
        }
        // 当返回有推荐数据时调用
        if (self.dataSource.count > 0) {
            [self.collectionView reloadData];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
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

- (UIScrollView *)imageScrollView
{
    if (_imageScrollView == nil) {
        
        // Y轴初始化坐标
        CGFloat offSetYPoint;
        _imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        if (_isPortrait == YES) {
            offSetYPoint = kMainBoundsHeight;
            _imageScrollView.contentSize = CGSizeMake((self.imageDatas.count + 1) * kMainBoundsWidth, kMainBoundsHeight *3);
            [_imageScrollView setContentOffset:CGPointMake(0, offSetYPoint)];
        }else{
            offSetYPoint = 0.0;
            _imageScrollView.contentSize = CGSizeMake((self.imageDatas.count + 1) * kMainBoundsWidth, kMainBoundsHeight);
        }
        _imageScrollView.pagingEnabled = YES;
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        _imageScrollView.showsVerticalScrollIndicator = NO;
        _imageScrollView.clipsToBounds = YES;
        _imageScrollView.directionalLockEnabled = YES;
        _imageScrollView.delegate = self;
        
        //点击推荐图集，重新请求数据后清除
        [self.scrollObjecArr removeAllObjects];
        // 设置小ScrollView（装载imageView的scrollView）
        for (int i = 0; i < self.imageDatas.count; i++) {
            
            ImageAtlasDetailModel *tmpModel = self.imageDatas[i];
            NSString *urlStr = tmpModel.pic_url;
            _photoScrollView = [[DDPhotoScrollView alloc] initWithFrame:CGRectZero urlString:urlStr];
            [_imageScrollView addSubview:_photoScrollView];
            [self.scrollObjecArr addObject:_photoScrollView];
            [_photoScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
                make.top.mas_equalTo(offSetYPoint);
                make.left.mas_equalTo(kMainBoundsWidth * i);
            }];
            
            // singleTapBlock回调：让所有UI，除了图片，全部消失
            __weak typeof(self) weakSelf = self;
            _photoScrollView.singleTapBlock = ^{
                // 如果已经消失，就出现
                if (weakSelf.isDisappear == YES) {
                    // 如果是竖屏状态
                    if (weakSelf.isPortrait == YES) {
                        [SAVORXAPI postUMHandleWithContentId:@"page_pic_vertical_show" key:nil value:nil];
                    }else{
                        [SAVORXAPI postUMHandleWithContentId:@"page_pic_landscape_show" key:nil value:nil];
                    }
                    [weakSelf.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (![obj isKindOfClass:[UIScrollView class]]) {
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
                    if (weakSelf.isPortrait == YES) {
                        [SAVORXAPI postUMHandleWithContentId:@"page_pic_vertical_hide" key:nil value:nil];
                    }else{
                        [SAVORXAPI postUMHandleWithContentId:@"page_pic_landscape_hide" key:nil value:nil];
                    }
                    // 消失
                    [weakSelf.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (![obj isKindOfClass:[UIScrollView class]]) {
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
        
        _recoLabel = [[UILabel alloc]init];
        _recoLabel.backgroundColor = [UIColor clearColor];
        _recoLabel.font = kPingFangLight(16);
        _recoLabel.textColor = UIColorFromRGB(0x922c3e);
        _recoLabel.textAlignment = NSTextAlignmentCenter;
        _recoLabel.text = RDLocalizedString(@"RDString_imgAtRecommend");
        [_imageScrollView addSubview:_recoLabel];
        [_recoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(70,45));
            make.top.mas_equalTo(offSetYPoint + 64);
            make.left.mas_equalTo(kMainBoundsWidth * self.imageDatas.count + kMainBoundsWidth/2 - 35);
        }];
        
        _lineViewOne = [[UIView alloc] initWithFrame:CGRectZero];
        _lineViewOne.backgroundColor = UIColorFromRGB(0x922c3e);
        [_imageScrollView addSubview:_lineViewOne];
        [_lineViewOne mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth/2 - 100, 1));
            make.top.mas_equalTo(offSetYPoint + 64 + 22);
            make.right.mas_equalTo(_recoLabel.mas_left).offset(- 10);
        }];
        
        _lineViewTwo = [[UIView alloc] initWithFrame:CGRectZero];
        _lineViewTwo.backgroundColor = UIColorFromRGB(0x922c3e);
        [_imageScrollView addSubview:_lineViewTwo];
        [_lineViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth/2 - 100, 1));
            make.top.mas_equalTo(offSetYPoint + 64 + 22);
            make.left.mas_equalTo(_recoLabel.mas_right).offset(10);
        }];
        
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 5, 0);
        _collectionView=[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor=[UIColor clearColor];
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_imageScrollView addSubview:_collectionView];
        [_collectionView registerClass:[ImageAtlasCollectViewCell class] forCellWithReuseIdentifier:@"imgCell"];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight - 64 - 45));
            make.top.mas_equalTo(offSetYPoint + 64 + 45);
            make.left.mas_equalTo(kMainBoundsWidth * self.imageDatas.count);
        }];
        
    }
    return _imageScrollView;
}

#pragma mark - UIScrollViewDelegate 代理方法
 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
     
     if (![scrollView isKindOfClass:[UICollectionView class]] && _isPortrait == YES) {
         // y轴发生了位移
         _isYChange = NO;
         
         if (_isComeBack == YES) {
             if (scrollView.contentOffset.y > 120 + kMainBoundsHeight) {
                 _imageScrollView.pagingEnabled = NO;
                 self.isComeBack = NO;
                 [self dismissFromTopWithDuration:0.5];
             }else if (scrollView.contentOffset.y < kMainBoundsHeight - 100){
                 self.isComeBack = NO;
                 [self dismissFromDownWithDuration:0.5];
             }
         }
         //算出页码
         CGFloat pageWidth = scrollView.frame.size.width;
         float fractionalPage = scrollView.contentOffset.x / pageWidth;
         NSInteger page = lround(fractionalPage);
         
         if (page == self.imageDatas.count) {
             if (_isDisappear == YES) {
                 [self wipeUpOrDown];
             }
         }
         [self setValue:@(page) forKey:@"currentPage"];
         
     }else if (![scrollView isKindOfClass:[UICollectionView class]]){
         //算出页码
         CGFloat pageWidth = scrollView.frame.size.width;
         float fractionalPage = scrollView.contentOffset.x / pageWidth;
         NSInteger page = lround(fractionalPage);
         
         if (page == self.imageDatas.count) {
             if (_isDisappear == YES) {
                 [self wipeUpOrDown];
             }
         }
         [self setValue:@(page) forKey:@"currentPage"];
     }
     
     self.scrollDirection =0;
 }

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (![scrollView isKindOfClass:[UICollectionView class]] && _isPortrait == YES) {
        
        CGFloat offsetY = scrollView.contentOffset.y;
//        NSLog(@"---%f",offsetY);
        
        if (offsetY > kMainBoundsHeight || offsetY < kMainBoundsHeight) {
            _isYChange = YES;
            if (self.isDisappear == NO) {
                [self wipeUpOrDown];
            }
        }
        
        if (offsetY >  kMainBoundsHeight) {
            if ( self.isComeBack == YES) {
                CGFloat alpha = (offsetY - kMainBoundsHeight)/kMainBoundsHeight;
                self.view.backgroundColor = [VCBackgroundColor colorWithAlphaComponent:1 - alpha];
            }
        }else if (offsetY <  kMainBoundsHeight) {
            if (self.isComeBack == YES) {
                CGFloat alpha = (kMainBoundsHeight - offsetY)/kMainBoundsHeight;
                self.view.backgroundColor = [VCBackgroundColor colorWithAlphaComponent: 1 - alpha];
            }
        }
        
        if (self.isComeBack == YES) {
            
            if (offsetY == kMainBoundsHeight && _isYChange == YES){
                self.view.backgroundColor = [VCBackgroundColor colorWithAlphaComponent: 1.0];
                if (self.isDisappear == YES) {
                    [self wipeUpOrDown];
                }
            }
        }
        
        if (self.scrollDirection == 0){//we need to determine direction
            //use the difference between positions to determine the direction.
            if (abs(self.scrollViewStartPosPoint.x-scrollView.contentOffset.x)<
                abs(self.scrollViewStartPosPoint.y-scrollView.contentOffset.y)){
                //Vertical Scrolling
                self.scrollDirection = 1;
            } else {
                //Horitonzal Scrolling
                self.scrollDirection = 2;
            }
        }
        //Update scroll position of the scrollview according to detected direction.
        if (self.scrollDirection == 1) {
            scrollView.contentOffset = CGPointMake(self.scrollViewStartPosPoint.x,scrollView.contentOffset.y);
        } else if (self.scrollDirection == 2){
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x,self.scrollViewStartPosPoint.y);
        }
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_isPortrait == YES) {
        self.scrollViewStartPosPoint = scrollView.contentOffset;
        self.scrollDirection = 0;
    }
    
}

//完成拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if (![scrollView isKindOfClass:[UICollectionView class]] && _isPortrait == YES) {
//        NSLog(@"--- x is  %f,---y  is %f",scrollView.contentOffset.x,scrollView.contentOffset.y);
        self.isComeBack = YES;
        if (scrollView.contentOffset.y > 120 + kMainBoundsHeight ) {
            _imageScrollView.pagingEnabled = NO;
            self.isComeBack = NO;
            [self dismissFromTopWithDuration:0.5];
        }else if (scrollView.contentOffset.y < kMainBoundsHeight - 100 ){
            self.isComeBack = NO;
            [self dismissFromDownWithDuration:0.5];
        }
    }
    
    if (decelerate) {
        self.scrollDirection =0;
    }
}

// 向上或是向下滑
- (void)wipeUpOrDown{
    
    __weak typeof(self) weakSelf = self;
    if (self.isDisappear == YES) {
        self.isDisappear = NO;
        [weakSelf.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[UIScrollView class]]) {
                [UIView animateWithDuration:0.2 animations:^{
                    obj.alpha = 1;
                } completion:^(BOOL finished) {
                    obj.userInteractionEnabled = YES;
                }];
            }
        }];
    }else{
        self.isDisappear = YES;
        [weakSelf.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[UIScrollView class]]) {
                [UIView animateWithDuration:0.2 animations:^{
                    obj.alpha = 0;
                } completion:^(BOOL finished) {
                    obj.userInteractionEnabled = NO;
                }];
            }
        }];
    }

}

// 页面从顶部消失
-(void)dismissFromTopWithDuration:(float)duration{
    
    [UIView animateWithDuration:duration animations:^{
        
        self.view.backgroundColor = [VCBackgroundColor colorWithAlphaComponent: 0.0];
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        _imageScrollView.bottom = keyWindow.top;
        [GlobalData shared].isImageAtlas = NO;
        [self dismissViewControllerAnimated:NO completion:nil];
        
    } completion:^(BOOL finished) {
        
        [_imageScrollView removeFromSuperview];
        
    }];
}

// 页面从底部消失
-(void)dismissFromDownWithDuration:(float)duration{
    
    [UIView animateWithDuration:duration animations:^{
        
        self.view.backgroundColor = [VCBackgroundColor colorWithAlphaComponent: 0.0];
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        _imageScrollView.top = keyWindow.bottom;
        [GlobalData shared].isImageAtlas = NO;
        [self dismissViewControllerAnimated:NO completion:nil];
        
    } completion:^(BOOL finished) {
        
        [_imageScrollView removeFromSuperview];
        
    }];
}


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
    // 如果页码大于当前最大数，不展示文本
    if (newIndex == self.imageDatas.count) {
        return;
    }
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
        if (_isPortrait == YES) {
            [_topView setImage:[UIImage new]];
            _topView.backgroundColor = kThemeColor;
        }else{
            [_topView setImage:[UIImage imageNamed:@"quanpingmc"]];
        }
        [self.view addSubview:_topView];
        [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(64);
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
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

#pragma mark - UICollectionView 代理方法
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageAtlasCollectViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"imgCell" forIndexPath:indexPath];
    cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
    
    CreateWealthModel *tmpModel = [self.dataSource objectAtIndex:indexPath.row];
    [cell configModelData:tmpModel andIsPortrait:_isPortrait];
    
    return cell;
}

//定义每一个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = 0;
    CGFloat height = 0;
    
    if (_isPortrait == YES) {
        width = (kMainBoundsWidth-5) / 2;
        height = (kMainBoundsHeight - 64 - 45 - 5 - 5 - 5) / 3;
    }else{
        width = (kMainBoundsWidth-10) / 3;
        height = (kMainBoundsHeight - 64 - 45 - 5 - 5 - 5) / 2;
    }
    return CGSizeMake(width, height);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CreateWealthModel *tmpModel = [self.dataSource objectAtIndex:indexPath.row];
    if (tmpModel.type == 3 || tmpModel.type == 4) {
        
        if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
            [Helper interfaceOrientation:UIInterfaceOrientationPortrait];
        }
        
        WebViewController * web = [[WebViewController alloc] initWithModel:tmpModel categoryID:self.categoryID];
        
        UINavigationController * na = self.parentNavigationController;
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
        [na pushViewController:web animated:YES];
        
    }else if (tmpModel.type == 1){
        
        if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
            [Helper interfaceOrientation:UIInterfaceOrientationPortrait];
        }
        
        ImageTextDetailViewController * text = [[ImageTextDetailViewController alloc] initWithCategoryID:self.categoryID model:tmpModel];
        
        UINavigationController * na = self.parentNavigationController;
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
        [na pushViewController:text animated:YES];
        
    }else{
        self.imgAtlModel = tmpModel;
        
        _currentIndex = 0;
        [self removeObserver];
        [_imageScrollView removeFromSuperview];
        _imageScrollView = nil;
        [_collectionView removeFromSuperview];
        _collectionView = nil;
        
        [self requestWithContentId:self.imgAtlModel.artid];
        [self setUpDatas];
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

#pragma mark - 返回上一级页面
- (void)backButtonClick
{
    [GlobalData shared].isImageAtlas = NO;
    [self dismissViewControllerAnimated:NO completion:nil];

    // 如果当前是横屏状态，点击返回，需调用下边方法强制旋转屏幕
//    UIViewController *vc  = [[UIViewController alloc] init];
//    [self presentViewController:vc animated:NO completion:^{
//        [vc dismissViewControllerAnimated:NO completion:nil];
//    }];
    
    // 如果当前是横屏状态，点击返回，需调用下边方法强制旋转屏幕
    if (_isPortrait == NO) {
        [[UIDevice currentDevice] setValue:
         [NSNumber numberWithInteger: _isPortrait?
         UIInterfaceOrientationLandscapeRight:UIInterfaceOrientationPortrait]
         forKey:@"orientation"];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    
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
                [MBProgressHUD showSuccessHUDInView:self.view title:RDLocalizedString(@"RDString_SuccessWithCancle")];
                [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"success"];
            }else{
                self.imgAtlModel.collected = 1;
                [MBProgressHUD showSuccessHUDInView:self.view title:RDLocalizedString(@"RDString_SuccessWithCollect")];
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
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithCollect") delay:1.f];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        if (isCollect == 0) {
            [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"fail"];
        }else{
            [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"fail"];
        }
        [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FailedWithCollect") delay:1.f];
    }];
}

#pragma mark --- 旋转屏幕调整布局
- (void)orieChanged
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == UIInterfaceOrientationPortrait) {
        
        [SAVORXAPI postUMHandleWithContentId:@"page_pic_landscape_rotate" key:nil value:nil];
        
        [self.imageScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        self.imageScrollView.width = kMainBoundsWidth;
        self.imageScrollView.contentOffset = CGPointMake(_currentIndex *kMainBoundsWidth, kMainBoundsHeight);
        _imageScrollView.contentSize = CGSizeMake((self.imageDatas.count + 1) * kMainBoundsWidth, kMainBoundsHeight *3);
        
        
        [_topView setImage:[UIImage new]];
        _topView.backgroundColor = kThemeColor;
//        [_topView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 64));
//            make.top.mas_equalTo(0);
//            make.left.mas_equalTo(0);
//        }];
        
        for (int i = 0; i < self.scrollObjecArr.count; i++) {
            DDPhotoScrollView *phoScrollView = (DDPhotoScrollView *)self.scrollObjecArr[i];
            [phoScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
                make.top.mas_equalTo(kMainBoundsHeight);
                make.left.mas_equalTo(kMainBoundsWidth * i);
            }];
        }
        
        [_recoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(70,45));
            make.top.mas_equalTo(kMainBoundsHeight + 64);
            make.left.mas_equalTo(kMainBoundsWidth * self.imageDatas.count + kMainBoundsWidth/2 - 35);
        }];
        
        [_lineViewOne mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth/2 - 100, 1));
            make.top.mas_equalTo(kMainBoundsHeight + 64 + 22);
            make.right.mas_equalTo(_recoLabel.mas_left).offset(- 10);
        }];
        
        [_lineViewTwo mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth/2 - 100, 1));
            make.top.mas_equalTo(kMainBoundsHeight + 64 + 22);
            make.left.mas_equalTo(_recoLabel.mas_right).offset(10);
        }];
        
        [_collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight - 64 - 45));
            make.top.mas_equalTo(kMainBoundsHeight + 64 + 45);
            make.left.mas_equalTo(kMainBoundsWidth * self.imageDatas.count);
        }];
        _isPortrait = YES;
        [_collectionView reloadData];
        
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
        _imageScrollView.contentSize = CGSizeMake((self.imageDatas.count + 1) * kMainBoundsWidth, kMainBoundsHeight);
        
        
        
        [_topView setImage:[UIImage imageNamed:@"quanpingmc"]];
        [_topView setBackgroundColor:[UIColor clearColor]];
//        [_topView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 85));
//            make.top.mas_equalTo(0);
//            make.left.mas_equalTo(0);
//        }];
        
        for (int i = 0; i < self.scrollObjecArr.count; i++) {
            DDPhotoScrollView *phoScrollView = (DDPhotoScrollView *)self.scrollObjecArr[i];
            [phoScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(kMainBoundsWidth * i);
            }];
        }
        
        [_recoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(70,45));
            make.top.mas_equalTo(64);
            make.left.mas_equalTo(kMainBoundsWidth * self.imageDatas.count + kMainBoundsWidth/2 - 35);
        }];
        
        [_lineViewOne mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth/2 - 100, 1));
            make.top.mas_equalTo(64 + 22);
            make.right.mas_equalTo(_recoLabel.mas_left).offset(- 10);
        }];
        
        [_lineViewTwo mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth/2 - 100, 1));
            make.top.mas_equalTo(64 + 22);
            make.left.mas_equalTo(_recoLabel.mas_right).offset(10);
        }];
        
        [_collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            // 横屏最下方多留5像素间距
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight - 64 - 45 - 5));
            make.top.mas_equalTo(64 + 45);
            make.left.mas_equalTo(kMainBoundsWidth * self.imageDatas.count);
        }];
        [_collectionView reloadData];
    }
}

- (void)initInfoConfig{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orieChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillDidBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActivePlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc
{
    temp = -1;
    [self removeObserver];

}

// 移除通知及观察者
- (void)removeObserver{
    
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
