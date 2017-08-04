//
//  ViewController.m
//  GuideViewController
//
//  Created by 发兵 杨 on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDelegate.h"

@interface SplashViewController()<UIScrollViewDelegate>
{
    NSArray*                _imageArray ;
}
@property (retain, nonatomic) IBOutlet UIScrollView *pageScroll;
@property (strong, nonatomic) UIView *pageView;

@end
@implementation SplashViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _imageArray = [self createImageArray];
    [self createImageViews];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
-(NSArray*)createImageArray
{
    NSInteger count = 4;
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (int i = 1; i <=count; i ++)
    {
        NSString *imageName;
        if (kMainBoundsWidth==320 && kMainBoundsHeight==480)
        {
            imageName = [NSString stringWithFormat:@"index_%d.jpg", i];
        }
        else if(kMainBoundsWidth==320 && kMainBoundsHeight==568)
        {
            imageName = [NSString stringWithFormat:@"index4_%d.jpg",i];
        }else if(kMainBoundsWidth==375 && kMainBoundsHeight==667){
            imageName = [NSString stringWithFormat:@"index5_%d.jpg",i];
        }else if(kMainBoundsWidth==414 && kMainBoundsHeight==736){
            imageName = [NSString stringWithFormat:@"indexp6_%d.jpg",i];
        }
        UIImage *image = IMAGE_AT_APPDIR(imageName);
        if (image) {
            [imageArray addObject:image];
        }
    }
    return imageArray;
}


-(void)createImageViews
{
    _pageView = [[UIView alloc] init];
    _pageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_pageView];
    [_pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(65,3));
        make.bottom.mas_equalTo(- 20);
        make.centerX.mas_equalTo(0);
    }];
    for (int i = 0; i < 3; i ++) {
        UILabel *pageLabel = [[UILabel alloc] init];
        pageLabel.tag = i +1000;
        pageLabel.backgroundColor = UIColorFromRGB(0xddc8c4);
        if (i == 0) {
            pageLabel.frame = CGRectMake(i *15, 0, 15, 3);
            pageLabel.backgroundColor = UIColorFromRGB(0x902d3f);
        }else if (i == 1){
            pageLabel.frame = CGRectMake(10 + i *15, 0, 15, 3);
        }else if (i == 2){
            pageLabel.frame = CGRectMake(20 + i *15, 0, 15, 3);
        }
        pageLabel.layer.cornerRadius = 1.5;
        pageLabel.layer.masksToBounds = YES;
        [_pageView addSubview:pageLabel];
    }
    
    NSInteger count = _imageArray.count;
    if (count > 0)
    {
        _pageScroll.contentSize = CGSizeMake(kMainBoundsWidth*count, _pageScroll.frame.size.height);
        for (int i = 0; i < _imageArray.count; i ++)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kMainBoundsWidth*i, 0, kMainBoundsWidth, kMainBoundsHeight)];
            imageView.image = [_imageArray objectAtIndex:i];
            [_pageScroll addSubview:imageView];
            imageView.userInteractionEnabled = YES;
            if(i==count-1){
                UIButton* sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                sureBtn.backgroundColor = [UIColor clearColor];
                sureBtn.frame = CGRectZero;
                sureBtn.layer.cornerRadius = 2.0;
                sureBtn.layer.borderColor = UIColorFromRGB(0x922c3e).CGColor;
                sureBtn.layer.borderWidth = 1.0f;
                [sureBtn setTitle:RDLocalizedString(@"RDString_StartNow") forState:UIControlStateNormal];
                [sureBtn setTitleColor:UIColorFromRGB(0x922c3e) forState:UIControlStateNormal];
                [sureBtn.titleLabel setFont:kPingFangLight(16)];
                [sureBtn addTarget:self action:@selector(sureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [imageView addSubview:sureBtn];
                
                [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(88,30));
                    make.bottom.mas_equalTo(-40);
                    make.centerX.mas_equalTo(0);
                }];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    // 设置选中View背景色
    for (UILabel *label in [_pageView subviews]) {
        if (label.tag == page + 1000) {
            label.backgroundColor = UIColorFromRGB(0x902d3f);
        }else{
            label.backgroundColor = UIColorFromRGB(0xddc8c4);
        }
    }
}

-(void)sureBtnClicked:(id)sender
{
    
    if ([_delegate respondsToSelector:@selector(splashViewControllerSureBtnClicked)]) {
        [_delegate splashViewControllerSureBtnClicked];
    }
}

//允许屏幕旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

//返回当前屏幕旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
