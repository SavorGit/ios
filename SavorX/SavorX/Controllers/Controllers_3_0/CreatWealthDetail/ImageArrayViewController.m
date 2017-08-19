//
//  ImageArrayViewController.m
//  SavorX
//
//  Created by 郭春城 on 2017/8/18.
//  Copyright © 2017年 郭春城. All rights reserved.
//

//注意注册通知和移除通知需要添加判断
#import "ImageArrayViewController.h"
#import "ImageArrayCollectionViewCell.h"
#import "ImageAtlasDetailModel.h"
#import "HSPicDetailRequest.h"
#import "HSGetCollectoinStateRequest.h"
#import "HotPopShareView.h"
#import "HSIsOrCollectionRequest.h"

@interface ImageArrayViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, assign) NSInteger categoryID; //分类ID
@property(nonatomic ,strong) CreateWealthModel *imgAtlModel;

@property (nonatomic, strong) UICollectionView * baseCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout * baseLayout;

@property (nonatomic, strong) UIImageView * topView;
@property (nonatomic, strong) UIButton *collectBtn;
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) NSMutableArray * imageDatas;
@property (nonatomic, strong) UIPanGestureRecognizer * panGesture;
@property (nonatomic, strong) ImageArrayCollectionViewCell * currentCell;

@property (nonatomic, assign) BOOL isPortrait;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL isScrollCollectionView;

@end

@implementation ImageArrayViewController

- (instancetype)initWithCategoryID:(NSInteger)categoryID model:(CreateWealthModel *)model
{
    if (self = [super init]) {
        self.categoryID = categoryID;
        self.imgAtlModel = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GlobalData shared].isImageAtlasHiddenTop = NO;
    self.currentIndex = 0;
    self.isPortrait = YES;
    [GlobalData shared].isImageAtlas = YES;
    self.imageDatas = [NSMutableArray new];
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(64);
    }];
    [self requestWithContentId:self.imgAtlModel.artid];
    [self addObserver];
}

- (void)requestWithContentId:(NSString *)contentId{
    
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
                [self createSubViews];
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

- (void)createSubViews
{
    [self configBaseCollectionView];
}

- (void)configBaseCollectionView
{
    [self.view insertSubview:self.baseCollectionView belowSubview:self.topView];
    self.baseCollectionView.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
    [self.baseCollectionView reloadData];
    
    self.currentIndex = 0;
    [self performSelector:@selector(didScrollToItem) withObject:nil afterDelay:.1f];
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

#pragma mark - UICollectionView代理和数据源
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageDatas.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kMainBoundsWidth, kMainBoundsHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageArrayCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageArrayCell" forIndexPath:indexPath];
    
    ImageAtlasDetailModel * model = [self.imageDatas objectAtIndex:indexPath.row];
    [cell setImageWithURL:[NSURL URLWithString:model.pic_url]];
    
    return cell;
}

- (void)viewDidPan:(UIPanGestureRecognizer *)pan
{
    static CGPoint center;
    static BOOL isHidden;
    
    if (self.isScrollCollectionView) {
        return;
    }
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            center = pan.view.center;
            isHidden = [GlobalData shared].isImageAtlasHiddenTop;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            [self hiddenOtherView];
            
            CGPoint point = [pan translationInView:pan.view];
            CGPoint centerResult = CGPointMake(center.x, center.y + point.y);
            pan.view.center = centerResult;
            
            CGFloat contentY = fabs(centerResult.y - center.y);
            CGFloat scale = contentY / (kMainBoundsHeight / 2);
            CGFloat alpha = 1 - 0.4 * scale;
            if (alpha < .6f) {
                alpha = .6f;
            }
            self.view.backgroundColor = [VCBackgroundColor colorWithAlphaComponent:alpha];
        }
            break;
            
        case UIGestureRecognizerStateFailed:
        {
            [UIView animateWithDuration:.2f animations:^{
                pan.view.center = center;
                self.view.backgroundColor = VCBackgroundColor;
                if (isHidden) {
                    [GlobalData shared].isImageAtlasHiddenTop = NO;
                }
                [self topViewStatusShouldChange];
            }];
        }
            
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            [UIView animateWithDuration:.2f animations:^{
                pan.view.center = center;
                self.view.backgroundColor = VCBackgroundColor;
                if (isHidden) {
                    [GlobalData shared].isImageAtlasHiddenTop = NO;
                }
                [self topViewStatusShouldChange];
            }];
        }
            
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGFloat contentY = fabs(pan.view.center.y - center.y);
            if (contentY > kMainBoundsHeight / 5) {
                
                if (pan.view.center.y - center.y < 0) {
                    
                    //向上
                    [UIView animateWithDuration:.2f animations:^{
                        
                        pan.view.center = CGPointMake(pan.view.center.x, -(pan.view.frame.size.height / 2));
                        self.view.backgroundColor = [VCBackgroundColor colorWithAlphaComponent:0.f];
                        
                    } completion:^(BOOL finished) {
                        
                        [self backButtonClick];
                        
                    }];
                    
                }else{
                    
                    //向下
                    [UIView animateWithDuration:.2f animations:^{
                        
                        pan.view.center = CGPointMake(pan.view.center.x, kMainBoundsHeight+(pan.view.frame.size.height / 2));
                        self.view.backgroundColor = [VCBackgroundColor colorWithAlphaComponent:0.f];
                        
                    } completion:^(BOOL finished) {
                        
                        [self backButtonClick];
                        
                    }];
                    
                }
                
            }else{
                [UIView animateWithDuration:.2f animations:^{
                    pan.view.center = center;
                    self.view.backgroundColor = VCBackgroundColor;
                    if (isHidden) {
                        [GlobalData shared].isImageAtlasHiddenTop = NO;
                    }
                    [self topViewStatusShouldChange];
                }];
            }
            
        }
            
            break;
            
        default:
            break;
    }
}

