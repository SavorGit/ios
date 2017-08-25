//
//  HSCollectoinListRequest.h
//  SavorX
//
//  Created by 郭春城 on 2017/7/12.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSCollectoinListRequest : BGNetworkRequest

- (instancetype)initWithCreateTime:(NSString *)createTime;

@end
