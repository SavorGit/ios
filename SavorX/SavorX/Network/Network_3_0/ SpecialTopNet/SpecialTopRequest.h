//
//  SpecialTopRequest.h
//  SavorX
//
//  Created by 王海朋 on 2017/7/11.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface SpecialTopRequest : BGNetworkRequest

- (instancetype)initWithSortNum:(NSString *)sortNum;

@end
