//
//  HSHomeRestaurantList.h
//  SavorX
//
//  Created by 王海朋 on 2017/5/24.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

// 此类用于获取首页三条餐厅列表
@interface HSHomeRestaurantList : BGNetworkRequest

- (instancetype)initWithLng:(NSString *)lng lat:(NSString *)lat;

@end
