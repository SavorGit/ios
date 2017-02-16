//
//  HSHotelVodListRequest.h
//  SavorX
//
//  Created by 郭春城 on 17/2/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSHotelVodListRequest : BGNetworkRequest

- (instancetype)initWithHotelID:(NSInteger)hotelID andPageNo:(NSInteger)pageNo andPageSize:(NSInteger)pageSize createTime:(NSInteger)createTime;

@end
