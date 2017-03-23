//
//  HSLauchImageOrVideoRequest.h
//  SavorX
//
//  Created by 王海朋 on 17/3/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSLauchImageOrVideoRequest : BGNetworkRequest

- (instancetype)initWithDeviceIdentification:(NSString *)identification;

@end