- (void)hiddenOtherView
{
    if (![GlobalData shared].isImageAtlasHiddenTop) {
        self.topView.alpha = 0.f;
        [GlobalData shared].isImageAtlasHiddenTop = YES;
//        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - 屏幕方向发生变化
- (void)orieChanged
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        
        [self orieDidChangeToPortrait];
        
    }else if (orientation == UIInterfaceOrientationLandscapeLeft ||
              orientation == UIInterfaceOrientationLandscapeRight){
        
        [self orieDidChangeToLandscape];
        
    }
    
    self.baseCollectionView.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
    [self.baseCollectionView reloadData];
    [self.baseCollectionView setContentOffset:CGPointMake(kMainBoundsWidth * self.currentIndex, 0) animated:NO];
}

//竖屏
- (void)orieDidChangeToPortrait
{
    self.isPortrait = YES;
    
    [self.topView setImage:[UIImage new]];
    self.topView.backgroundColor = kThemeColor;
    
    self.panGesture.enabled = YES;
}

//横屏
- (void)orieDidChangeToLandscape
{
    self.isPortrait = NO;
    
    [self.topView setImage:[UIImage imageNamed:@"quanpingmc"]];
    [self.topView setBackgroundColor:[UIColor clearColor]];
    
    self.panGesture.enabled = NO;
}

#pragma mark - scrollView的代理方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.baseCollectionView) {
        self.currentIndex = lround(scrollView.contentOffset.x / kMainBoundsWidth);
        
        [self didScrollToItem];
    }
}

#pragma mark - 滑动到某一个item的时候相应的处理
- (void)didScrollToItem
{
    ImageArrayCollectionViewCell * cell = self.currentCell;
    if (cell) {
        [cell removeGestureForImage:self.panGesture];
    }
    
    [cell addGestureForImage:self.panGesture];
}

- (ImageArrayCollectionViewCell *)currentCell
{
    ImageArrayCollectionViewCell * cell = (ImageArrayCollectionViewCell *)[self.baseCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
    return cell;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer * pan = (UIPanGestureRecognizer *)gestureRecognizer;
        
        // 我们要响应水平移动和垂直移动, 根据上次和本次移动的位置，算出一个速率的point
        CGPoint veloctyPoint = [pan velocityInView:pan.view];
        
        if (pan.state == UIGestureRecognizerStateBegan) {
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) {
                self.isScrollCollectionView = YES;
                return YES;
            }else{
                self.isScrollCollectionView = NO;
                return NO;
            }
        }
    }
    
    return NO;
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orieChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (UICollectionViewFlowLayout *)baseLayout
{
    if (!_baseLayout) {
        _baseLayout = [[UICollectionViewFlowLayout alloc] init];
        _baseLayout.minimumLineSpacing = 0;
        _baseLayout.minimumInteritemSpacing = 0;
        _baseLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _baseLayout;
}

- (UICollectionView *)baseCollectionView
{
    if (!_baseCollectionView) {
        _baseCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:self.baseLayout];
        _baseCollectionView.backgroundColor = [UIColor clearColor];
        _baseCollectionView.pagingEnabled = YES;
        _baseCollectionView.showsHorizontalScrollIndicator = NO;
        _baseCollectionView.showsVerticalScrollIndicator = NO;
        [_baseCollectionView registerClass:[ImageArrayCollectionViewCell class] forCellWithReuseIdentifier:@"ImageArrayCell"];
        _baseCollectionView.dataSource = self;
        _baseCollectionView.delegate = self;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topViewStatusShouldChange)];
        tap.numberOfTapsRequired = 1;
        [_baseCollectionView addGestureRecognizer:tap];
    }
    return _baseCollectionView;
}

- (void)topViewStatusShouldChange
{
    if ([GlobalData shared].isImageAtlasHiddenTop) {
        [GlobalData shared].isImageAtlasHiddenTop = NO;
//        [self setNeedsStatusBarAppearanceUpdate];
        [UIView animateWithDuration:.3f animations:^{
            self.topView.alpha = 1.f;
        }];
        
    }else{
        [GlobalData shared].isImageAtlasHiddenTop = YES;
//        [self setNeedsStatusBarAppearanceUpdate];
        [UIView animateWithDuration:.3f animations:^{
            self.topView.alpha = 0.f;
        }];
    }
}

- (UIView *)topView
{
    if (_topView == nil) {
        
        _topView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _topView.userInteractionEnabled = YES;
        _topView.contentMode = UIViewContentModeScaleToFill;
        if (_isPortrait == YES) {
//            [_topView setImage:[UIImage new]];
            _topView.backgroundColor = kThemeColor;
        }else{
//            [_topView setImage:[UIImage imageNamed:@"quanpingmc"]];
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

#pragma mark - 返回上一级页面
- (void)backButtonClick
{
    [GlobalData shared].isImageAtlas = NO;
    [GlobalData shared].isImageAtlasHiddenTop = NO;
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // 如果当前是横屏状态，点击返回，需调用下边方法强制旋转屏幕
    if (_isPortrait == NO) {
        [Helper interfaceOrientation:UIInterfaceOrientationPortrait];
    }
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
