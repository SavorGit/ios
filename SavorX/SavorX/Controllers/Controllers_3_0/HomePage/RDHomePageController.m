//
//  RDHomePageController.m
//  小热点3.0
//
//  Created by 郭春城 on 2017/6/16.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDHomePageController.h"
#import "RDHomeScreenViewController.h"

@implementation RDHomePageController

- (instancetype)init
{
    NSArray * vcArray = @[[UIViewController class],[UIViewController class],[UIViewController class]];
    NSArray * titleArray = @[@"创富", @"生活", @"专题"];
    
    if (self = [super initWithViewControllerClasses:vcArray andTheirTitles:titleArray]) {
        [self configPageController];
    }
    return self;
}

- (void)insertViewController
{
    NSInteger index = self.selectIndex;
    
    //改变title数组
    NSMutableArray * currentTitles = [NSMutableArray arrayWithArray:self.titles];
    [currentTitles insertObject:@"插入" atIndex:0];
    self.titles = [NSArray arrayWithArray:currentTitles];
    
    //改变控制器数组
    NSMutableArray * currentViewControllerClasses = [NSMutableArray arrayWithArray:self.viewControllerClasses];
    [currentViewControllerClasses insertObject:[RDHomeScreenViewController class] atIndex:0];
    self.viewControllerClasses = [NSArray arrayWithArray:currentViewControllerClasses];
    
    //改变子控制器frame数组
    if (self.childViewFrames.count > 0) {
        CGRect frame = [[self.childViewFrames lastObject] CGRectValue];
        frame.origin.x += frame.size.width;
        [self.childViewFrames addObject:[NSValue valueWithCGRect:frame]];
    }
    
    //改变缓存控制器数组
    RDHomeScreenViewController * first = [[RDHomeScreenViewController alloc] init];
    NSMutableArray * cacheArray = [NSMutableArray new];
    for (NSInteger i = 0; i < self.viewControllerClasses.count; i++) {
        if ([self.memCache objectForKey:@(i)]) {
            [cacheArray addObject:[self.memCache objectForKey:@(i)]];
        }
    }
    [cacheArray insertObject:first atIndex:0];
    for (NSInteger i = 0; i < cacheArray.count; i++) {
        [self.memCache setObject:[cacheArray objectAtIndex:i] forKey:@(i)];
    }
    
    //改变预加载控制器数组
    NSMutableDictionary * tempDisplayVC = [NSMutableDictionary dictionaryWithDictionary:self.displayVC];
    [self.displayVC removeAllObjects];
    for (NSInteger i = 0; i < self.viewControllerClasses.count; i++) {
        if ([tempDisplayVC objectForKey:@(i)]) {
            [self.displayVC setObject:[tempDisplayVC objectForKey:@(i)] forKey:@(i+1)];
        }
    }
    [self.displayVC setObject:first forKey:@(0)];
    
    //注意：一定要先修改数据再对视图进行操作，否则将引起scrollView在属性发生改变的时候调用代理，会通过改变前的数据源进行视图配置，导致改变后部分视图消失或者错乱
    //改变scrollView所有控制器视图frame
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width + self.view.frame.size.width, self.scrollView.contentSize.height);
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x + self.scrollView.frame.size.width, 0);
    for (UIView * view in self.scrollView.subviews) {
        CGRect frame = view.frame;
        frame.origin.x += frame.size.width;
        view.frame = frame;
    }
    
    first.view.frame = [[self.childViewFrames objectAtIndex:0] CGRectValue];
    
    [self.scrollView addSubview:first.view];
    [self addChildViewController:first];
    [first didMoveToParentViewController:self];
    
    self.menuViewContentMargin = ([UIScreen mainScreen].bounds.size.width - (self.menuItemWidth + 10) * 4) / 2;
    [self wm_resetMenuViewWithNodelegateWithIndex:index + 1];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"移除" style:UIBarButtonItemStyleDone target:self action:@selector(removeViewController)];
}

