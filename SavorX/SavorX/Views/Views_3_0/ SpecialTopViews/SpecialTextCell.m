//
//  SpecialTextCell.m
//  SavorX
//
//  Created by 郭春城 on 2017/8/28.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialTextCell.h"

@interface SpecialTextCell ()

@property (nonatomic, strong) UILabel * artTextLabel;

@end

@implementation SpecialTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self initWithSubView];
    }
    return self;
}

- (void)initWithSubView
{
    self.artTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.artTextLabel.font = kPingFangLight(15);
    self.artTextLabel.textColor = UIColorFromRGB(0x575757);
    self.artTextLabel.numberOfLines = 0;
    [self.contentView addSubview:self.artTextLabel];
    [self.artTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(- 15);
        make.height.mas_equalTo(22.5);
    }];
}

- (void)configWithText:(NSString *)text
{
    self.artTextLabel.text = text;
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
