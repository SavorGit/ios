//
//  AdviceViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/18.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "AdviceViewController.h"
#import "UIColor+YYAdditions.h"
#import "GCCKeyChain.h"
#import "FeedbackView.h"
#import "HSSubmitFeedbackRequest.h"

@interface AdviceViewController ()<FeedbackViewDelegate>

@property (nonatomic, strong) FeedbackView *feedbackView;

@end

@implementation AdviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.feedbackView = [FeedbackView loadFromXib];
    [self.view addSubview:self.feedbackView];
    self.feedbackView.delegate = self;
    self.feedbackView.frame = self.view.frame;
}

-(void)viewDidAppear:(BOOL)animated{
    [SAVORXAPI postUMHandleWithContentId:@"menu_feedback" key:nil value:nil];
}

-(void)feedbackView:(FeedbackView *)fView adviceText:(NSString *)advice phoneText:(NSString *)phone{
    
    NSString * adviceStr = advice;
    NSString * contactStr = phone;
    
    if (![advice isEqualToString:@""]) {
        [SAVORXAPI postUMHandleWithContentId:@"menu_feedback_input" key:nil value:nil];
    }
    if (![phone isEqualToString:@""]) {
        [SAVORXAPI postUMHandleWithContentId:@"menu_feedback_information" key:nil value:nil];
    }
    if (adviceStr.length == 0) {
        [SAVORXAPI showAlertWithString:@"请填写完整信息" withController:self];
        return;
    }
    
    [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在发送"];
    
    HSSubmitFeedbackRequest *request = [[HSSubmitFeedbackRequest alloc] initWithSuggestion:adviceStr contactWay:contactStr];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [MBProgressHUD showSuccessHUDInView:self.view title:@"已发送"];
        [SAVORXAPI postUMHandleWithContentId:@"menu_feedback_back_submit" key:@"menu_feedback_back_submit" value:@"success"];
        [self.navigationController popViewControllerAnimated:YES];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [SAVORXAPI showAlertWithString:@"发送失败" withController:self];
        [SAVORXAPI postUMHandleWithContentId:@"menu_feedback_back_submit" key:@"menu_feedback_back_submit" value:@"fail"];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [SAVORXAPI showAlertWithString:@"发送失败" withController:self];
        [SAVORXAPI postUMHandleWithContentId:@"menu_feedback_back_submit" key:@"menu_feedback_back_submit" value:@"fail"];
    }];
    
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"menu_feedback_back" key:nil value:nil];
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
