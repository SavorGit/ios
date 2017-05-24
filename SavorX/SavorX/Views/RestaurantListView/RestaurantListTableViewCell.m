//
//  RestaurantListTableViewCell.m
//  SavorX
//
//  Created by 王海朋 on 2017/5/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RestaurantListTableViewCell.h"

@implementation RestaurantListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self initWithSubView];
    }
    return self;
}

- (void)initWithSubView{
    
    _bgView = [[UIView alloc]init];
    _bgView.backgroundColor = [UIColor lightGrayColor];
    _bgView.layer.masksToBounds = YES;
    _bgView.layer.cornerRadius = 3.0;
    _bgView.layer.borderWidth = 0.0;
    [self.contentView addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 20, 130));
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(10);
    }];
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.frame = CGRectMake(15, 15,85, 21);
    _titleLabel.font = [UIFont boldSystemFontOfSize:20];
    _titleLabel.textColor = UIColorFromRGB(0x808080);
    _titleLabel.text = @"李秀英英";
    [_bgView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.width - 100, 25));
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(10);
    }];
    
    _distanceLabel = [[UILabel alloc]init];
    _distanceLabel.font = [UIFont systemFontOfSize:17];
    _distanceLabel.textColor = UIColorFromRGB(0x808080);
    _distanceLabel.text = @"100m";
    [_bgView addSubview:_distanceLabel];
    [_distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 20));
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(_titleLabel.mas_right).offset(10);
    }];
    
    _addressLabel = [[UILabel alloc]init];
    _addressLabel.text = @"地址：北京市朝阳区大望路永峰大厦601";
    _addressLabel.backgroundColor = [UIColor clearColor];
    _addressLabel.font = [UIFont systemFontOfSize:17];
    _addressLabel.textColor = UIColorFromRGB(0x808080);
    [_bgView addSubview:_addressLabel];
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.width, 40));
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(30);
        make.left.mas_equalTo(10);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
