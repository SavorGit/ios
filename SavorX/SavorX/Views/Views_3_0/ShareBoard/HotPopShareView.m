//
//  HotPopShareView.m
//  ShareBoard
//
//  Created by 王海朋 on 2017/7/10.
//  Copyright © 2017年 曹雪莹. All rights reserved.
//

#import "HotPopShareView.h"
#import "ImageWithLabel.h"
#import "UMCustomSocialManager.h"
#import "GCCKeyChain.h"

#define ScreenWidth			[[UIScreen mainScreen] bounds].size.width
#define ScreenHeight		[[UIScreen mainScreen] bounds].size.height
#define SHAREVIEW_BGCOLOR   [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1]
#define WINDOW_COLOR        [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define ANIMATE_DURATION    0.25f
#define LINE_HEIGHT         84
#define BUTTON_HEIGHT       50
#define NORMAL_SPACE        7
#define LABEL_HEIGHT		30
#define BGVIEWDISTANCE		55

@interface HotPopShareView ()

//	所有标题
@property (nonatomic, strong) NSArray  *shareBtnTitleArray;
//	所有图片
@property (nonatomic, strong) NSArray  *shareBtnImageArray;
//	整个底部分享面板
@property (nonatomic, strong) UIView   *bgView;
//	分享面板取消按钮上部的 View
@property (nonatomic, strong) UIView   *topSheetView;
//	取消按钮
@property (nonatomic, strong) UIButton *cancelBtn;
//	所有的分享按钮
@property (nonatomic, copy) NSMutableArray *buttons;

@property(nonatomic ,assign) NSInteger startIndex;

@property(nonatomic ,strong) CreateWealthModel *model;

@property(nonatomic ,strong) UIViewController *VC;

@end

@implementation HotPopShareView

- (instancetype)initWithModel:(CreateWealthModel *)model andVC:(UIViewController *)VC {
    
    self = [super init];
    if (self) {
        
        self.model = model;
        self.VC = VC;
        //初始化数据
        [self creatDatas];
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        //背景蒙版，带灰度
        self.backgroundColor = WINDOW_COLOR;
        //加载分享面板
        [self loadUIConfig];
    }
    return self;
}

- (void)creatDatas{
    
    BOOL hadInstalledWeixin = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
    BOOL hadInstalledQQ = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]];
    
    NSMutableArray *titlearr = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:5];
    
    int startIndex = 0;
    
    if (hadInstalledWeixin) {
        [titlearr addObjectsFromArray:@[@"微信", @"朋友圈"]];
        [imageArr addObjectsFromArray:@[@"WeChat",@"friends"]];
    } else {
        startIndex += 2;
    }
    
    if (hadInstalledQQ) {
        [titlearr addObjectsFromArray:@[@"QQ", @"QQ空间"]];
        [imageArr addObjectsFromArray:@[@"qq",@"fx_Zone"]];
    } else {
        startIndex += 2;
    }
    
    //    [titlearr addObjectsFromArray:@[@"微信", @"朋友圈"]];
    //    [imageArr addObjectsFromArray:@[@"WeChat",@"friends"]];
    //
    //    [titlearr addObjectsFromArray:@[@"QQ", @"QQ空间"]];
    //    [imageArr addObjectsFromArray:@[@"qq",@"qq"]];
    
    [titlearr addObjectsFromArray:@[@"微博"]];
    [imageArr addObjectsFromArray:@[@"weibo"]];
    
    [titlearr addObjectsFromArray:@[@"微信收藏"]];
    [imageArr addObjectsFromArray:@[@"fx_wxsc"]];
    
    [titlearr addObjectsFromArray:@[@"复制链接"]];
    [imageArr addObjectsFromArray:@[@"fuzhilianjie"]];
    
    _shareBtnTitleArray = titlearr;
    _shareBtnImageArray = imageArr;
}

//加载自定义视图，按钮的tag依次为（200 + i）
- (void)loadUIConfig {
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.topSheetView];
    [self.bgView addSubview:self.cancelBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xece6de);
    [_bgView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 1));
        make.top.mas_equalTo(_cancelBtn.mas_top).offset(-1);
        make.left.mas_equalTo(0);
    }];

    //按钮
    for (NSInteger i = 0; i < self.shareBtnTitleArray.count; i++) {
        
        CGFloat x = self.bgView.bounds.size.width / 4 * ( i % 4);
        CGFloat y = LABEL_HEIGHT + (i / 4) * LINE_HEIGHT;
        CGFloat w = self.bgView.bounds.size.width / 4;
        CGFloat h = 80;
        
        CGRect frame =  CGRectMake(x, y, w, h);
        ImageWithLabel *item = [ImageWithLabel imageLabelWithFrame:frame Image:[UIImage imageNamed:self.shareBtnImageArray[i]] LabelText:self.shareBtnTitleArray[i]];
        item.labelOffsetY = 10;
        item.tag = 200 + i;
        [item setLabelColor:UIColorFromRGB(0x595757)];
        [item setLabelFont:kPingFangLight(12)];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClick:)];
        [item addGestureRecognizer:tapGes];
        [self.topSheetView addSubview:item];
        [self.buttons addObject:item];
        
        item.backgroundColor = [UIColor clearColor];
    }
    //弹出
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        self.bgView.frame = CGRectMake(0, ScreenHeight - CGRectGetHeight(self.bgView.frame), ScreenWidth, CGRectGetHeight(self.bgView.frame));
    }];
}

