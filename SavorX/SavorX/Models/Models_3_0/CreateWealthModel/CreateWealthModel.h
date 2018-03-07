//
//  CreateWealthModel.h
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/3.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import "BaseModel.h"

@interface CreateWealthModel : BaseModel

@property(nonatomic, copy) NSString * artid;
@property(nonatomic, copy) NSString *sort_num;
@property(nonatomic, assign) NSInteger type;
@property(nonatomic, assign) NSInteger imgStyle;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *imageURL;
@property(nonatomic, copy) NSString *contentURL;
@property(nonatomic, copy) NSString *sourceName;
@property(nonatomic, copy) NSString *logo;
@property(nonatomic, copy) NSString *indexImageUrl;

@property(nonatomic, assign) NSInteger canplay;
@property(nonatomic, assign) NSInteger duration;
@property(nonatomic, copy) NSString *mediaId;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *updateTime;
@property(nonatomic, copy) NSString *videoURL;
@property (nonatomic, assign) NSInteger canPlay;
@property (nonatomic, copy) NSString *colTuJi;
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
@property (nonatomic, assign) NSInteger shareType;//非接口返回，用于分享类型(1代表专题组首页分享)

@end
