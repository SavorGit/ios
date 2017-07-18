//
//  HeadlinesTableViewCell.m
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/3.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import "HeadlinesTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation HeadlinesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self initWithSubView];
    }
    return self;
}

- (void)initWithSubView{
    
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = UIColorFromRGB(0xf6f2ed);
    [self.contentView addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 20, 343));
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(10);
    }];
    
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bgImageView.layer.masksToBounds = YES;
    _bgImageView.backgroundColor = [UIColor clearColor];
    [_bgView addSubview:_bgImageView];
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 30, 255));
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(5);
    }];
    
    _headLineImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _headLineImage.contentMode = UIViewContentModeScaleAspectFill;
    _headLineImage.layer.masksToBounds = YES;
    _headLineImage.backgroundColor = [UIColor clearColor];
    _headLineImage.image = [UIImage imageNamed:@"toutiao"];
    [_bgImageView addSubview:_headLineImage];
    [_headLineImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(58, 36));
        make.top.mas_equalTo(_bgImageView.mas_top);
        make.left.mas_equalTo(0);
    }];
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = kPingFangMedium(16);
    _titleLabel.textColor = UIColorFromRGB(0x434343);
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.text = @"标题";
    [_bgView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 30, 20));
        make.top.mas_equalTo(_bgImageView.mas_bottom).offset(15);
        make.left.mas_equalTo(12);
    }];
    
    _sourceImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _sourceImage.contentMode = UIViewContentModeScaleAspectFill;
    _sourceImage.layer.masksToBounds = YES;
    _sourceImage.backgroundColor = [UIColor clearColor];
    [_bgView addSubview:_sourceImage];
    
    [_sourceImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(12);
        make.left.mas_equalTo(12);
    }];
    
    _sourceLabel = [[UILabel alloc]init];
    _sourceLabel.text = @"";
    _sourceLabel.font = kPingFangLight(11);
    _sourceLabel.textColor = UIColorFromRGB(0x8a8886);
    [_bgView addSubview:_sourceLabel];
    [_sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.mas_lessThanOrEqualTo(100);
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(12);
        make.left.mas_equalTo(_sourceImage.mas_right).offset(6);
    }];
    
    _timeLabel = [[UILabel alloc]init];
    _timeLabel.text = @"";
    _timeLabel.font = kPingFangLight(10);
    _timeLabel.textColor = UIColorFromRGB(0xb2afab);
    [_bgView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 20));
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(12);
        make.left.mas_equalTo(_sourceLabel.mas_right).offset(10.5);
    }];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xece6de);
    [_bgView addSubview:lineView];
    [lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 20, 6));
        make.top.mas_equalTo(_bgView.mas_bottom).offset(-6);
        make.left.mas_equalTo(0);
    }];
}

- (void)configModelData:(CreateWealthModel *)model{
    
    self.titleLabel.text = model.title;
    self.sourceLabel.text = model.sourceName;
    if (!isEmptyString(model.updateTime)) {
        self.timeLabel.text =  [model.updateTime stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    }
    
    [self.sourceImage sd_setImageWithURL:[NSURL URLWithString:model.logo] placeholderImage:[UIImage imageNamed:@"zanwu"]];
    
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:model.indexImageUrl] placeholderImage:[UIImage imageNamed:@"zanwu"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        if ([manager diskImageExistsForURL:[NSURL URLWithString:model.indexImageUrl]]) {
            NSLog(@"不加载动画");
        }else {
            
            self.bgImageView.alpha = 0.0;
            [UIView transitionWithView:self.bgImageView
                              duration:1.0f
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                [self.bgImageView setImage:image];
                                self.bgImageView.alpha = 1.0;
                            } completion:NULL];
        }
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
