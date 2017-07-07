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


@interface ImageAtlasDetailViewController ()<UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) ImageAtlasScrollView *imageScrollView;
@property (nonatomic, strong) DDPhotoDescView *photoDescView;
@property (nonatomic, strong) DDPhotoScrollView *photoScrollView;

@property (nonatomic, assign) BOOL isDisappear;
@property (nonatomic, assign) NSInteger currentIndex;

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
    
    [self.view addSubview:self.imageScrollView];
    [self.imageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
    [self addObserver:self forKeyPath:@"currentPage" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
    
    [self.view addSubview:self.backButton];
}

- (void)initInfoConfig{
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:230/255.0 blue:223/255.0 alpha:1.0];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollObjecArr = [[NSMutableArray alloc] initWithCapacity:100];
    self.imageArr = [NSArray arrayWithObjects:@"https://dn-brknqdxv.qbox.me/a70592e5162cb7df8391.jpg",@"https://dn-brknqdxv.qbox.me/d6e24a57b763c14b7731.jpg",@"https://dn-brknqdxv.qbox.me/5fb13268c2d1ef3bfe69.jpg",@"https://dn-brknqdxv.qbox.me/fea55faa880653633cc8.jpg",@"https://dn-brknqdxv.qbox.me/8401b45695d7fea371ca.jpg",@"https://dn-brknqdxv.qbox.me/59bda095dcb55dd91347.jpg",@"https://dn-brknqdxv.qbox.me/ec1379afc23d6afc3d90.jpg",@"https://dn-brknqdxv.qbox.me/51b10338ffdf7016a599.jpg",@"https://dn-brknqdxv.qbox.me/4b82c3574058ea94a2c8.jpg",@"https://dn-brknqdxv.qbox.me/a0287e02c7889227d5c7.jpg", nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orieChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (ImageAtlasScrollView *)imageScrollView
{
    if (_imageScrollView == nil) {
        _imageScrollView = [[ImageAtlasScrollView alloc] initWithFrame:CGRectZero];
        _imageScrollView.contentSize = CGSizeMake(self.imageArr.count * kMainBoundsWidth, kMainBoundsHeight);
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        // 切换的动画效果
        _imageScrollView.effect = JT3DScrollViewEffectNone;
        _imageScrollView.clipsToBounds = YES;
        _imageScrollView.delegate = self;
        
        // 设置小ScrollView（装载imageView的scrollView）
        for (int i = 0; i < self.imageArr.count; i++) {
            
            NSString *urlStr = self.imageArr[i];
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
    _photoDescView = [[DDPhotoDescView alloc] initWithDesc:@"这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容,这是描述的内容." index:newIndex totalCount:self.imageArr.count];
    [self.view addSubview:_photoDescView];
    
    [_photoDescView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 55,_photoDescView.height));
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
}

#pragma mark - getter
- (UIButton *)backButton
{
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 15, 40, 40)];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateSelected];
        [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

#pragma mark -
- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

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
        _imageScrollView.contentSize = CGSizeMake(self.imageArr.count * kMainBoundsWidth, kMainBoundsHeight);
        
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
        _imageScrollView.contentSize = CGSizeMake(self.imageArr.count * kMainBoundsWidth, kMainBoundsHeight);

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
