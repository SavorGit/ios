//
//  HSVideoViewController.h
//  SavorX
//
//  Created by 郭春城 on 17/3/22.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import "HSVodModel.h"
#import "GCCPlayerView.h"

typedef void (^comeFromWebView)(NSDictionary *parDic);

@interface HSVideoViewController : BaseViewController

@property (nonatomic, strong) GCCPlayerView * playView; //播放器

- (instancetype)initWithModel:(HSVodModel *)model image:(UIImage *)image;

@end
