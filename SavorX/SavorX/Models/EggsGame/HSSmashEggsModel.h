//
//  HSSmashEggsModel.h
//  SavorX
//
//  Created by 王海朋 on 2017/7/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseModel.h"

@interface HSSmashEggsModel : BaseModel

//奖品类型参数
@property (nonatomic, copy) NSString * award_start_time;
@property (nonatomic, copy) NSString * award_end_time;
@property (nonatomic, assign) NSInteger lottery_num;

@end
