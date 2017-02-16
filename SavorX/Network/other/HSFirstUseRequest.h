//
//  HSFirstUseRequest.h
//  SavorX
//
//  Created by 郭春城 on 17/2/12.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSFirstUseRequest : BGNetworkRequest

- (instancetype)initWithHotelId:(NSInteger)hotelId;

@end
