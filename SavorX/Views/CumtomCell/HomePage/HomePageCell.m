//
//  HomePageCell.m
//  SavorX
//
//  Created by 郭春城 on 17/1/19.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HomePageCell.h"

@interface HomePageCell ()

@end

@implementation HomePageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createHomePageCell];
    }
    return self;
}

- (void)createHomePageCell
{
    self.categroyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.categroyLabel.font = [UIFont systemFontOfSize:15];
    self.categroyLabel.textColor = UIColorFromRGB(0x666666);
    self.categroyLabel.textAlignment = NSTextAlignmentCenter;
    self.categroyLabel.text = @"#分类";
    [self.contentView addSubview:self.categroyLabel];
    
    [self.categroyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgImageView.mas_bottom).offset(0);
        make.left.mas_equalTo(10);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(45);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgImageView.mas_bottom).offset(0);
        make.left.equalTo(self.categroyLabel.mas_right).offset(15);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
}

@end
