//
//  ImageAtlasScrollView.h
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/7.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JT3DScrollViewEffect) {
    JT3DScrollViewEffectNone,
    JT3DScrollViewEffectTranslation,
    JT3DScrollViewEffectDepth,
    JT3DScrollViewEffectCarousel,
    JT3DScrollViewEffectCards
};

@interface ImageAtlasScrollView : UIScrollView

@property (nonatomic) JT3DScrollViewEffect effect;

@property (nonatomic) CGFloat angleRatio;

@property (nonatomic) CGFloat rotationX;
@property (nonatomic) CGFloat rotationY;
@property (nonatomic) CGFloat rotationZ;

@property (nonatomic) CGFloat translateX;
@property (nonatomic) CGFloat translateY;

- (NSUInteger)currentPage;

- (void)loadNextPage:(BOOL)animated;
- (void)loadPreviousPage:(BOOL)animated;
- (void)loadPageIndex:(NSUInteger)index animated:(BOOL)animated;

@end
