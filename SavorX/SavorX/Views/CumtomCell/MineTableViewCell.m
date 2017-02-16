//
//  MineTableViewCell.m
//  SavorX
//
//  Created by 郭春城 on 16/8/17.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "MineTableViewCell.h"

@interface MineTableViewCell ()

@property (nonatomic, strong) UIImageView * rightMore;
@property (nonatomic, strong) UILabel * rightLabel;

@end

@implementation MineTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createMineCell];
    }
    return self;
}

- (void)createMineCell
{
    self.rightLabel = [[UILabel alloc] init];
    self.rightLabel.textColor = [UIColor grayColor];
    self.rightLabel.font = [UIFont systemFontOfSize:16];
    self.rightLabel.textAlignment = NSTextAlignmentRight;
    
    self.rightMore = [[UIImageView alloc] init];
    [self.rightMore setImage:[UIImage imageNamed:@"rightMore"]];
    
    [self showRightMoreImage];
}

- (void)showRightMoreImage
{
    
    if (self.rightLabel.superview) {
        [self.rightLabel removeFromSuperview];
    }
    
    [self.contentView addSubview:self.rightMore];
    
    [self.rightMore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
}

- (void)showRightTitleLabelWith:(NSString *)title
{
    if (self.rightMore.superview) {
        [self.rightMore removeFromSuperview];
    }
    
    [self.rightLabel setText:title];
    
    [self.contentView addSubview:self.rightLabel];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(150, 30));
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
