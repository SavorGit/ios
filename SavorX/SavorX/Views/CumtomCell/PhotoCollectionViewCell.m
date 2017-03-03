//
//  PhotoCollectionViewCell.m
//  SavorX
//
//  Created by 郭春城 on 17/3/1.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@interface PhotoCollectionViewCell ()

@property (nonatomic, strong) UIImageView * bgImageView; //缩略图

//PHAssetMediaTypeImage
@property (nonatomic, strong) UIImageView * selectImageView; //选择图

//PHAssetMediaTypeAudio
@property (nonatomic, strong) UIView * videoMaskView; //视频遮罩
@property (nonatomic, strong) UILabel * videoTimeLabel; //视频时长显示

@end

@implementation PhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUpPhotoCell];
    }
    return self;
}

- (void)reloadViewWithAsset:(PHAsset *)asset andIsChoose:(BOOL)isChoose
{
    self.mediaType = asset.mediaType;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CollectionViewCellSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [self.bgImageView setImage:result];
    }];
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        
        self.videoTimeLabel.hidden = YES;
        self.videoMaskView.hidden = YES;
        if (isChoose) {
            self.selectImageView.hidden = NO;
        }else{
            self.selectImageView.hidden = YES;
        }
        
    }else if (asset.mediaType == PHAssetMediaTypeVideo) {
        
        self.videoTimeLabel.hidden = NO;
        self.selectImageView.hidden = YES;
        if (isChoose) {
            self.videoMaskView.hidden = NO;
        }else{
            self.videoMaskView.hidden = YES;
        }
        
        long long minute = 0, second = 0;
        second = asset.duration;
        minute = second / 60;
        second = second % 60;
        self.videoTimeLabel.text = [NSString stringWithFormat:@"%.2lld'%.2lld\"", minute, second];
    }
}

- (void)photoDidBeSelected:(BOOL)select
{
    if (select) {
        self.isChoosed = YES;
        [self.selectImageView setImage:[UIImage imageNamed:@"ImageSelectedSmallOn"]];
    }else{
        self.isChoosed = NO;
        [self.selectImageView setImage:[UIImage imageNamed:@"ImageSelectedSmallOff"]];
    }
}

- (void)setUpPhotoCell
{
    self.bgImageView = [[UIImageView alloc] init];
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bgImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.selectImageView = [[UIImageView alloc] init];
    [self.selectImageView setImage:[UIImage imageNamed:@"ImageSelectedSmallOff"]];
    [self.contentView addSubview:self.selectImageView];
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(31, 31));
        make.bottom.mas_equalTo(-2);
        make.right.mas_equalTo(-2);
    }];
    
    self.videoMaskView = [[UIView alloc] initWithFrame:CGRectZero];
    self.videoMaskView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    [self.contentView addSubview:self.videoMaskView];
    [self.videoMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.videoTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.videoTimeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    self.videoTimeLabel.textAlignment = NSTextAlignmentRight;
    self.videoTimeLabel.textColor = [UIColor whiteColor];
    self.videoTimeLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.videoTimeLabel];
    [self.videoTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(30);
    }];
    
    self.layer.cornerRadius = 3.f;
    self.layer.masksToBounds = YES;
}

@end
