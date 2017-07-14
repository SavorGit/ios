//
//  ImageTextDetailViewController.h
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/4.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CreateWealthModel.h"

@interface ImageTextDetailViewController : BaseViewController

@property (nonatomic, assign) NSInteger categoryID; //分类ID
@property(nonatomic ,strong) CreateWealthModel *imgTextModel;

@end