- (void)removeViewController
{
    int index = self.selectIndex;
    
    //改变缓存控制器数组
    NSMutableArray * cacheArray = [NSMutableArray new];
    for (NSInteger i = 0; i < self.viewControllerClasses.count; i++) {
        if ([self.memCache objectForKey:@(i)]) {
            if (i == 0) {
                
            }else{
                [cacheArray addObject:[self.memCache objectForKey:@(i)]];
            }
        }
    }
    
    [self.memCache removeAllObjects];
    for (NSInteger i = 0; i < cacheArray.count; i++) {
        [self.memCache setObject:[cacheArray objectAtIndex:i] forKey:@(i)];
    }
    
    //改变预加载控制器数组
    NSMutableDictionary * tempDisplayVC = [NSMutableDictionary dictionaryWithDictionary:self.displayVC];
    [self.displayVC removeAllObjects];
    for (NSInteger i = 0; i < self.viewControllerClasses.count; i++) {
        if ([tempDisplayVC objectForKey:@(i)]) {
            if (i != 0) {
                [self.displayVC setObject:[tempDisplayVC objectForKey:@(i)] forKey:@(i-1)];
            }
        }
    }
    
    //改变子控制器frame数组
    if (self.childViewFrames.count > 0) {
        [self.childViewFrames removeLastObject];
    }
    
    //移除的时候一定先处理缓存控制器再处理数据源，否则会造成移除数据源之后，遍历缓存控制器时会遗漏最后一个
    //改变title数组
    NSMutableArray * currentTitles = [NSMutableArray arrayWithArray:self.titles];
    [currentTitles removeObjectAtIndex:0];
    self.titles = [NSArray arrayWithArray:currentTitles];
    
    //改变控制器数组
    NSMutableArray * currentViewControllerClasses = [NSMutableArray arrayWithArray:self.viewControllerClasses];
    [currentViewControllerClasses removeObjectAtIndex:0];
    self.viewControllerClasses = [NSArray arrayWithArray:currentViewControllerClasses];
    
    for (UIViewController * vc in self.childViewControllers) {
        if ([vc isKindOfClass:[RDHomeScreenViewController class]]) {
            [vc removeFromParentViewController];
            break;
        }
    }
    
    if (index == 0) {
        for (UIView * view in self.scrollView.subviews) {
            CGRect frame = view.frame;
            frame.origin.x -= frame.size.width;
            [UIView animateWithDuration:.3f animations:^{
                view.frame = frame;
            } completion:^(BOOL finished) {
                if (view.frame.origin.x < view.frame.size.width / 2.f * -1) {
                    [view removeFromSuperview];
                }
            }];
        }
    }else{
        for (UIView * view in self.scrollView.subviews) {
            CGRect frame = view.frame;
            frame.origin.x -= frame.size.width;
            view.frame = frame;
            if (view.frame.origin.x < view.frame.size.width / 2.f * -1) {
                [view removeFromSuperview];
            }
        }
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x - self.scrollView.frame.size.width, 0);
        //改变scrollView所有控制器视图frame
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width - self.view.frame.size.width, self.scrollView.contentSize.height);
    
    self.menuViewContentMargin = ([UIScreen mainScreen].bounds.size.width - (self.menuItemWidth + 10) * 3) / 2;
    [self.menuView reload];
    if (index > 0) {
        self.selectIndex = index - 1;
    }
    
    [self resetCurrentViewController:[self.displayVC objectForKey:@(self.selectIndex)]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"插入" style:UIBarButtonItemStyleDone target:self action:@selector(insertViewController)];
}

- (void)configPageController
{    
    self.preloadPolicy = WMPageControllerPreloadPolicyNeighbour;
    self.menuViewStyle = WMMenuViewStyleLine;
    self.titleSizeNormal = 14;
    self.titleSizeSelected = 17;
    self.titleColorNormal = [UIColor grayColor];
    self.titleColorSelected = [UIColor colorWithRed:143.f/255.f green:46.f/255.f blue:64.f/255.f alpha:1];
    
    self.menuItemWidth = [UIScreen mainScreen].bounds.size.width / 8;
    self.menuViewContentMargin = ([UIScreen mainScreen].bounds.size.width - (self.menuItemWidth + 10) * 3) / 2;
    self.menuBGColor = [UIColor colorWithRed:237.f/255.f green:230.f/255.f blue:222.f/255.f alpha:.3f];
    self.menuHeight = 50;
    
    self.progressColor = [UIColor colorWithRed:143.f/255.f green:46.f/255.f blue:64.f/255.f alpha:1];
    self.progressWidth = 34;
    self.progressViewBottomSpace = 13;
    
    self.pageAnimatable = YES;
    
    [self createCustomUI];
}

- (void)createCustomUI
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"插入" style:UIBarButtonItemStyleDone target:self action:@selector(insertViewController)];
}

@end
