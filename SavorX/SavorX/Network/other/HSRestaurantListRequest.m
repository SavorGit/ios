//
//  HSRestaurantListRequest.m
//  SavorX
//
//  Created by 王海朋 on 2017/5/24.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSRestaurantListRequest.h"

@implementation HSRestaurantListRequest

- (instancetype)initWithHotelId:(NSInteger )hotelId lng:(NSString *)lng lat:(NSString *)lat pageNum:(NSUInteger )pageNum{
    
    if (self = [super init]) {
        
        self.methodName = [NSString stringWithFormat:@"Screendistance/distance/getAllDistance?%@&lat=%@&lng=%@&hotelid=%ld&pageNum=%ld", [Helper getURLPublic], lat, lng, hotelId, pageNum];
        self.httpMethod = BGNetworkRequestHTTPGet;

    }
    return self;
}

@end
