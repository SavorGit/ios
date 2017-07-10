//
//  RDHotelItemModel.h
//  SavorX
//
//  Created by 郭春城 on 2017/7/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseModel.h"

@interface RDHotelItemModel : BaseModel

@property (nonatomic, copy) NSString * cid; //id
@property (nonatomic, copy) NSString * title; //标题
@property (nonatomic, copy) NSString * name; //名称
@property (nonatomic, assign) NSInteger duration; //总时长
@property (nonatomic, assign) NSInteger canPlay; //是否可以点播
@property (nonatomic, assign) NSInteger createTime; //创建时间
@property (nonatomic, copy) NSString * updateTime; //更新时间
@property (nonatomic, assign) NSInteger type; //类型
@property (nonatomic, copy) NSString * mediaId; //视频的mediaID
@property (nonatomic, copy) NSString * sort_num; //排序
@property (nonatomic, copy) NSString * sourceName; //来源
@property (nonatomic, copy) NSString * logo; //logo
@property (nonatomic, copy) NSString * imageURL; //图片
@property (nonatomic, copy) NSString * contentURL; //内容URL
@property (nonatomic, copy) NSString * videoURL; //视频URL

@end
