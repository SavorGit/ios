//
//  CategoryViewController.h
//  SavorX
//
//  Created by 郭春城 on 17/1/17.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HomeBaseViewController.h"

@interface CategoryViewController : HomeBaseViewController

@property (nonatomic, assign) NSInteger categoryID;

@property (nonatomic, strong) UINavigationController * parentNavigationController;

- (instancetype)initWithCategoryID:(NSInteger)categoryID;

- (void)showSelfAndCreateLog;

@end
