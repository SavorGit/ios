//
//  RDAwardTool.m
//  SavorX
//
//  Created by 郭春城 on 2017/5/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDAwardTool.h"
#import "GCCKeyChain.h"

#define RDAwardInfo @"RDAwardInfo"
#define RDAwardDate @"RDAwardDate" //抽奖存储在钥匙串中的日期
#define RDAwardNumber @"RDAwardNumber" //抽奖存储在钥匙串中的对应数量
#define RDAwardHangerNumber @"RDAwardHangerNumber" //抽奖存储在钥匙串中的第几次将会中奖
#define RDAwardCurrentNumber @"RDAwardCurrentNumber" //抽奖存储在钥匙串中的当前抽奖时间

@implementation RDAwardTool

//检测当前是否可以进行抽奖
+ (BOOL)awardCanAwardWithAPILottery_num:(NSInteger)lottery_num
{
    NSInteger number = lottery_num;
    
    if ([RDAwardTool checkRDAwardDateIsEnable]) {
        NSDictionary * dict = [GCCKeyChain load:RDAwardInfo];
        number = [[dict objectForKey:RDAwardNumber] integerValue];
    }
    
    if (number > 0) {
        return YES;
    }
    
    return NO;
}

//进行了一次抽奖
+ (void)awardHasAwardWithResult:(BOOL)isSuccess
{
    if ([RDAwardTool checkRDAwardDateIsEnable]) {
        NSDictionary * dict = [GCCKeyChain load:RDAwardInfo];
        
        NSMutableDictionary * tempdict = [NSMutableDictionary dictionaryWithDictionary:dict];
        
        //处理当前的抽奖总次数
        NSInteger number = [[dict objectForKey:RDAwardNumber] integerValue];
        number -= 1;
        [tempdict setObject:[NSNumber numberWithInteger:number] forKey:RDAwardNumber];
        
        //处理当前已经抽奖的次数
        NSInteger currentNumber = [[dict objectForKey:RDAwardCurrentNumber] integerValue];
        currentNumber += 1;
        [tempdict setObject:[NSNumber numberWithInteger:currentNumber] forKey:RDAwardCurrentNumber];
        
        dict = [NSDictionary dictionaryWithDictionary:tempdict];
        [GCCKeyChain save:RDAwardInfo data:dict];
    }
}

//保存抽奖次数
+ (void)awardSaveAwardNumber:(NSInteger)number
{
    if ([RDAwardTool checkRDAwardDateIsEnable]) {
        
        
        
    }else{
        NSDictionary * dict = @{RDAwardDate : [Helper getCurrentTimeWithFormat:@"yyyyMMdd"],
                                RDAwardNumber : [NSNumber numberWithInteger:number],
                                RDAwardCurrentNumber : [NSNumber numberWithInteger:0],
                                RDAwardHangerNumber : [NSNumber numberWithInteger:(arc4random() % 5 + 1)]};
        [GCCKeyChain save:RDAwardInfo data:dict];
    }
}

+ (BOOL)awardShouldWin
{
    if ([RDAwardTool checkRDAwardDateIsEnable]) {
        NSDictionary * dict = [GCCKeyChain load:RDAwardInfo];
        NSInteger hangerNumber = [[dict objectForKey:RDAwardHangerNumber] integerValue];
        NSInteger currentNumber = [[dict objectForKey:RDAwardCurrentNumber] integerValue];
        NSInteger nextNumber = currentNumber + 1;
        if (nextNumber == hangerNumber) {
            return YES;
        }
    }
    
    return NO;
}

//检测当前的抽奖信息是否有效
+ (BOOL)checkRDAwardDateIsEnable
{
    if ([GCCKeyChain load:RDAwardInfo]) {
        
        NSDictionary * dict = [GCCKeyChain load:RDAwardInfo];
        
        NSString * awardDate = [dict objectForKey:RDAwardDate];
        NSString * date = [Helper getCurrentTimeWithFormat:@"yyyyMMdd"];
        
        if ([awardDate isEqualToString:date]) {
            return YES;
        }else{
            [GCCKeyChain deleteDataForKey:RDAwardInfo];
            return NO;
        }
    }
    return NO;
}

@end
