//
//  BasicTableViewCell.m
//  SavorX
//
//  Created by 郭春城 on 16/8/12.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BasicTableViewCell.h"

@interface BasicTableViewCell ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView * canDemand;

@end

@implementation BasicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createHotCell];
    }
    return self;
}

- (void)createHotCell
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bgImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.bgImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = UIColorFromRGB(0x333333);
    [self.contentView addSubview:self.titleLabel];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.timeLabel.layer.cornerRadius = 12;
    self.timeLabel.clipsToBounds = YES;
    [self.bgImageView addSubview:self.timeLabel];
    
    self.canDemand = [[UIImageView alloc] init];
    [self.canDemand setImage:[UIImage imageNamed:@"canDemand"]];
    [self.bgImageView addSubview:self.canDemand];
    self.canDemand.hidden = YES;
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo([Helper autoHomePageCellImageHeight]);
        make.right.mas_equalTo(0);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgImageView.mas_bottom).offset(0);
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(55, 24));
        make.bottom.mas_equalTo(-10);
        make.right.mas_equalTo(-15);
    }];
    
    [self.canDemand mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(35, 27));
    }];
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(.25f, .25f);
    self.layer.shadowOpacity = .06f;
}

- (void)videoCanDemand:(BOOL)can
{
    self.canDemand.hidden = !can;
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
