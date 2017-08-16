//
//  ImageAtlasDetailViewController.h
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/5.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateWealthModel.h"
#import "BaseViewController.h"

typedef void (^imageAtlas) (BOOL isPortrait);
@interface ImageAtlasDetailViewController : BaseViewController

- (instancetype)initWithCategoryID:(NSInteger)categoryID model:(CreateWealthModel *)model;

@property (nonatomic, assign) NSInteger categoryID; //分类ID
@property(nonatomic ,strong) CreateWealthModel *imgAtlModel;
@property (nonatomic, weak) UINavigationController * parentNavigationController;

@property(nonatomic, copy) imageAtlas imageAtlBlock;

@end
