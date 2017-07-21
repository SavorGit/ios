//
//  DDPhotoDescView.m
//  DDNews
//
//  Created by Dvel on 16/4/20.
//  Copyright © 2016年 Dvel. All rights reserved.
//

#import "DDPhotoDescView.h"
#import "Masonry.h"
#import "UIView+Additional.h"
#import "RDTabScrollViewPage.h"

#define DescViewDefaultHeight 130
#define TextViewWidth         kMainBoundsWidth - 65
#define DistanceToBottom      20

@interface DDPhotoDescView()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) RDTabScrollViewPage * page;

@end

@implementation DDPhotoDescView

- (instancetype)initWithDesc:(NSString *)desc index:(NSInteger)index totalCount:(NSInteger)totalCount
{
	self = [super init];
	if (self) {

        self.backgroundColor = [UIColorFromRGB(0xece6de) colorWithAlphaComponent:.9f];
        
        // 页码
        _page = [[RDTabScrollViewPage alloc] initWithFrame:CGRectMake(5, 10, 40, 23) withTotalNumber:99 withType:RDTabScrollViewPageType_DOWNBIG withIndex:index + 1 ];
        _page.backgroundColor = [UIColor clearColor];
        [self addSubview:_page];
        
		// 描述文本
		self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
		self.textView.text = desc;
		self.textView.backgroundColor = [UIColor clearColor];
		self.textView.textColor = UIColorFromRGB(0x434343);
		self.textView.font = kPingFangLight(16);
        self.textView.textAlignment = NSTextAlignmentLeft;
        self.textView.userInteractionEnabled = NO;
        self.textView.editable = YES;
        self.textView.delegate = self;
        [self addSubview:self.textView];
        
        CGFloat textViewHeight = [self heightForString:self.textView andWidth:TextViewWidth];
        self.frame = CGRectMake(0, 0, kMainBoundsWidth, textViewHeight + DistanceToBottom);
		self.textView.frame = CGRectMake(50, 0, TextViewWidth, textViewHeight);
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orieChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	}
	return self;
}

- (float) heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}

/** 为了使超出self范围titleView也能响应手势，重写hitTest方法 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	UIView *view = [super hitTest:point withEvent:event];
	if (view == nil) {
		for (UIView *subView in self.subviews) {
			CGPoint p = [subView convertPoint:point fromView:self];
			if (CGRectContainsPoint(subView.bounds, p)) {
				view = subView;
			}
		}
	}
	return view;
}

// 旋转屏幕通知处理
- (void)orieChanged
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        CGFloat textViewHeight = [self heightForString:self.textView andWidth:kMainBoundsWidth - 75];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,textViewHeight + DistanceToBottom));
            make.bottom.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        self.textView.frame = CGRectMake(50, 0, TextViewWidth, textViewHeight);
        
    }else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        CGFloat textViewHeight = [self heightForString:self.textView andWidth:kMainBoundsWidth - 75];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,textViewHeight + DistanceToBottom));
            make.bottom.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        self.textView.frame = CGRectMake(50, 0, TextViewWidth, textViewHeight);

    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

@end
