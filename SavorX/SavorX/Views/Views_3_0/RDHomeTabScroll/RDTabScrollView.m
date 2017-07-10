//
//  RDTabScrollView.m
//  小热点切换
//
//  Created by 郭春城 on 2017/6/29.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDTabScrollView.h"
#import "RDTabScrollItem.h"

@interface RDTabScrollView ()

@property (nonatomic, strong) NSArray * dataSource;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) RDTabScrollItem * topItem;
@property (nonatomic, strong) RDTabScrollItem * currentItem;
@property (nonatomic, strong) RDTabScrollItem * bottomItem;
@property (nonatomic, strong) RDTabScrollItem * tempScroolItem;

@property (nonatomic, assign) CGPoint topItemCenter;
@property (nonatomic, assign) CGPoint currentItemCenter;
@property (nonatomic, assign) CGPoint bottomItemCenter;

@property (nonatomic, strong) UIPanGestureRecognizer * pan;
@property (nonatomic, strong) UISwipeGestureRecognizer * swipUp;
@property (nonatomic, strong) UISwipeGestureRecognizer * swipDown;

@end

@implementation RDTabScrollView

- (instancetype)initWithFrame:(CGRect)frame modelArray:(NSArray *)array
{
    if (self = [super initWithFrame:frame]) {
        
        self.dataSource = array;
        [self createTabScrollItem];
    }
    return self;
}

- (void)createTabScrollItem
{
    self.backgroundColor = UIColorFromRGB(0xece6de);
    
    CGFloat itemWidth = self.frame.size.width - 40;
    CGFloat itemHeight = itemWidth * 0.646 + 59;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.topItemCenter = CGPointMake(width / 2, height / 2 - 40);
    self.currentItemCenter = CGPointMake(width / 2, height / 2);
    self.bottomItemCenter = CGPointMake(width / 2, height / 2 + 40);
    
    self.topItem = [[RDTabScrollItem alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight) info:[self.dataSource lastObject] index:self.dataSource.count total:self.dataSource.count];
    self.topItem.center = self.topItemCenter;
    [self addSubview:self.topItem];
    
    self.currentItem = [[RDTabScrollItem alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight) info:[self.dataSource firstObject] index:1 total:self.dataSource.count];
    self.currentItem.center = self.currentItemCenter;
    [self addSubview:self.currentItem];
    
    self.bottomItem = [[RDTabScrollItem alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight) info:[self.dataSource objectAtIndex:1] index:2 total:self.dataSource.count];
    self.bottomItem.center = self.bottomItemCenter;
    [self addSubview:self.bottomItem];
    
    self.topItem.transform = CGAffineTransformMakeScale(.9, .9);
    self.bottomItem.transform = CGAffineTransformMakeScale(.9, .9);
    
    [self bringSubviewToFront:self.currentItem];
    self.currentIndex = 0;
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tabScrollTabDidPan:)];
    self.swipUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tabScrollTabDidSwip:)];
    self.swipUp.direction = UISwipeGestureRecognizerDirectionUp;
    self.swipDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tabScrollTabDidSwip:)];
    self.swipDown.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.swipUp requireGestureRecognizerToFail:self.pan];
    [self.swipDown requireGestureRecognizerToFail:self.pan];
    
    [self resetGestureRecognizeWith:self.currentItem];
}

- (void)resetGestureRecognizeWith:(RDTabScrollItem *)item
{
    [item addGestureRecognizer:self.pan];
    [item addGestureRecognizer:self.swipUp];
    [item addGestureRecognizer:self.swipDown];
}

- (void)removeGestureRecognizeWith:(RDTabScrollItem *)item
{
    [item removeGestureRecognizer:self.pan];
    [item removeGestureRecognizer:self.swipUp];
    [item removeGestureRecognizer:self.swipDown];
}

