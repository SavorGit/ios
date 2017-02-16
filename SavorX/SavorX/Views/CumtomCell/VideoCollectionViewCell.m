//
//  VideoCollectionViewCell.m
//  SavorX
//
//  Created by 郭春城 on 16/8/11.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "VideoCollectionViewCell.h"

@interface VideoCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation VideoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.bgImage.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)getInfoFromAsset:(PHAsset *)asset
{
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CollectionViewCellSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [self.bgImage setImage:result];
    }];
    
    long long minute = 0, second = 0;
    second = asset.duration;
    minute = second / 60;
    second = second % 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%.2lld'%.2lld\"", minute, second];
}

- (void)getInfoFromAVAsset:(AVAsset *)asset
{
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    [self.bgImage setImage:thumb];
    
    long long minute = 0, second = 0;
    second = asset.duration.value / asset.duration.timescale;
    minute = second / 60;
    second = second % 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%.2lld:%.2lld", minute, second];
}

@end
