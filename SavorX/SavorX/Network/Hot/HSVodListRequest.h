//
//  HSVodListRequest.h
//  HotSpot
//
//  Created by lijiawei on 16/12/7.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface HSVodListRequest : BGNetworkRequest

- (instancetype)initWithPageNo:(NSInteger)pageNo andPageSize:(NSInteger)pageSize createTime:(NSInteger)createTime;

@end
