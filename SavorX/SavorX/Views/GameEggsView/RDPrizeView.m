//
//  RDPrizeView.m
//  SavorX
//
//  Created by 王海朋 on 2017/5/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDPrizeView.h"

@implementation RDPrizeView

- (instancetype)initWithFrame:(CGRect)frame withModel:(HSEggsResultModel *)model{
    
    if (self = [super initWithFrame:frame]) {
        
        [self creatSubViews:model];
    }
    return self;
}

- (void)creatSubViews:(HSEggsResultModel *)model{
    UILabel *congratueLab = [[UILabel alloc] init];
    congratueLab.font = [UIFont systemFontOfSize:16];
    congratueLab.textColor = UIColorFromRGB(0xf5f5f5);
    congratueLab.backgroundColor = [UIColor clearColor];
    congratueLab.textAlignment = NSTextAlignmentCenter;
    congratueLab.text = @"恭喜您，中奖了~~~";
    [self addSubview:congratueLab];
    [congratueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 50));
        make.top.mas_equalTo(self.top).offset(5);
        make.centerX.equalTo(self);
    }];
    
    UILabel *phoneNameLab = [[UILabel alloc] init];
    phoneNameLab.font = [UIFont systemFontOfSize:12];
    phoneNameLab.textColor = UIColorFromRGB(0xf5f5f5);
    phoneNameLab.backgroundColor = [UIColor clearColor];
    phoneNameLab.textAlignment = NSTextAlignmentLeft;
    phoneNameLab.text = @"游戏者的手机";
    [self addSubview:phoneNameLab];
    [phoneNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.top.mas_equalTo(congratueLab.mas_bottom);
        make.left.mas_equalTo(5);
    }];
    
    UILabel *prizeLevelLab = [[UILabel alloc] init];
    prizeLevelLab.font = [UIFont systemFontOfSize:30];
    prizeLevelLab.textColor = UIColorFromRGB(0xf5f5f5);
    prizeLevelLab.backgroundColor = [UIColor clearColor];
    prizeLevelLab.textAlignment = NSTextAlignmentCenter;
    prizeLevelLab.text = @"特等奖";
    [self addSubview:prizeLevelLab];
    [prizeLevelLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 60));
        make.top.mas_equalTo(phoneNameLab.mas_bottom);
        make.centerX.equalTo(self);
    }];
    
    UILabel *prizeFormLab = [[UILabel alloc] init];
    prizeFormLab.font = [UIFont systemFontOfSize:14];
    prizeFormLab.textColor = [UIColor blackColor];
    prizeFormLab.backgroundColor = [UIColor clearColor];
    prizeFormLab.textAlignment = NSTextAlignmentCenter;
    prizeFormLab.text = @"快去找服务员领取奖品吧";
    [self addSubview:prizeFormLab];
    [prizeFormLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(160, 30));
        make.top.mas_equalTo(self.mas_bottom).offset(- 80);
        make.centerX.equalTo(self);
    }];
    
    UILabel *prizeTimeLab = [[UILabel alloc] init];
    prizeTimeLab.font = [UIFont systemFontOfSize:14];
    prizeTimeLab.textColor = [UIColor blackColor];
    prizeTimeLab.backgroundColor = [UIColor clearColor];
    prizeTimeLab.textAlignment = NSTextAlignmentCenter;
    prizeTimeLab.text = @"有效领奖时间:60分钟,";
    [self addSubview:prizeTimeLab];
    [prizeTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(140, 30));
        make.top.mas_equalTo(self.mas_bottom).offset(-40);
        make.left.mas_equalTo(20);
    }];
    
    UILabel *alertLab = [[UILabel alloc] init];
    alertLab.font = [UIFont systemFontOfSize:14];
    alertLab.textColor = [UIColor redColor];
    alertLab.backgroundColor = [UIColor clearColor];
    alertLab.textAlignment = NSTextAlignmentCenter;
    alertLab.text = @"关闭后将无法领取";
    [self addSubview:alertLab];
    [alertLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(140, 30));
        make.top.mas_equalTo(self.mas_bottom).offset(-40);
        make.left.mas_equalTo(prizeTimeLab.mas_right);
    }];

}
@end
