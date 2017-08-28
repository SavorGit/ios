//
//  RDHomePageController.m
//  小热点3.0
//
//  Created by 郭春城 on 2017/6/16.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDHomePageController.h"
#import "RDHomeScreenViewController.h"
#import "UIViewController+LGSideMenuController.h"
#import "RealCreateWealthViewController.h"
#import "SpecialTopicViewController.h"
#import "HSGetSpecialRequest.h"
#import "RDHomeStatusView.h"
#import "LiveViewController.h"
#import "GCCDLNA.h"
#import "WebViewController.h"
#import "ImageTextDetailViewController.h"
#import "ImageArrayViewController.h"
#import "RDLogStatisticsAPI.h"

#import "SpecialListViewController.h"

@interface RDHomePageController ()

@property (nonatomic, copy) NSString * specialTitle;
@property (nonatomic, assign) BOOL isInsertVC;

@end

@implementation RDHomePageController

- (instancetype)init
{
    NSArray * vcArray = @[[RealCreateWealthViewController class],[LiveViewController class],[SpecialTopicViewController class]];
    NSArray * titleArray = @[RDLocalizedString(@"RDString_CreateWealth"), RDLocalizedString(@"RDString_Live"), RDLocalizedString(@"RDString_SpecialTopic")];
    
    if (self = [super initWithViewControllerClasses:vcArray andTheirTitles:titleArray]) {
        [self configPageController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createNavigationTitleView];
    [self checkSpecialTopic];
    [self addNotificationCenter];
    [self handleLaunchWork];
}

- (void)handleLaunchWork
{
    if ([GlobalData shared].is3DTouchEnable) {
        
        if ([[GlobalData shared].shortcutItem.type isEqualToString:@"3dtouch.connet"]) {
            
            if ([GlobalData shared].networkStatus == RDNetworkStatusReachableViaWiFi) {
                [[GCCDLNA defaultManager] startSearchPlatform];
            }
            
            [[RDHomeStatusView defaultView] scanQRCode];
            
        }else if ([[GlobalData shared].shortcutItem.type isEqualToString:@"3dtouch.screen"]) {
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
    
    if ([GlobalData shared].isLaunchedByNotification) {
        [self didReceiveRemoteNotification:[GlobalData shared].launchModel];
    }
}

//收到节目的推送，跳转至相关的页面
- (void)didReceiveRemoteNotification:(CreateWealthModel *)model
{
    NSInteger categoryID = model.categoryId;
    [SAVORXAPI postUMHandleWithContentId:model.artid withType:readHandle];
    //如果不是绑定状态
    if (model.type == 3 || model.type == 4) {
        WebViewController * web = [[WebViewController alloc] init];
        web.model = model;
        web.categoryID = categoryID;
        
        [self.navigationController pushViewController:web animated:YES];
        [SAVORXAPI postUMHandleWithContentId:@"home_click_video" key:nil value:nil];
    }else if (model.type == 2) {
        ImageArrayViewController * vc = [[ImageArrayViewController alloc] initWithCategoryID:0 model:model];
        
        vc.parentNavigationController = self.navigationController;
        float version = [UIDevice currentDevice].systemVersion.floatValue;
        if (version < 8.0) {
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {;
            vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:vc animated:NO completion:^{
            
        }];
        
        [self.navigationController pushViewController:vc animated:YES];
        [SAVORXAPI postUMHandleWithContentId:@"home_click_article" key:nil value:nil];
    }else{
        ImageTextDetailViewController * article = [[ImageTextDetailViewController alloc] init];
        article.imgTextModel = model;
        
        [self.navigationController pushViewController:article animated:YES];
        [SAVORXAPI postUMHandleWithContentId:@"home_click_article" key:nil value:nil];
        
    }
}

- (void)createNavigationTitleView
{
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 25)];
    [button setImage:[UIImage imageNamed:@"logo_biaoti"] forState:UIControlStateNormal];
    [button setTitle:RDLocalizedString(@"RDString_APPName") forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xece6de) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 7)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
    self.navigationItem.titleView = button;
    button.userInteractionEnabled = NO;
}

- (void)checkSpecialTopic
{
    HSGetSpecialRequest * request = [[HSGetSpecialRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSString * title = [[response objectForKey:@"result"] objectForKey:@"specialName"];
        if (!isEmptyString(title)) {
            [self autoSpecialTitleWith:title];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)didFoundBox
{
    [self insertViewController];
}

- (void)disconnectBox
{
    [self removeViewController];
}

- (void)autoSpecialTitleWith:(NSString *)title
{
    self.specialTitle = title;
    
    if (self.titles) {
        NSMutableArray * titleArray = [NSMutableArray arrayWithArray:self.titles];
        [titleArray removeLastObject];
        [titleArray addObject:title];
        self.titles = [NSArray arrayWithArray:titleArray];
        
        CGFloat width = [self.specialTitle boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size.width;
        
        [self updateTitle:title andWidth:width atIndex:self.titles.count - 1];
        [self.menuView updateBadgeViewAtIndex:self.titles.count - 1];
        
        if (self.progressViewWidths) {
            NSMutableArray * array = [NSMutableArray arrayWithArray:self.progressViewWidths];
            [array removeLastObject];
            [array addObject:@(width)];
            self.progressViewWidths = [NSArray arrayWithArray:array];
        }
        [self autoItemMargin];
    }
}

- (void)insertViewController
{
    if (self.isInsertVC) {
        return;
    }
    
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        [Helper interfaceOrientation:UIInterfaceOrientationPortrait];
    }
    
    self.itemMargin = 12;
    
    [self setScrollEnable:NO];
    
    self.isInsertVC = YES;
    
    NSInteger index = self.selectIndex;
    
    //改变title数组
    NSMutableArray * currentTitles = [NSMutableArray arrayWithArray:self.titles];
    [currentTitles insertObject:RDLocalizedString(@"RDString_Screen") atIndex:0];
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
    
    [self wm_resetMenuViewWithNodelegateWithIndex:index + 1];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [self autoItemMargin];
    [self.menuView updateBadgeViewAtIndex:self.titles.count - 1];
    
    [self setScrollEnable:YES];
}

- (void)removeViewController
{
    if (!self.isInsertVC) {
        return;
    }
    
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        [Helper interfaceOrientation:UIInterfaceOrientationPortrait];
    }
    
    self.itemMargin = 20;
    
    [self setScrollEnable:NO];
    
    self.isInsertVC = NO;
    
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
    
    [self.menuView reload];
    if (index > 0) {
        self.selectIndex = index - 1;
    }
    [[RDHomeStatusView defaultView] removeFromSuperview];
    [self resetCurrentViewController:[self.displayVC objectForKey:@(self.selectIndex)]];
    [self autoItemMargin];
    [self.menuView updateBadgeViewAtIndex:self.titles.count - 1];
    
    [self setScrollEnable:YES];
}

- (void)configPageController
{    
    self.preloadPolicy = WMPageControllerPreloadPolicyNear;
    self.menuViewStyle = WMMenuViewStyleLine;
    self.titleSizeNormal = 14;
    self.titleSizeSelected = 17;
    self.titleColorNormal = [UIColor grayColor];
    self.titleColorSelected = kThemeColor;
    
    self.menuItemWidth = 50;
    self.menuBGColor = kThemeColor;
    self.menuHeight = 50;
    self.itemMargin = 15;
    [self autoItemMargin];
    
    self.progressColor = [UIColor colorWithRed:143.f/255.f green:46.f/255.f blue:64.f/255.f alpha:1];
    self.progressWidth = 30;
    self.progressViewBottomSpace = 13;
    
    self.pageAnimatable = YES;
    self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
    
    [self createCustomUI];
}

- (void)autoItemMargin
{
    self.menuViewContentMargin = (kMainBoundsWidth - (self.menuItemWidth + self.itemMargin) * self.titles.count - self.itemMargin) / 2;
    if (!isEmptyString(self.specialTitle)) {
        CGSize size = [self.specialTitle boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size;
        CGFloat width = size.width;
        self.menuViewContentMargin = (kMainBoundsWidth - (self.menuItemWidth + self.itemMargin) * self.titles.count - self.itemMargin - 20 - (width - self.menuItemWidth)) / 2;
    }
}

- (void)createCustomUI
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    [button setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
    [button addTarget:self action:@selector(openLeftDrawer:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)openLeftDrawer:(id)sender
{
    [self showLeftViewAnimated:sender];
}

- (UIView *)menuView:(WMMenuView *)menu badgeViewAtIndex:(NSInteger)index
{
    if (index == self.titles.count - 1) {
        CGFloat width = self.menuItemWidth;
        if (!isEmptyString(self.specialTitle)) {
            CGSize size = [self.specialTitle boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size;
            width = size.width;
            UIImageView * view = [[UIImageView alloc] initWithFrame:CGRectMake(width - 10 - self.specialTitle.length * .5, 12, 24, 12)];
            [view setImage:[UIImage imageNamed:@"zhuanti"]];
            return view;
        }
    }
    return nil;
}

- (CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index
{
    if (index == self.titles.count - 1) {
        if (!isEmptyString(self.specialTitle)) {
            CGSize size = [self.specialTitle boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size;
            
            return size.width;
        }
    }
    return 40;
}

- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info
{
    if ([viewController isKindOfClass:[SpecialTopicViewController class]]) {
        
        [RDLogStatisticsAPI RDPageLogCategoryID:@"103" volume:@"index"];
        SpecialTopicViewController * vc = (SpecialTopicViewController *)viewController;
        [vc showSelfAndCreateLog];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStyleDone target:self action:@selector(shareSpecialTopic)];
        
    }else{
        
        self.navigationItem.rightBarButtonItem = nil;
        if ([viewController isKindOfClass:[RealCreateWealthViewController class]]) {
            
            [RDLogStatisticsAPI RDPageLogCategoryID:@"101" volume:@"index"];
            RealCreateWealthViewController * vc = (RealCreateWealthViewController *)viewController;
            [vc showSelfAndCreateLog];
            
        }else if ([viewController isKindOfClass:[LiveViewController class]]){
            
            [RDLogStatisticsAPI RDPageLogCategoryID:@"102" volume:@"index"];
            LiveViewController * vc = (LiveViewController *)viewController;
            [vc showSelfAndCreateLog];
            
        }
    }
}

- (void)shareSpecialTopic
{
    SpecialListViewController * specialList = [[SpecialListViewController alloc] init];
    [self.navigationController pushViewController:specialList animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.sideMenuController.leftViewSwipeGestureEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.sideMenuController.leftViewSwipeGestureEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)addNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFoundBox) name:RDDidFoundHotelIdNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectBox) name:RDDidNotFoundSenceNotification object:nil];
}

- (void)removeNotificationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidFoundHotelIdNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RDDidNotFoundSenceNotification object:nil];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (BOOL)prefersStatusBarHidden
{
//    if ([GlobalData shared].isImageAtlas) {
//        return [GlobalData shared].isImageAtlasHiddenTop;
//    }
    
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([GlobalData shared].isImageAtlas == NO) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;;
}

- (void)dealloc
{
    [self removeViewController];
}

@end
