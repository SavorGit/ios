//
//  ArticleReadViewController.h
//  SavorX
//
//  Created by 郭春城 on 17/2/13.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import "HSVodModel.h"

@interface ArticleReadViewController : BaseViewController

@property (nonatomic, assign) NSInteger categoryID; //分类ID

- (instancetype)initWithVodModel:(HSVodModel *)model andImage:(UIImage *)image;

@end
