//
//  RestaurantListModel.h
//  SavorX
//
//  Created by 王海朋 on 2017/5/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseModel.h"

@interface RestaurantListModel : BaseModel

//餐厅名字
@property (nonatomic, copy) NSString *name;

//距离
@property (nonatomic, copy) NSString *dis;

//地址
@property (nonatomic, copy) NSString *addr;

//id
@property (nonatomic, assign) NSInteger id;

//纬度
@property (nonatomic, copy) NSString *lat;

//经度
@property (nonatomic, copy) NSString *lng;

@end
