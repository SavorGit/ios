//
//  RDHomeScreenViewController.m
//  小热点3.0
//
//  Created by 郭春城 on 2017/7/3.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDHomeScreenViewController.h"
#import "RDTabScrollView.h"
#import "Masonry.h"

@interface RDHomeScreenViewController ()

@property (nonatomic, strong) RDTabScrollView * tabScroll;
@property (nonatomic, strong) UIView * bottomView;

@end

@implementation RDHomeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
}

- (void)createUI
{
    self.tabScroll = [[RDTabScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height / 5 * 3) imagesNameArray:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"]];
    self.tabScroll.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.tabScroll];
    [self.tabScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(self.view.frame.size.height / 5 * 3);
    }];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tabScroll.mas_bottom).offset(0);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    UIButton * photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoBtn setTitle:@"相册上电视" forState:UIControlStateNormal];
    [photoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [photoBtn setBackgroundColor:[UIColor blueColor]];
    [photoBtn addTarget:self action:@selector(photoButtonDidBeCicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:photoBtn];
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 40) / 2;
    [photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(width, 70));
        make.centerY.mas_equalTo(0);
    }];
    
    UIButton * fileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fileBtn setTitle:@"文件上电视" forState:UIControlStateNormal];
    [fileBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fileBtn setBackgroundColor:[UIColor blueColor]];
    [fileBtn addTarget:self action:@selector(fileButtonDidBeCicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:fileBtn];
    [fileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(photoBtn.mas_right).offset(10);
        make.size.mas_equalTo(CGSizeMake(width, 70));
        make.centerY.mas_equalTo(0);
    }];
}

- (void)photoButtonDidBeCicked
{
    
}

- (void)fileButtonDidBeCicked
{
    
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
