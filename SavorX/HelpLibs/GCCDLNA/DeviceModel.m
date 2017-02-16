//
//  DeviceModel.m
//  DLNATest
//
//  Created by 郭春城 on 16/10/10.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "DeviceModel.h"

@implementation DeviceModel

- (instancetype)init
{
    if (self = [super init]) {
        self.AVTransport = [[AVTransportModel alloc] init];
        self.Rendering = [[AVTransportModel alloc] init];
    }
    return self;
}

@end
