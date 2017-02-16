//
//  HomeBaseViewController.h
//  SavorX
//
//  Created by 郭春城 on 17/2/14.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NoDataView.h"
#import "NoNetWorkView.h"

@interface HomeBaseViewController : UIViewController


/**
 *  @brief 初始化View
 */
-(void)setupViews;
/**
 *  @brief 初始化Data
 */
-(void)setupDatas;

//设置返回按钮
- (void)setNavBackArrow;

//返回按钮点击事件
- (void)navBackButtonClicked:(UIButton *)sender;


#pragma mark - 无数据的显示方法
/**
 *  显示无数据视图
 *
 *  @param frame 内容显示的frame
 */
- (void)showNoDataViewWithFrame:(CGRect)frame;
- (void)showNoDataViewWithFrame:(CGRect)frame noDataType:(NODataType)type;
/**
 *  显示无数据视图在某个视图上
 *
 *  @param superView 无数据视图的父视图
 */
- (void)showNoDataViewInView:(UIView *)superView;
- (void)showNoDataViewInView:(UIView *)superView noDataString:(NSString *)noDataString;
-(void)showNoDataViewInView:(UIView*)superView noDataType:(NODataType)type;
- (void)showNoDataViewBelowView:(UIView *)view noDataType:(NODataType)type;
- (void)showNoDataView;
- (void)hideNoDataView;

#pragma mark - 无网络的显示方法
-(void)showNoNetWorkView:(NoNetWorkViewStyle)style;
- (void)showNoNetWorkViewWithFrame:(CGRect)frame;
-(void)showNoNetWorkView;
-(void)hideNoNetWorkView;
-(void)retryToGetData;
/**
 *  在某个视图上显示无网，此时无网络视图在此视图的中心，大小与此视图一样大小
 *
 *  @param view 显示无网络视图的父视图
 */
-(void)showNoNetWorkViewInView:(UIView *)view;


@end
