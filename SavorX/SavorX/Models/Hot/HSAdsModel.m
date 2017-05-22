//
//  HSAdsModel.m
//  SavorX
//
//  Created by 郭春城 on 17/2/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSAdsModel.h"

@implementation HSAdsModel

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        self.type = HSAdsModelType_AD;
    }
    return self;
}

- (id)initAwardWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        self.type = HSAdsModelType_AWARD;
    }
    return self;
}

-(NSDictionary *)attrMapDict{
    
    return @{@"cid":@"id"};
    
}

@end
