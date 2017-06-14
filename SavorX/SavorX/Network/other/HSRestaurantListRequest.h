//
//  HSRestaurantListRequest.h
//  SavorX
//
//  Created by 王海朋 on 2017/5/24.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

// 此类用于获取所有餐厅列表
@interface HSRestaurantListRequest : BGNetworkRequest

- (instancetype)initWithHotelId:(NSInteger )hotelId lng:(NSString *)lng lat:(NSString *)lat pageNum:(NSUInteger )pageNum;

@end