- (void)tabScrollTabDidSwip:(UISwipeGestureRecognizer *)swip
{
    CGFloat height = self.frame.size.height;
    CGFloat maxDistance = height / 2;
    
    [self removeGestureRecognizeWith:self.currentItem];
    
    if (!self.tempScroolItem) {
        self.tempScroolItem = [[RDTabScrollItem alloc] initWithFrame:self.currentItem.frame];
        self.tempScroolItem.center = self.currentItem.center;
    }
    self.tempScroolItem.alpha = .2f;
    [self insertSubview:self.tempScroolItem atIndex:0];
    
    self.topItem.alpha = .5f;
    self.bottomItem.alpha = .5f;
    
    if (swip.direction == UISwipeGestureRecognizerDirectionUp) {
        
        [UIView animateWithDuration:.2f animations:^{
            [self sendSubviewToBack:self.bottomItem];
            [self sendSubviewToBack:self.tempScroolItem];
            
            RDHotelItemModel * imageName1 = [self nextTempInfo];
            [self.tempScroolItem configWithInfo:imageName1 index:[self.dataSource indexOfObject:imageName1]+1 total:self.dataSource.count];
            
            self.topItem.transform = CGAffineTransformMakeScale(.8f, .8f);
            self.topItem.center = CGPointMake(self.topItemCenter.x, self.topItemCenter.y - 40);
            self.topItem.alpha = .2f;
            
            self.currentItem.transform = CGAffineTransformMakeScale(.9f, .9f);
            self.currentItem.center = CGPointMake(self.currentItemCenter.x, self.currentItemCenter.y - maxDistance);
            self.currentItem.alpha = .2f;
            
            self.bottomItem.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self.bottomItem.center = self.currentItemCenter;
            self.bottomItem.alpha = 1.f;
            
            self.tempScroolItem.transform = CGAffineTransformMakeScale(.9f, .9f);
            self.tempScroolItem.center = self.bottomItemCenter;
            self.tempScroolItem.alpha = .5f;
        } completion:^(BOOL finished) {
            [self didScroolEndWithNext];
            [UIView animateWithDuration:.2f animations:^{
                self.topItem.alpha = 1.f;
                self.bottomItem.alpha = 1.f;
                self.currentItem.alpha = 1.f;
                self.topItem.center = self.topItemCenter;
                self.currentItem.center = self.currentItemCenter;
                self.bottomItem.center = self.bottomItemCenter;
                self.topItem.transform = CGAffineTransformMakeScale(.9f, .9f);
                self.currentItem.transform = CGAffineTransformMakeScale(1.f, 1.f);
                self.bottomItem.transform = CGAffineTransformMakeScale(.9f, .9f);
            }];
            [self bringSubviewToFront:self.currentItem];
            [self resetGestureRecognizeWith:self.currentItem];
        }];
    }else{
        [UIView animateWithDuration:.2f animations:^{
            [self sendSubviewToBack:self.bottomItem];
            [self sendSubviewToBack:self.tempScroolItem];
            
            self.topItem.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self.topItem.center = self.currentItemCenter;
            self.topItem.alpha = 1.f;
            
            self.currentItem.transform = CGAffineTransformMakeScale(.9f, .9f);
            self.currentItem.center = CGPointMake(self.bottomItemCenter.x, self.bottomItemCenter.y + maxDistance);
            self.currentItem.alpha = .2f;
            
            self.bottomItem.transform = CGAffineTransformMakeScale(.8f, .8f);
            self.bottomItem.center = CGPointMake(self.bottomItemCenter.x, self.bottomItemCenter.y + 40);
            self.bottomItem.alpha = .2f;
            
            RDHotelItemModel * imageName2 = [self lastTempInfo];
            [self.tempScroolItem configWithInfo:imageName2 index:[self.dataSource indexOfObject:imageName2]+1 total:self.dataSource.count];
            self.tempScroolItem.transform = CGAffineTransformMakeScale(.9f, .9f);
            self.tempScroolItem.center = self.topItemCenter;
            self.tempScroolItem.alpha = .5f;
        } completion:^(BOOL finished) {
            [self didScroolEndWithLast];
            [UIView animateWithDuration:.2f animations:^{
                self.topItem.alpha = 1.f;
                self.bottomItem.alpha = 1.f;
                self.currentItem.alpha = 1.f;
                self.topItem.center = self.topItemCenter;
                self.currentItem.center = self.currentItemCenter;
                self.bottomItem.center = self.bottomItemCenter;
                self.topItem.transform = CGAffineTransformMakeScale(.9f, .9f);
                self.currentItem.transform = CGAffineTransformMakeScale(1.f, 1.f);
                self.bottomItem.transform = CGAffineTransformMakeScale(.9f, .9f);
            }];
            [self bringSubviewToFront:self.currentItem];
            [self resetGestureRecognizeWith:self.currentItem];
        }];
    }
}

