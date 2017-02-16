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
    NSInteger count = _imageArray.count;
    if (count > 0)
    {
        _pageScroll.contentSize = CGSizeMake(kMainBoundsWidth*count, _pageScroll.frame.size.height);
        for (int i = 0; i < _imageArray.count; i ++)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kMainBoundsWidth*i, 0, kMainBoundsWidth, kMainBoundsHeight)];
            imageView.image = [_imageArray objectAtIndex:i];
            [_pageScroll addSubview:imageView];
            if(i==count-1){
                UIButton* sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                sureBtn.backgroundColor = [UIColor clearColor];
                sureBtn.frame = CGRectMake(0, 0, 115, 32);
//                [sureBtn setImage:IMAGE_AT_APPDIR(@"icon_kaiqi_normal.png") forState:UIControlStateNormal];
//                [sureBtn setImage:IMAGE_AT_APPDIR(@"icon_kaiqi_press.png") forState:UIControlStateHighlighted];
    
                sureBtn.layer.cornerRadius = 2.0;
                sureBtn.layer.borderColor = [UIColor whiteColor].CGColor;
                sureBtn.layer.borderWidth = 1.0f;
                [sureBtn setTitle:@"立即体验" forState:UIControlStateNormal];
                
                
                sureBtn.centerX = imageView.left+kMainBoundsWidth/2;
               
                if (kMainBoundsWidth==320 && kMainBoundsHeight==480)
                {
                     sureBtn.bottom = kMainBoundsHeight-178;
                }
                else if(kMainBoundsWidth==320 && kMainBoundsHeight==568)
                {
                    sureBtn.bottom = kMainBoundsHeight-185;
                }else if(kMainBoundsWidth==375 && kMainBoundsHeight==667){
                    sureBtn.bottom = kMainBoundsHeight-215;
                }else if(kMainBoundsWidth==414 && kMainBoundsHeight==736){
                    sureBtn.bottom = kMainBoundsHeight-245;
                }

                [sureBtn addTarget:self action:@selector(sureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [_pageScroll addSubview:sureBtn];
            }
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
