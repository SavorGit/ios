//
//  SpecialListTableViewCell.m
//  SavorX
//
//  Created by 郭春城 on 2017/8/28.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialListTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface SpecialListTableViewCell ()

@property (nonatomic, strong) UIView * bgContentView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIImageView * bgImageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * detailLabel;

@end

@implementation SpecialListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self initWithSubView];
    }
    return self;
}

- (void)initWithSubView
{
    self.backgroundColor = [UIColor clearColor];
    self.bgContentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.bgContentView];
    [self.bgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(7.5);
        make.left.mas_equalTo(10);
        make.bottom.mas_equalTo(-7.5);
        make.right.mas_equalTo(-10);
    }];
    self.bgContentView.backgroundColor = UIColorFromRGB(0xf6f2ed);
    
    UIView * topRedView = [[UIView alloc] initWithFrame:CGRectZero];
    topRedView.backgroundColor = UIColorFromRGB(0x902d3f);
    [self.bgContentView addSubview:topRedView];
    [topRedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(14);
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(3);
        make.height.mas_equalTo(20);
    }];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.textColor = UIColorFromRGB(0x902d3f);
    self.nameLabel.font = kPingFangMedium(18);
    [self.bgContentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.equalTo(topRedView.mas_right).offset(9);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(18);
    }];
    
    self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bgImageView.clipsToBounds = YES;
    self.bgImageView.backgroundColor = [UIColor clearColor];
    [self.bgContentView addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(15);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.equalTo(self.bgImageView.mas_width).multipliedBy(802.f/1242.f);
    }];
    
    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.textColor = UIColorFromRGB(0x575757);
    self.detailLabel.font = kPingFangLight(15);
    self.detailLabel.numberOfLines = 3;
    [self.bgContentView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgImageView.mas_bottom).offset(13);
        make.left.mas_equalTo(10);
        make.bottom.mas_equalTo(-17);
        make.right.mas_equalTo(-10);
    }];
    
    self.nameLabel.text = @"小热点专题名称";
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:@"http://oss.littlehotspot.com/media/resource/yk7Q67bprb.jpg"]];
    self.detailLabel.text = @"红酥手，黄縢酒，满城春色宫墙柳。东风恶，欢情薄。一怀愁绪，几年离索。错！错！错！春如旧，人空瘦，泪痕红浥鲛绡透。桃花落。闲池阁。山盟虽在，锦书难托。莫！莫！莫！";
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
