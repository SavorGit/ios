//
//  RecommendViewController.h
//  SavorX
//
//  Created by 郭春城 on 17/1/17.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HomeBaseViewController.h"

@interface RecommendViewController : HomeBaseViewController

@property (nonatomic, strong) UINavigationController * parentNavigationController;

- (void)showSelfAndCreateLog;

@end
