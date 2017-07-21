//
//  BaseViewController.m
//  SavorX
//
//  Created by lijiawei on 16/12/9.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import "RDLoadingView.h"

@interface BaseViewController ()<NoDataViewDelegate,NoNetWorkViewDelegate>{
    
    /**无数据视图**/
    NoDataView*         _noDataView;
    /**无网视图**/
    NoNetWorkView*      _noNetWorkView;
    /**Loading视图**/
    RDLoadingView*      _loadingView;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = VCBackgroundColor;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    [self setNavBackArrowWithWidth:40];
    // Do any additional setup after loading the view.
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}

+ (instancetype)viewController{
    BaseViewController *ctrl = [[self alloc] init];
    ctrl.hidesBottomBarWhenPushed = YES;
    return ctrl;
}

- (void)setupViews
{
}
- (void)setupDatas
{
}

- (void)setNavBackArrow {
    [self setNavBackArrowWithWidth:40];
}

- (void)setNavBackArrowWithWidth:(CGFloat)width {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    [button setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, width, 44);
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
    [button addTarget:self action:@selector(navBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 *  显示无数据视图
 *
 *  @param frame 内容显示的frame
 */
- (void)showNoDataViewWithFrame:(CGRect)frame{
    if (!_noDataView) {
        _noDataView = [NoDataView loadFromXib];
        _noDataView.delegate = self;
    }
    [_noDataView showNoDataViewController:self noDataType:kNoDataType_Default];
    [_noDataView setContentViewFrame:frame];
}

- (void)showNoDataViewWithFrame:(CGRect)frame noDataType:(NODataType)type{
    if (!_noDataView) {
        _noDataView = [NoDataView loadFromXib];
        _noDataView.delegate = self;
    }
    [_noDataView showNoDataViewController:self noDataType:type];
    [_noDataView setContentViewFrame:frame];
}

- (void)showNoDataViewInView:(UIView *)superView{
    if (!_noDataView) {
        _noDataView = [NoDataView loadFromXib];
        _noDataView.delegate = self;
    }
    [_noDataView showNoDataView:superView noDataType:kNoDataType_Default];
}
- (void)showNoDataViewInView:(UIView *)superView noDataString:(NSString *)noDataString
{
    if (!_noDataView) {
        _noDataView = [NoDataView loadFromXib];
        _noDataView.delegate = self;
    }
    [_noDataView showNoDataView:superView noDataString:noDataString];
}

- (void)showNoDataViewBelowView:(UIView *)view noDataType:(NODataType)type
{
    if (!_noDataView) {
        _noDataView = [NoDataView loadFromXib];
        _noDataView.delegate = self;
    }
    [_noDataView showNoDataBelowView:view noDataType:type];
}

-(void)showNoDataViewInView:(UIView*)superView noDataType:(NODataType)type{
    
    if (!_noDataView) {
        _noDataView = [NoDataView loadFromXib];
        _noDataView.delegate = self;
    }
    [_noDataView showNoDataView:superView noDataType:type];
    
}

- (void)showNoDataView
{
    [self showLoadFailView:YES noDataType:0];
}

- (void)hideNoDataView
{
    [self showLoadFailView:NO noDataType:0];
}

- (void)showLoadFailView:(BOOL)isShow noDataType:(NODataType)nodataType{
    if(isShow){
        if (!_noDataView) {
            _noDataView = [NoDataView loadFromXib];
            _noDataView.delegate = self;
        }
        [_noDataView showNoDataViewController:self noDataType:nodataType];
    }
    else{
        [_noDataView hide];
    }
}


#pragma mark - show or hide noNetWorkView method
-(void)showNoNetWorkView{
    [self showNoNetWorkViewInView:self.view];
}

- (void)showNoNetWorkView:(NoNetWorkViewStyle)style{
    return [self showNoNetWorkViewInView:self.view frame:self.view.bounds style:style];
}

- (void)showNoNetWorkViewWithFrame:(CGRect)frame{
    [self showNoNetWorkViewInView:self.view frame:frame];
}

-(void)showNoNetWorkViewInView:(UIView *)view{
    [self showNoNetWorkViewInView:view frame:view.bounds];
}

- (void)showNoNetWorkViewInView:(UIView *)view centerY:(CGFloat)centerY style:(NoNetWorkViewStyle)style
{
    CGRect frame = view.bounds;
    
    frame.size.height -= centerY;
    
    [self showNoNetWorkViewInView:view frame:frame style:style];
}

- (void)showNoNetWorkViewInView:(UIView *)view frame:(CGRect)frame{
    NoNetWorkViewStyle style = NoNetWorkViewStyle_No_NetWork;
    AFNetworkReachabilityStatus networkStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if(networkStatus == AFNetworkReachabilityStatusReachableViaWiFi || networkStatus == AFNetworkReachabilityStatusReachableViaWWAN){
        //加载失败
        style = NoNetWorkViewStyle_Load_Fail;
    }
    [self showNoNetWorkViewInView:view frame:frame style:style];
}

- (void)showNoNetWorkViewInView:(UIView *)view frame:(CGRect)frame style:(NoNetWorkViewStyle)style{
    if (!_noNetWorkView) {
        _noNetWorkView = [NoNetWorkView loadFromXib];
        _noNetWorkView.delegate = self;
    }
    
    [_noNetWorkView showInView:view style:style];
    _noNetWorkView.frame = frame;
}

-(void)hideNoNetWorkView
{
    [_noNetWorkView hide];
}

//Overide method
#pragma mark NoNetWorkViewDelegate
-(void)retryToGetData{
    
}

#pragma mark - loading的显示方法
- (void)showLoadingView
{
    if (!_loadingView) {
        _loadingView = [[RDLoadingView alloc] init];
    }
    
    if (_loadingView.superview) {
        [_loadingView removeFromSuperview];
    }
    
    [self.view addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(104);
        make.height.mas_equalTo(40);
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(-30);
    }];
    [_loadingView showLoaingAnimation];
}

- (void)hiddenLoadingView
{
    if (_loadingView) {
        if (_loadingView.superview) {
            [_loadingView hiddenLoaingAnimation];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
