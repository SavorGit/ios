//
//  HSInstallationInforUpload.h
//  SavorX
//
//  Created by 王海朋 on 2017/5/2.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSInstallationInforUpload : BGNetworkRequest

- (instancetype)initWithHotelId:(NSString *)hotelId waiterId:(NSString *)waiterId andSt:(NSString *)st;

@end
