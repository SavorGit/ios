//
//  CreateWealthModel.h
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/3.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import "BaseModel.h"

@interface CreateWealthModel : BaseModel

@property(nonatomic, assign) NSString * artid;
@property(nonatomic, strong) NSString *sort_num;
@property(nonatomic, assign) NSInteger type;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *imageURL;
@property(nonatomic, strong) NSString *contentURL;
@property(nonatomic, strong) NSString *sourceName;
@property(nonatomic, strong) NSString *logo; 
@property(nonatomic, strong) NSString *indexImageUrl;

@property(nonatomic, assign) NSInteger canplay;
@property(nonatomic, assign) NSInteger duration;
@property(nonatomic, assign) NSString *mediaId;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *updateTime;
@property(nonatomic, strong) NSString *videoURL;
@property (nonatomic, assign) NSInteger canPlay;
@property (nonatomic, assign) NSString *colTuJi;
@property (nonatomic, copy) NSString * createTime; //创建时间
@property (nonatomic, assign) NSInteger collected;  //0代表未收藏，1代表收藏

@property (nonatomic, copy) NSString * acreateTime;
@property (nonatomic, copy) NSString * ucreateTime;

@property (nonatomic, assign) NSInteger categoryId;
@property (nonatomic, copy) NSString * category;//用于文章推荐
@property (nonatomic, copy) NSString * indexImgUrl;//用于文章推荐
@property (nonatomic, copy) NSString * order_tag;//用于文章推荐
@property (nonatomic, copy) NSString * shareTitle;//用于文章推荐

@property (nonatomic, assign) NSInteger sgtype;//用于专题组类型
@property (nonatomic, copy) NSString * img_url;//用于专题组图片
@property (nonatomic, copy) NSString * stitle;//用于专题组小标题
@property (nonatomic, copy) NSString * stext;//用于专题组文字内容
@property (nonatomic, copy) NSString * desc;//用于专题组头部描述

//非接口返回
@property (nonatomic, assign) NSInteger cid;


@end
