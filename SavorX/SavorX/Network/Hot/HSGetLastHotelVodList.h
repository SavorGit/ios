//
//  HSGetLastHotelVodList.h
//  SavorX
//
//  Created by 郭春城 on 17/2/14.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSGetLastHotelVodList : BGNetworkRequest

- (instancetype)initWithHotelId:(NSInteger)hotelId createTime:(NSInteger)createTime flag:(NSString *)flag;

@end
