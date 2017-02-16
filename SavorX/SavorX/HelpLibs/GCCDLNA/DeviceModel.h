//
//  DeviceModel.h
//  DLNATest
//
//  Created by 郭春城 on 16/10/10.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVTransportModel.h"

@interface DeviceModel : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * UUID;
@property (nonatomic, strong) NSString * headerURL;
@property (nonatomic, strong) AVTransportModel * AVTransport;
@property (nonatomic, strong) AVTransportModel * Rendering;

@end
