//
//  SpecialTopDetailViewController.h
//  SavorX
//
//  Created by 王海朋 on 2017/7/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CreateWealthModel.h"

@interface SpecialTopDetailViewController : BaseViewController

@property (nonatomic, assign) NSInteger categoryID; //分类ID
@property(nonatomic, strong) CreateWealthModel *specilDetailModel;

@end