- (void)tabScrollTabDidPan:(UIPanGestureRecognizer *)pan
{
    static CGPoint center;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            center = pan.view.center;
            self.topItem.alpha = .5f;
            self.bottomItem.alpha = .5f;
            if (!self.tempScroolItem) {
                self.tempScroolItem = [[RDTabScrollItem alloc] initWithFrame:self.currentItem.frame];
                self.tempScroolItem.center = self.currentItem.center;
            }
            [self insertSubview:self.tempScroolItem atIndex:0];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
            {
                CGPoint point = [pan translationInView:pan.view];
                self.currentItem.center = CGPointMake(center.x, center.y + point.y);
                [self itemDidScroll];
            }
            break;
            
        case UIGestureRecognizerStateFailed:
        {
            [self itemDidEndScroll];
        }
            
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            [self itemDidEndScroll];
        }
            
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            [self itemDidEndScroll];
        }
            
            break;
            
        default:
            break;
    }
}

- (void)itemDidScroll
{
    CGFloat height = self.frame.size.height;
    
    CGFloat rateY = self.currentItem.center.y - height / 2;
    CGFloat tempRateY = rateY;
    if (tempRateY < 0) {
        tempRateY *= -1;
    }
    CGFloat maxDistance = height / 2;
    if (tempRateY <= maxDistance) {
        [self bringSubviewToFront:self.currentItem];
        CGFloat rate = tempRateY / maxDistance;
        CGFloat scaleRate = (1 - 0.9) * rate;
        CGFloat alphaRate = (1 - 0.5) * rate;
        CGFloat centerYRate = 40 * rate;
        
        self.currentItem.transform = CGAffineTransformMakeScale(1 - scaleRate, 1 - scaleRate);
        self.currentItem.alpha = 1 - .8 * rate;
        
        if (rateY > 0) {
            
            [self sendSubviewToBack:self.bottomItem];
            [self sendSubviewToBack:self.tempScroolItem];
            
            self.topItem.transform = CGAffineTransformMakeScale(.9f + scaleRate, .9f + scaleRate);
            self.topItem.alpha = .5f + alphaRate;
            self.topItem.center = CGPointMake(self.topItemCenter.x, self.topItemCenter.y + centerYRate);
            
            self.bottomItem.transform = CGAffineTransformMakeScale(.9f - scaleRate, .9f - scaleRate);
            self.bottomItem.alpha = .5f - alphaRate;
            self.bottomItem.center = CGPointMake(self.bottomItemCenter.x, self.bottomItemCenter.y + centerYRate);
            
            RDHotelItemModel * imageName = [self lastTempInfo];
            [self.tempScroolItem configWithInfo:imageName index:[self.dataSource indexOfObject:imageName]+1 total:self.dataSource.count];
            self.tempScroolItem.transform = CGAffineTransformMakeScale(.8f + scaleRate, .8f + scaleRate);
            self.tempScroolItem.alpha = .2f + .8 * rate;
            self.tempScroolItem.center = CGPointMake(self.topItemCenter.x, self.topItemCenter.y - 30 + centerYRate);
        }else{
            [self sendSubviewToBack:self.topItem];
            [self sendSubviewToBack:self.tempScroolItem];
            
            self.bottomItem.transform = CGAffineTransformMakeScale(.9f + scaleRate, .9f + scaleRate);
            self.bottomItem.alpha = .5f + alphaRate;
            self.bottomItem.center = CGPointMake(self.bottomItemCenter.x, self.bottomItemCenter.y - centerYRate);
            
            self.topItem.transform = CGAffineTransformMakeScale(.9f - scaleRate, .9f - scaleRate);
            self.topItem.alpha = .5f - alphaRate;
            self.topItem.center = CGPointMake(self.topItemCenter.x, self.topItemCenter.y - centerYRate);
            
            RDHotelItemModel * imageName = [self nextTempInfo];
            [self.tempScroolItem configWithInfo:imageName index:[self.dataSource indexOfObject:imageName]+1 total:self.dataSource.count];
            self.tempScroolItem.transform = CGAffineTransformMakeScale(.8f + scaleRate, .8f + scaleRate);
            self.tempScroolItem.alpha = .2f + .8 * rate;
            self.tempScroolItem.center = CGPointMake(self.topItem.center.x, self.bottomItemCenter.y + 30 - centerYRate);
        }
    }else{
        if (rateY > 0) {
            [self bringSubviewToFront:self.topItem];
        }else{
            [self bringSubviewToFront:self.bottomItem];
        }
    }
}

