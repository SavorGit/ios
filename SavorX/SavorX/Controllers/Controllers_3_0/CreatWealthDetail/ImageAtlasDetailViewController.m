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


@interface ImageAtlasDetailViewController ()<UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) ImageAtlasScrollView *imageScrollView;
@property (nonatomic, strong) DDPhotoDescView *photoDescView;
@property (nonatomic, strong) DDPhotoScrollView *photoScrollView;
@property (nonatomic, strong) UIButton *collectBtn;

@property (nonatomic, assign) BOOL isDisappear;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong)NSMutableArray *imageDatas;
@property (nonatomic, strong)NSArray *imageArr;
@property (nonatomic, strong)NSMutableArray *scrollObjecArr;
@property (assign, nonatomic) NSUInteger currentImageIndex;

@end

@implementation ImageAtlasDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [self initInfoConfig];
    [self.view addSubview:self.topView];
    //2650
    [self requestWithContentId:self.imgAtlModel.artid];
}

- (void)requestWithContentId:(NSString *)contentId{

    HSPicDetailRequest * request = [[HSPicDetailRequest alloc] initWithContentId:contentId];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSArray *resultArr = [response objectForKey:@"result"];
        for (int i = 0; i < resultArr.count; i ++) {
            ImageAtlasDetailModel *imageAtlModel = [[ImageAtlasDetailModel alloc] initWithDictionary:resultArr[i]];
            [self.imageDatas addObject:imageAtlModel];
        }
        [self creatSubViews];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)creatSubViews{
    
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
    [self.view addSubview:self.topView];
    [self addObserver:self forKeyPath:@"currentPage" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
    
}

- (void)initInfoConfig{
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:230/255.0 blue:223/255.0 alpha:1.0];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollObjecArr = [[NSMutableArray alloc] initWithCapacity:100];
    self.imageDatas = [[NSMutableArray alloc] initWithCapacity:100];
//    self.imageArr = [NSArray arrayWithObjects:@"https://dn-brknqdxv.qbox.me/a70592e5162cb7df8391.jpg",@"https://dn-brknqdxv.qbox.me/d6e24a57b763c14b7731.jpg",@"https://dn-brknqdxv.qbox.me/5fb13268c2d1ef3bfe69.jpg",@"https://dn-brknqdxv.qbox.me/fea55faa880653633cc8.jpg",@"https://dn-brknqdxv.qbox.me/8401b45695d7fea371ca.jpg",@"https://dn-brknqdxv.qbox.me/59bda095dcb55dd91347.jpg",@"https://dn-brknqdxv.qbox.me/ec1379afc23d6afc3d90.jpg",@"https://dn-brknqdxv.qbox.me/51b10338ffdf7016a599.jpg",@"https://dn-brknqdxv.qbox.me/4b82c3574058ea94a2c8.jpg",@"https://dn-brknqdxv.qbox.me/a0287e02c7889227d5c7.jpg", nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orieChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (ImageAtlasScrollView *)imageScrollView
{
    if (_imageScrollView == nil) {
        _imageScrollView = [[ImageAtlasScrollView alloc] initWithFrame:CGRectZero];
        _imageScrollView.contentSize = CGSizeMake(self.imageDatas.count * kMainBoundsWidth, kMainBoundsHeight);
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
                } else {
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
}

#pragma mark - getter
- (UIView *)topView
{
    if (_topView == nil) {
        
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
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
        [_topView addSubview:_collectBtn];
        [_collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 44));
            make.top.mas_equalTo(20);
            make.right.mas_equalTo(- 65);
        }];
        if (self.imgAtlModel.collected == 1) {
            _collectBtn.selected = YES;
        }
    }
    return _topView;
}

#pragma mark -分享点击
- (void)shareAction{
    
    HotPopShareView *shareView = [[HotPopShareView alloc] initWithModel:self.imgAtlModel andVC:self];
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
            if (self.imgAtlModel.collected == 1) {
                self.imgAtlModel.collected = 0;
                [MBProgressHUD showSuccessHUDInView:self.view title:@"取消成功"];
            }else{
                self.imgAtlModel.collected = 1;
                [MBProgressHUD showSuccessHUDInView:self.view title:@"收藏成功"];
            }
            self.collectBtn.selected = !self.collectBtn.selected;
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {

    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

#pragma mark -backButtonClick
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
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
    
        [self.imageScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        self.imageScrollView.width = kMainBoundsWidth;
        self.imageScrollView.contentOffset = CGPointMake(_currentIndex *kMainBoundsWidth, 0);
        _imageScrollView.contentSize = CGSizeMake(self.imageDatas.count * kMainBoundsWidth, kMainBoundsHeight);
        
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

        [self.imageScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        self.imageScrollView.width = kMainBoundsWidth;
        self.imageScrollView.contentOffset = CGPointMake(_currentIndex *kMainBoundsWidth, 0);
        _imageScrollView.contentSize = CGSizeMake(self.imageDatas.count * kMainBoundsWidth, kMainBoundsHeight);
        
        _topView.backgroundColor = [UIColor clearColor];
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
    }
}

- (void)dealloc
{
    temp = -1;
    [self removeObserver:self forKeyPath:@"currentPage"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
