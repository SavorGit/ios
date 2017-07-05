//
//  HotTopicShareView.m
//  ShareBoard
//
//  Created by 王海朋 on 2017/7/4.
//  Copyright © 2017年 曹雪莹. All rights reserved.
//

#import "HotTopicShareView.h"
#import "ImageWithLabel.h"

#define ScreenWidth			[[UIScreen mainScreen] bounds].size.width
#define SELF_Height		119
#define SHAREVIEW_BGCOLOR   [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1]
#define WINDOW_COLOR        [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define LINE_HEIGHT         74
#define BUTTON_HEIGHT       30
#define LABEL_HEIGHT		45

@interface HotTopicShareView()

//	所有标题
@property (nonatomic, strong) NSArray  *shareBtnTitleArray;
//	所有图片
@property (nonatomic, strong) NSArray  *shareBtnImageArray;
//	整个底部分享面板的 backgroundView
@property (nonatomic, strong) UIView   *bgView;
//	分享面板取消按钮上部的 View
@property (nonatomic, strong) UIView   *topSheetView;
//	头部提示文字Label
@property (nonatomic, strong) UILabel  *proLbl;
@property (nonatomic, strong) UIView   *titleView;
//	头部提示文字
@property (nonatomic, copy)   NSString *protext;
//	所有的分享按钮
@property (nonatomic, copy) NSMutableArray *buttons;

@end

@implementation HotTopicShareView

- (instancetype)initWithShareHeadOprationWith:(NSArray *)titleArray andImageArry:(NSArray *)imageArray andY:(CGFloat)ory {
    
    self = [super init];
    if (self) {
        
        _shareBtnTitleArray = titleArray;
        _shareBtnImageArray = imageArray;
        _protext = @"分享到";
        
        self.frame = CGRectMake(0, ory, ScreenWidth, SELF_Height);
        //	背景，带灰度
        self.backgroundColor = [UIColor cyanColor];
        //	可点击
        self.userInteractionEnabled = YES;
        //	加载分享面板
        [self loadUIConfig];
    }
    return self;
}

/**
 加载自定义视图，按钮的tag依次为（200 + i）
 */
- (void)loadUIConfig {
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.topSheetView];
    [self.bgView addSubview:self.titleView];
    
    //	按钮
    for (NSInteger i = 0; i < self.shareBtnTitleArray.count; i++) {
        
        CGFloat x = self.bgView.bounds.size.width / 4 * ( i % 4);
        CGFloat y = LABEL_HEIGHT + (i / 4) * LINE_HEIGHT;
        CGFloat w = self.bgView.bounds.size.width / 4;
        CGFloat h = 70;
        
        CGRect frame =  CGRectMake(x, y, w, h);
        ImageWithLabel *item = [ImageWithLabel imageLabelWithFrame:frame Image:[UIImage imageNamed:self.shareBtnImageArray[i]] LabelText:@""];
        item.labelOffsetY = 0;
        
        item.tag = 200 + i;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClick:)];
        [item addGestureRecognizer:tapGes];
        [self.topSheetView addSubview:item];
        
        [self.buttons addObject:item];
    }
}



#pragma mark --------------------------- Selector
/**
 按钮点击
@param tapGes 手势
 */
- (void)itemClick:(UITapGestureRecognizer *)tapGes {
    if (self.btnClick) {
        
        self.btnClick(tapGes.view.tag - 200);
    }
}

#pragma mark --------------------------- getter
- (UIView *)bgView {
    
    if (_bgView == nil) {
        
        _bgView = [[UIView alloc] init];
        //根据图标个数，计算行数，计算 backgroundView 的高度
        NSInteger index;
        if (_shareBtnTitleArray.count % 4 == 0) {
            
            index = _shareBtnTitleArray.count / 4;
            
        } else {
            
            index = _shareBtnTitleArray.count / 4 + 1;
        }
        _bgView.frame = CGRectMake(0, 0, ScreenWidth, BUTTON_HEIGHT + (_protext.length == 0 ? 0 : 45) + LINE_HEIGHT * index);
    }
    return _bgView;
}

- (UIView *)topSheetView {
    
    if (_topSheetView == nil) {
        
        _topSheetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_bgView.frame), CGRectGetHeight(_bgView.frame) - BUTTON_HEIGHT)];
        _topSheetView.backgroundColor = [UIColor clearColor];
    }
    return _topSheetView;
}

- (UIView *)titleView
{
    if (_titleView == nil) {
        
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_bgView.frame), LABEL_HEIGHT)];
        UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(0, 22, ([UIScreen mainScreen].bounds.size.width - 60)/2, 1)];
        leftLine.backgroundColor = [UIColor redColor];
        [_titleView addSubview:leftLine];
        
        _proLbl = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 60)/2, 0, 60, LABEL_HEIGHT)];
        _proLbl.text = _protext;
        _proLbl.textColor = [UIColor blackColor];
        _proLbl.backgroundColor = [UIColor clearColor];
        _proLbl.textAlignment = NSTextAlignmentCenter;
        [_titleView addSubview:_proLbl];
        
        UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 60)/2 + 60, 22, ([UIScreen mainScreen].bounds.size.width - 60)/2, 1)];
        rightLine.backgroundColor = [UIColor redColor];
        [_titleView addSubview:rightLine];
    }
    return _titleView;
}

- (NSArray *)buttons {
    
    if (!_buttons) {
        _buttons = [NSMutableArray arrayWithCapacity:5];
    }
    return _buttons;
}

@end
