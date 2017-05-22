//
//  HSAwardUploadRequest.h
//  SavorX
//
//  Created by 郭春城 on 2017/5/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSAwardUploadRequest : BGNetworkRequest

- (instancetype)initWithPrizeid:(NSInteger)prizeid andPrizeTime:(NSString *)prizeTime;

@end
