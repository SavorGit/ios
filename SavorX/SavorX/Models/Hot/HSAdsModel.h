//
//  HSAdsModel.h
//  SavorX
//
//  Created by 郭春城 on 17/2/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseModel.h"

@interface HSAdsModel : BaseModel

@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * imageURL;
@property (nonatomic, assign) NSInteger duration;

@end
