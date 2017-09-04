//
//  SpecialTopicGroupViewController.h
//  SavorX
//
//  Created by 王海朋 on 2017/8/29.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import "HomeBaseViewController.h"

@interface SpecialTopicGroupViewController : HomeBaseViewController

@property (nonatomic, strong) UITableView * tableView; //表格展示视图

- (instancetype)initWithtopGroupID:(NSInteger)topGroupId;

- (void)showSelfAndCreateLog;

@end
