//
//  CreateWealthModel.h
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/3.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateWealthModel : BaseModel

//@property(nonatomic, assign) NSInteger type;
//@property(nonatomic, strong) NSString *title;
//@property(nonatomic, strong) NSString *subTitle;
//@property(nonatomic, strong) NSString *source;
//@property(nonatomic, strong) NSString *time;
//@property(nonatomic, strong) NSString *sourceImage;
//@property(nonatomic, strong) NSString *imageUrl;


@property(nonatomic, assign) NSInteger artid;
@property(nonatomic, strong) NSString *sort_num;
@property(nonatomic, assign) NSInteger type;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *imageURL;
@property(nonatomic, strong) NSString *contentURL;
//@property(nonatomic, strong) NSString *acreateTime;
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
@property (nonatomic, assign) NSInteger createTime; //创建时间

//非接口返回
@property (nonatomic, assign) NSInteger cid;


@end
