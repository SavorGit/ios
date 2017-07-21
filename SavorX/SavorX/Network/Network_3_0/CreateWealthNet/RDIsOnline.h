//
//  RDIsOnline.h
//  SavorX
//
//  Created by 郭春城 on 2017/7/21.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <BGNetwork/BGNetwork.h>

@interface RDIsOnline : BGNetworkRequest

- (instancetype)initWithArtID:(NSString *)artID;

@end
