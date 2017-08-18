//
//  DDPhotoScrollView.m
//  DDNews
//
//  Created by Dvel on 16/4/19.
//  Copyright © 2016年 Dvel. All rights reserved.
//

#import "DDPhotoScrollView.h"
#import "Masonry.h"
#import "UIView+Additional.h"
#import "UIImageView+WebCache.h"

@interface DDPhotoScrollView () <UIScrollViewDelegate>
@end

@implementation DDPhotoScrollView

- (instancetype)initWithFrame:(CGRect)frame urlString:(NSString *)urlString
{
	self = [super initWithFrame:frame];
	if (self) {
		// 设置图片
		_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,kMainBoundsWidth, kMainBoundsHeight)];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		_imageView.userInteractionEnabled = YES;
		[_imageView sd_setImageWithURL:[NSURL URLWithString:urlString]
				 placeholderImage:[UIImage imageNamed:@"zanwu"]
						  options:SDWebImageContinueInBackground];
		[self addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
		
		// 设置scrollView和缩放
		self.delegate = self;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
        self.minimumZoomScale = 1;
		self.maximumZoomScale = 2.0;
        
		// 单击手势
		UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnScrollView)];
        [singleTap setNumberOfTapsRequired:1];
		[_imageView addGestureRecognizer:singleTap];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orieChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

	}
	return self;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _imageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
//	CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
//	(scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
//	CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
//	(scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
//	CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
//									   scrollView.contentSize.height * 0.5 + offsetY);
//	_imageView.center = actualCenter;
    
//	NSLog(@"%@", NSStringFromCGAffineTransform(scrollView.subviews[0].transform));
    
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                            
                            scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{	
	// 直接模拟doubleTap即可
	UITapGestureRecognizer *recognizer = [UITapGestureRecognizer new];
	[recognizer setValue:scrollView forKey:@"view"];
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    NSLog(@"缩放比例-----%f",scale);
    
}

/**
 *  根据图片和屏幕比例关系,调整最大和最小伸缩比例
 */
- (void)setMaxAndMinZoomScales
{
    // self.photoImageView的初始位置
    UIImage *image = self.imageView.image;
    if (image == nil || image.size.height==0) {
        return;
    }
    CGFloat imageWidthHeightRatio = image.size.width / image.size.height;
    self.imageView.width = kMainBoundsWidth;
    self.imageView.height = kMainBoundsWidth / imageWidthHeightRatio;
    self.imageView.centerX = 0;
    if (self.imageView.height > kMainBoundsHeight) {
        self.imageView.centerY = 0;
        self.scrollEnabled = YES;
    } else {
        self.imageView.centerY = (kMainBoundsHeight - self.imageView.height ) * 0.5;
        self.scrollEnabled = NO;
    }
    self.maximumZoomScale = MAX(kMainBoundsHeight / self.imageView.height, 3.0);
    self.minimumZoomScale = 1.0;
    self.zoomScale = 1.0;
    self.contentSize = CGSizeMake(self.imageView.width, MAX(self.imageView.height, kMainBoundsHeight));
}

#pragma mark - 手势
- (void)singleTapOnScrollView
{
	if (self.singleTapBlock) {
		self.singleTapBlock();
	}
}

// 旋转屏幕通知处理
- (void)orieChanged
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        [_imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        
    }else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        [_imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,kMainBoundsHeight));
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
    }
}

@end
