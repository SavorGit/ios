//
//  WebViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/8/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import "HSVodModel.h"
#import "GCCPlayerView.h"

/**
 *	小热点H5加载页面，在未绑定机顶盒时阅读当期文章，或者在发现页阅读历史文章用于展示文章的页面
 */
typedef void (^comeFromWebView)(NSDictionary *parDic);
@interface WebViewController : BaseViewController

- (instancetype)initWithModel:(HSVodModel *)model categoryID:(NSInteger)categoryID;

@property (nonatomic, strong) HSVodModel * model;
@property (nonatomic, strong) GCCPlayerView * playView; //播放器
@property (nonatomic, assign) NSInteger categoryID; //分类ID

@end
