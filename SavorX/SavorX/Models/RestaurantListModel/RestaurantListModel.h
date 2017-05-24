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
@property (nonatomic, assign) NSString *title;

//距离
@property (nonatomic, assign) NSString *distance;

//地址
@property (nonatomic, assign) NSString *address;

@end
