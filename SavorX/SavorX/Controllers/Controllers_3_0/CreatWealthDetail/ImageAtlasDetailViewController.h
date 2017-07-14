//
//  ImageAtlasDetailViewController.h
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/5.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateWealthModel.h"

@interface ImageAtlasDetailViewController : UIViewController

@property (nonatomic, assign) NSInteger categoryID; //分类ID
@property(nonatomic ,strong) CreateWealthModel *imgAtlModel;

@end