- (void)itemDidEndScroll
{
    [self removeGestureRecognizeWith:self.currentItem];
    CGFloat height = self.frame.size.height;
    
    CGFloat rateY = self.currentItem.center.y - height / 2;
    CGFloat tempRateY = rateY;
    if (tempRateY < 0) {
        tempRateY *= -1;
    }
    CGFloat maxDistance = height / 4;
    if (tempRateY >= maxDistance) {
        if (rateY > 0) {
            [self didScroolEndWithLast];
        }else{
            [self didScroolEndWithNext];
        }
    }else{
        [UIView animateWithDuration:.2f animations:^{
            self.tempScroolItem.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self.tempScroolItem removeFromSuperview];
        }];
    }
    
    [self bringSubviewToFront:self.currentItem];
    
    [UIView animateWithDuration:.2f animations:^{
        self.topItem.alpha = 1.f;
        self.bottomItem.alpha = 1.f;
        self.currentItem.alpha = 1.f;
        self.topItem.center = self.topItemCenter;
        self.currentItem.center = self.currentItemCenter;
        self.bottomItem.center = self.bottomItemCenter;
        self.topItem.transform = CGAffineTransformMakeScale(.9f, .9f);
        self.currentItem.transform = CGAffineTransformMakeScale(1.f, 1.f);
        self.bottomItem.transform = CGAffineTransformMakeScale(.9f, .9f);
    } completion:^(BOOL finished) {
        
    }];
    [self resetGestureRecognizeWith:self.currentItem];
}

- (void)didScroolEndWithLast
{
    RDHotelItemModel * imageName = [self lastTempInfo];
    [self.tempScroolItem configWithInfo:imageName index:[self.dataSource indexOfObject:imageName]+1 total:self.dataSource.count];
    [self.bottomItem removeFromSuperview];
    self.bottomItem = self.currentItem;
    self.currentItem = self.topItem;
    self.topItem = self.tempScroolItem;
    self.tempScroolItem = nil;
    if (self.currentIndex > 0) {
        self.currentIndex--;
    }else{
        self.currentIndex = self.dataSource.count - 1;
    }
}

- (void)didScroolEndWithNext
{
    RDHotelItemModel * imageName = [self nextTempInfo];
    [self.tempScroolItem configWithInfo:imageName index:[self.dataSource indexOfObject:imageName]+1 total:self.dataSource.count];
    [self.topItem removeFromSuperview];
    self.topItem = self.currentItem;
    self.currentItem = self.bottomItem;
    self.bottomItem = self.tempScroolItem;
    self.tempScroolItem = nil;
    if (self.currentIndex < self.dataSource.count - 1) {
        self.currentIndex++;
    }else{
        self.currentIndex = 0;
    }
}

- (RDHotelItemModel *)nextTempInfo
{
    if (self.currentIndex >= self.dataSource.count - 2) {
        if (self.currentIndex == self.dataSource.count - 1) {
            return [self.dataSource objectAtIndex:1];
        }else{
            return [self.dataSource firstObject];
        }
    }
    return [self.dataSource objectAtIndex:self.currentIndex + 2];
}

- (RDHotelItemModel *)lastTempInfo
{
    if (self.currentIndex <= 1) {
        if (self.currentIndex == 0) {
            return [self.dataSource objectAtIndex:self.dataSource.count - 2];
        }else{
            return [self.dataSource lastObject];
        }
    }
    return [self.dataSource objectAtIndex:self.currentIndex - 2];
}

@end
