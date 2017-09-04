//
//  SingleSpecialTopicViewController.m
//  SavorX
//
//  Created by 王海朋 on 2017/9/1.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SingleSpecialTopicViewController.h"

@interface SingleSpecialTopicViewController ()

@end

@implementation SingleSpecialTopicViewController

- (instancetype)initWithtopGroupID:(NSInteger )topGroupId
{
    if (self = [super initWithtopGroupID:topGroupId]) {
        
        [self hiddenFootView];
    }
    return self;
}

- (void)hiddenFootView{
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 15)];
    footView.backgroundColor = UIColorFromRGB(0xf6f2ed);
    self.tableView.tableFooterView = footView;
}

- (void)viewDidLoad {
    [super viewDidLoad]; 
    // Do any additional setup after loading the view.
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
