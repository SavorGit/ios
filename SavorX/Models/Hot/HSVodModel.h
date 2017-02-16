//
//  HSVodModel.h
//  HotSpot
//
//  Created by 郭春城 on 16/12/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseModel.h"

@interface HSVodModel : BaseModel

@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, copy) NSString * category;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, copy) NSString * imageURL;
@property (nonatomic, copy) NSString * contentURL;
@property (nonatomic, assign) NSInteger canPlay;
@property (nonatomic, copy) NSString * videoURL;
@property (nonatomic, copy) NSString * shareTitle;
@property (nonatomic, copy) NSString * shareContent;
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, assign) NSInteger type;

@end
