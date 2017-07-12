//
//  SpecialTopTableViewCell.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialTopTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation SpecialTopTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self initWithSubView];
    }
    return self;
}

- (void)initWithSubView{
    
    _bgView = [[UIView alloc]init];
    _bgView.backgroundColor = UIColorFromRGB(0xf6f2ed);
    [self.contentView addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 96));
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
    
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bgImageView.layer.masksToBounds = YES;
    _bgImageView.backgroundColor = [UIColor clearColor];
    [_bgView addSubview:_bgImageView];
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(130, 84));
        make.top.mas_equalTo(6);
        make.right.mas_equalTo(-15);
    }];
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = kPingFangMedium(16);
    _titleLabel.textColor = UIColorFromRGB(0x434343);
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.text = @"标题";
    [_bgView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 30 - 130 - 10, 20));
        make.top.mas_equalTo(6);
        make.left.mas_equalTo(15);
    }];
    
    _timeLabel = [[UILabel alloc]init];
    _timeLabel.text = @"";
    _timeLabel.font = kPingFangLight(10);
    _timeLabel.textColor = UIColorFromRGB(0xb2afab);
    [_bgView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 20));
        make.bottom.mas_equalTo(_bgImageView.mas_bottom).offset(-15);
        make.left.mas_equalTo(15);
    }];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xe0dad2);
    [_bgView addSubview:lineView];
    [lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 1));
        make.bottom.mas_equalTo(_bgView.bottom).offset(-1);
        make.left.mas_equalTo(0);
    }];
    
}

- (void)configModelData:(HSSpecialTopModel *)model{
    
    self.titleLabel.text = model.title;
    if (!isEmptyString(model.updateTime)) {
        self.timeLabel.text =  [model.updateTime stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    }
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:model.imageURL] placeholderImage:[UIImage imageNamed:@"zanwu"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        if ([manager diskImageExistsForURL:[NSURL URLWithString:model.imageURL]]) {
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
