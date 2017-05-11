//
//  RDPrizeView.m
//  SavorX
//
//  Created by 王海朋 on 2017/5/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDPrizeView.h"
#import "GCCGetInfo.h"

@implementation RDPrizeView

- (instancetype)initWithFrame:(CGRect)frame withModel:(HSEggsResultModel *)model{
    
    if (self = [super initWithFrame:frame]) {
        
        [self creatSubViews:model];
    }
    return self;
}

- (void)creatSubViews:(HSEggsResultModel *)model{
    
    UIImageView *bgImgView = [[UIImageView alloc] init];
    bgImgView.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    bgImgView.image = [UIImage imageNamed:@"zjjg_bg"];
    [self addSubview:bgImgView];
    
    UILabel *congratueLab = [[UILabel alloc] init];
    congratueLab.font = [UIFont systemFontOfSize:20];
    congratueLab.textColor = [UIColor whiteColor];
    congratueLab.backgroundColor = [UIColor clearColor];
    congratueLab.textAlignment = NSTextAlignmentCenter;
    congratueLab.text = @"恭喜您，中奖啦~";
    [bgImgView addSubview:congratueLab];
    [congratueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 50));
        make.top.mas_equalTo(self.top).offset(5);
        make.centerX.equalTo(self);
    }];
    
    UILabel *phoneNameLab = [[UILabel alloc] init];
    phoneNameLab.font = [UIFont systemFontOfSize:16];
    phoneNameLab.textColor = [UIColor redColor];
    phoneNameLab.backgroundColor = [UIColor clearColor];
    phoneNameLab.textAlignment = NSTextAlignmentLeft;
    phoneNameLab.text = [NSString stringWithFormat:@"%@的IPhone",[GCCGetInfo getIphoneName]];
    [bgImgView addSubview:phoneNameLab];
    CGFloat phoneNameLabWidth  = [Helper autoWidthWith:260];
    CGFloat phoneNameLabHeight  = [Helper autoHeightWith:30];
    [phoneNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(phoneNameLabWidth, phoneNameLabHeight));
        make.top.mas_equalTo(congratueLab.mas_bottom).offset(5);
        make.left.mas_equalTo(10);
    }];
    
