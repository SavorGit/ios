//
//  HSAdsModel.h
//  SavorX
//
//  Created by 郭春城 on 17/2/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseModel.h"

typedef enum : NSUInteger {
    HSAdsModelType_AD,
    HSAdsModelType_AWARD
} HSAdsModelType;

@interface HSAdsModel : BaseModel

//当前类型是广告类型还是奖品类型
@property (nonatomic, assign) HSAdsModelType type;

//广告和奖品类型通用参数
@property (nonatomic, copy) NSString * imageURL;


//广告类型参数
@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, assign) NSInteger duration;

//奖品类型参数
@property (nonatomic, copy) NSString * award_start_time;
@property (nonatomic, copy) NSString * award_end_time;

- (id)initAwardWithDictionary:(NSDictionary *)dictionary;

@end
