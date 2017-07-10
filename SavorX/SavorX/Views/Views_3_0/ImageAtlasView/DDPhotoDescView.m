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

#define DescViewDefaultHeight 130

@interface DDPhotoDescView()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation DDPhotoDescView

- (instancetype)initWithDesc:(NSString *)desc index:(NSInteger)index totalCount:(NSInteger)totalCount
{
	self = [super init];
	if (self) {

		// 描述文本
		self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 0)];
		self.textView.text = desc;
		self.textView.backgroundColor = [UIColor clearColor];
		self.textView.textColor = [UIColor lightGrayColor];
		self.textView.font = [UIFont systemFontOfSize:16];
        
        CGFloat textViewHeight = [self heightForString:self.textView andWidth:kMainBoundsWidth - 55];
        // self
        self.frame = CGRectMake(0, 0, kMainBoundsWidth, textViewHeight + 10);
        self.backgroundColor = [UIColor clearColor];
        
		self.textView.frame = CGRectMake(55, 0, kMainBoundsWidth - 55, textViewHeight);
		self.textView.userInteractionEnabled = NO;
		[self addSubview:self.textView];

		// 页码里的index
		UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 3, 30, textViewHeight)];
		NSMutableAttributedString *aStrM = [[NSMutableAttributedString alloc]
											initWithString:[NSString stringWithFormat:@"%zd", index + 1]
											attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18]}];
		[aStrM appendAttributedString:[[NSAttributedString alloc] initWithString:@"/"]];
		[aStrM appendAttributedString:[[NSAttributedString alloc]
									   initWithString:[NSString stringWithFormat:@"%zd", totalCount]
									   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}]];
		[aStrM addAttribute:NSKernAttributeName value:@2 range:NSMakeRange(0, aStrM.length)];
		indexLabel.attributedText = aStrM;
		indexLabel.textAlignment = NSTextAlignmentCenter;
		indexLabel.textColor = [UIColor whiteColor];
		[indexLabel sizeToFit];
		[self addSubview:indexLabel];
        
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
        CGFloat textViewHeight = [self heightForString:self.textView andWidth:kMainBoundsWidth - 55];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,textViewHeight + 10));
            make.bottom.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
       self.textView.frame = CGRectMake(55, 0, kMainBoundsWidth - 55, textViewHeight);
        
    }else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        CGFloat textViewHeight = [self heightForString:self.textView andWidth:kMainBoundsWidth - 55];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth,textViewHeight + 10));
            make.bottom.mas_equalTo(0);
            make.left.mas_equalTo(0);
        }];
        self.textView.frame = CGRectMake(55, 0, kMainBoundsWidth - 55, textViewHeight);

    }
}

@end