#pragma mark --- Selector


#pragma mark ---取消
- (void)tappedCancel {
    
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.bgView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark ---分享按钮点击
- (void)itemClick:(UITapGestureRecognizer *)tapGes {
    
    [self tappedCancel];
    NSInteger btnTag = tapGes.view.tag - 200;
    switch (btnTag + _startIndex) {
        case 0: {
            // 微信
            [[UMCustomSocialManager defaultManager] sharedToPlatform:UMSocialPlatformType_WechatSession andController:self.VC withModel:self.model];
            
        }
            break;
        case 1: {
            // 微信朋友圈
            [[UMCustomSocialManager defaultManager] sharedToPlatform:UMSocialPlatformType_WechatTimeLine andController:self.VC withModel:self.model];
        }
            break;
        case 2: {
            // QQ
            [[UMCustomSocialManager defaultManager] sharedToPlatform:UMSocialPlatformType_QQ andController:self.VC withModel:self.model];
            
        }
            break;
        case 3: {
            // QQ空间
            [[UMCustomSocialManager defaultManager] sharedToPlatform:UMSocialPlatformType_Qzone andController:self.VC withModel:self.model];
        }
            break;
        case 4: {
            // 微博
            [[UMCustomSocialManager defaultManager] sharedToPlatform:UMSocialPlatformType_Sina andController:self.VC withModel:self.model];
            
        }
            break;
        case 5: {
            // 微信收藏
            [[UMCustomSocialManager defaultManager] sharedToPlatform:UMSocialPlatformType_WechatFavorite andController:self.VC withModel:self.model];
            
        }
            break;
        case 6: {
            // 复制链接
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.model.contentURL;
            [MBProgressHUD showTextHUDwithTitle:@"复制成功" delay:1.5f];
            
        }
            break;
        default:
            break;
    }
}

#pragma mark --- bgView
- (UIView *)bgView {
    
    if (_bgView == nil) {
        
        _bgView = [[UIView alloc] init];
        
        //	根据图标个数，计算行数，计算 backgroundView 的高度
        NSInteger index;
        if (_shareBtnTitleArray.count % 4 == 0) {
            
            index = _shareBtnTitleArray.count / 4;
            
        } else {
            
            index = _shareBtnTitleArray.count / 4 + 1;
            
        }
        _bgView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, BGVIEWDISTANCE + BUTTON_HEIGHT + LINE_HEIGHT * index);
        _bgView.backgroundColor = UIColorFromRGB(0xf6f3f0);
    }
    return _bgView;
}

- (UIView *)topSheetView {
    
    if (_topSheetView == nil) {
        
        _topSheetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_bgView.frame), CGRectGetHeight(_bgView.frame) - BUTTON_HEIGHT)];
        _topSheetView.backgroundColor = [UIColor whiteColor];
        _topSheetView.alpha = 0.8;
    }
    return _topSheetView;
}

- (UIButton *)cancelBtn {
    
    if (_cancelBtn == nil) {
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(0, CGRectGetHeight(_bgView.frame) - BUTTON_HEIGHT, CGRectGetWidth(_bgView.frame), BUTTON_HEIGHT);
        //	取消按钮
        [_cancelBtn setTitle:@"取消分享" forState:UIControlStateNormal];
        _cancelBtn.backgroundColor = UIColorFromRGB(0xfefbf8);
        [_cancelBtn setTitleColor:UIColorFromRGB(0x444444) forState:UIControlStateNormal];
        [_cancelBtn.titleLabel setFont:kPingFangRegular(15)];
        //	点击按钮，取消，收起面板，移除视图
        [_cancelBtn addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}


- (NSArray *)buttons {
    
    if (!_buttons) {
        _buttons = [NSMutableArray arrayWithCapacity:5];
    }
    return _buttons;
}

#pragma mark --- User-Defined

- (void)setCancelBtnColor:(UIColor *)cancelBtnColor {
    
    [_cancelBtn setTitleColor:cancelBtnColor forState:UIControlStateNormal];
}

- (void)setOtherBtnColor:(UIColor *)otherBtnColor {
    
    for (id res in _bgView.subviews) {
        
        if ([res isKindOfClass:[UIButton class]]) {
            
            UIButton *button = (UIButton *)res;
            [button setTitleColor:otherBtnColor forState:UIControlStateNormal];
        }
    }
}

- (void)setOtherBtnFont:(NSInteger)otherBtnFont {
    
    for (id res in _bgView.subviews) {
        
        if ([res isKindOfClass:[UIButton class]]) {
            
            UIButton *button = (UIButton *)res;
            button.titleLabel.font = [UIFont systemFontOfSize:otherBtnFont];
        }
    }
}

- (void)setCancelBtnFont:(NSInteger)cancelBtnFont {
    
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:cancelBtnFont];
}

@end
