//
//  ImageArrayViewController.h
//  SavorX
//
//  Created by 郭春城 on 2017/8/18.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseViewController.h"

@interface ImageArrayViewController : BaseViewController

- (instancetype)initWithCategoryID:(NSInteger)categoryID model:(CreateWealthModel *)model;

@property (nonatomic, weak) UINavigationController * parentNavigationController;

@end