//    UILabel *getPriTimeLab = [[UILabel alloc] init];
//    getPriTimeLab.font = [UIFont systemFontOfSize:16];
//    getPriTimeLab.textColor = [UIColor redColor];
//    getPriTimeLab.backgroundColor = [UIColor clearColor];
//    getPriTimeLab.textAlignment = NSTextAlignmentLeft;
//    getPriTimeLab.text = @"2017-05-11 16:12";
//    [bgImgView addSubview:getPriTimeLab];
//    CGFloat getPriWidth  = [Helper autoWidthWith:kMainBoundsWidth - 260];
//    CGFloat getPribHeight  = [Helper autoHeightWith:30];
//    [phoneNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(getPriWidth, getPribHeight));
//        make.top.mas_equalTo(congratueLab.mas_bottom).offset(5);
//        make.left.mas_equalTo(10);
//    }];
    
    
    UIImageView *prizeLevelImg = [[UIImageView alloc] init];
    prizeLevelImg.image = [UIImage imageNamed:@"yidj"];
    [bgImgView addSubview:prizeLevelImg];
    CGFloat prizeLeveWidth  = [Helper autoWidthWith:113];
    CGFloat prizeLeveHeight  = [Helper autoHeightWith:36];
    CGFloat prizeLeveToTop  = [Helper autoHeightWith:20];
    [prizeLevelImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(prizeLeveWidth, prizeLeveHeight));
        make.top.mas_equalTo(phoneNameLab.mas_bottom).offset(prizeLeveToTop);
        make.centerX.equalTo(self);
    }];
    if (model.prize_level == 1) {
        prizeLevelImg.image = [UIImage imageNamed:@"yidj"];
    }else if (model.prize_level == 2){
        prizeLevelImg.image = [UIImage imageNamed:@"erdj"];
    }else if (model.prize_level == 3){
        prizeLevelImg.image = [UIImage imageNamed:@"sadj"];
    }else{
        prizeLevelImg.image = [UIImage imageNamed:@"xxcy"];
    }
    
    UILabel *prizeFormLab = [[UILabel alloc] init];
    prizeFormLab.font = [UIFont systemFontOfSize:18];
    if (kMainBoundsWidth == 320) {
        prizeFormLab.font = [UIFont systemFontOfSize:15];
    }
    prizeFormLab.textColor = [UIColor lightGrayColor];
    prizeFormLab.backgroundColor = [UIColor clearColor];
    prizeFormLab.textAlignment = NSTextAlignmentCenter;
    prizeFormLab.text = @"快去找服务员领取奖品吧";
    [bgImgView addSubview:prizeFormLab];
    CGFloat prizeFormToBottom  = [Helper autoHeightWith:12];
    [prizeFormLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 50));
        make.bottom.mas_equalTo(self.mas_bottom).offset(- prizeFormToBottom);
        make.centerX.equalTo(self);
    }];
    
    UILabel *prizeTimeLab = [[UILabel alloc] init];
    prizeTimeLab.font = [UIFont systemFontOfSize:14];
    if (kMainBoundsWidth == 320) {
        prizeTimeLab.font = [UIFont systemFontOfSize:11];
    }
    prizeTimeLab.textColor = [UIColor lightGrayColor];
    prizeTimeLab.backgroundColor = [UIColor clearColor];
    prizeTimeLab.textAlignment = NSTextAlignmentCenter;
    prizeTimeLab.text = @"有效领奖时间:60分钟,";
    [bgImgView addSubview:prizeTimeLab];
    CGFloat prizeViewWidth  = [Helper autoWidthWith:294];
    CGFloat priAlertWidth  = [Helper autoWidthWith:260];
    CGFloat prTLabToLeft = [Helper autoHeightWith:(prizeViewWidth - priAlertWidth)/2];
    
    CGFloat prizeTimeWidth  = [Helper autoWidthWith:140];
    CGFloat prizeTimeHeight  = [Helper autoHeightWith:30];
    [prizeTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(prizeTimeWidth, prizeTimeHeight));
        make.top.mas_equalTo(self.mas_bottom).offset(-30);
        make.left.mas_equalTo(bgImgView.mas_left).offset(prTLabToLeft);
    }];
    
    UILabel *alertLab = [[UILabel alloc] init];
    alertLab.font = [UIFont systemFontOfSize:14];
    if (kMainBoundsWidth == 320) {
        alertLab.font = [UIFont systemFontOfSize:11];
    }
    alertLab.textColor = [UIColor redColor];
    alertLab.backgroundColor = [UIColor clearColor];
    alertLab.textAlignment = NSTextAlignmentCenter;
    alertLab.text = @"关闭后将无法领取";
    [bgImgView addSubview:alertLab];
    CGFloat alertWidth  = [Helper autoWidthWith:120];
    CGFloat alertHeight  = [Helper autoHeightWith:30];
    [alertLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(alertWidth, alertHeight));
        make.top.mas_equalTo(self.mas_bottom).offset(-30);
        make.left.mas_equalTo(prizeTimeLab.mas_right);
    }];
    
    if (model.win == 1) {
        congratueLab.text = @"恭喜您，中奖啦~";
    }else if (model.win == 0){
        congratueLab.text = @"很遗憾，没有中奖";
        prizeFormLab.text = @"您可邀请好友参加此活动哦~";
        prizeTimeLab.text = @"";
        alertLab.text = @"";
        CGFloat prizeFormToBottom  = [Helper autoHeightWith:10];
        [prizeFormLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 40));
            make.bottom.mas_equalTo(self.mas_bottom).offset(- prizeFormToBottom);
            make.centerX.equalTo(self);
        }];
    }

}
@end
