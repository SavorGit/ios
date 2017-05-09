//
//  HSEggsResultModel.h
//  SavorX
//
//  Created by 王海朋 on 2017/5/9.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseModel.h"

@interface HSEggsResultModel : BaseModel

//砸蛋进度
@property (nonatomic, assign) NSInteger progress;

//是否已砸开，0否1是
@property (nonatomic, assign) NSInteger done;

//是否中奖，0否1是
@property (nonatomic, assign) NSInteger win;

//中奖提示语
@property (nonatomic, copy) NSString *info;

@end
