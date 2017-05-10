//
//  RDAwardTool.h
//  SavorX
//
//  Created by 郭春城 on 2017/5/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDAwardTool : NSObject

//检测当前是否可以进行抽奖
+ (BOOL)awardCanAwardWithAPILottery_num:(NSInteger)lottery_num;

//进行了一次抽奖
+ (void)awardHasAwardWithResult:(BOOL)isSuccess;

//保存抽奖次数
+ (void)awardSaveAwardNumber:(NSInteger)number;

//是否应该中奖
+ (BOOL)awardShouldWin;

@end
