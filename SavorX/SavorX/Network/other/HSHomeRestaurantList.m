//
//  HSHomeRestaurantList.m
//  SavorX
//
//  Created by 王海朋 on 2017/5/24.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSHomeRestaurantList.h"

@implementation HSHomeRestaurantList

- (instancetype)initWithLng:(NSString *)lng lat:(NSString *)lat{
    
    if (self = [super init]) {
        
        self.methodName = [NSString stringWithFormat:@"Screendistance/distance/getHotelDistance?lat=%@&lng=%@&hotelid=%ld",lat,lng,[GlobalData shared].hotelId];
        self.httpMethod = BGNetworkRequestHTTPGet;
        
    }
    return self;
}

@end
