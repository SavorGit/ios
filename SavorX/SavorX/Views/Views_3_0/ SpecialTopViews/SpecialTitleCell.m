//
//  SpecialTitleCell.m
//  SavorX
//
//  Created by 郭春城 on 2017/8/28.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialTitleCell.h"

@interface SpecialTitleCell ()

@property (nonatomic, strong) UILabel * artTitleLabel;

@end


@implementation SpecialTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self initWithSubView];
    }
    return self;
}

- (void)initWithSubView
{
    self.artTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.artTitleLabel.backgroundColor = [UIColor clearColor];
    self.artTitleLabel.font = kPingFangRegular(16);
    self.artTitleLabel.textColor = UIColorFromRGB(0x922c3e);
    self.artTitleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.artTitleLabel];
    [self.artTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(- 15);
        make.height.mas_equalTo(22.5);
    }];
}

- (void)configWithText:(NSString *)text
{
//    CGFloat height = [self getHeightByWidth:kMainBoundsWidth - 30 title:text font:kPingFangRegular(16)];
    self.artTitleLabel.text = text;
}

- (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = font;
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
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
