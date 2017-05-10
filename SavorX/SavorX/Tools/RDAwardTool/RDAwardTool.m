//
//  RDAwardTool.m
//  SavorX
//
//  Created by 郭春城 on 2017/5/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDAwardTool.h"
#import "GCCKeyChain.h"
#import "HSAwardUploadRequest.h"

//存储在钥匙串中的抽奖相关信息
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
    
    //检测钥匙串存储的抽奖信息有效性
    if ([RDAwardTool checkRDAwardDateIsEnable]) {
        //如果存在有效抽奖信息，则取出信息
        NSDictionary * dict = [GCCKeyChain load:RDAwardInfo];
        //将本地存储的有效次数赋值到number
        number = [[dict objectForKey:RDAwardNumber] integerValue];
    }
    
    if (number > 0) {
        return YES;
    }
    
    return NO;
}

//进行了一次抽奖
+ (void)awardHasAwardWithResultModel:(HSEggsResultModel *)model
{
    //检测钥匙串存储的抽奖信息有效性
    if ([RDAwardTool checkRDAwardDateIsEnable]) {
        
        //如果存在有效抽奖信息，则取出信息
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
    
    //日志上报
    HSAwardUploadRequest * request = [[HSAwardUploadRequest alloc] initWithPrizeid:model.prize_id andPrizeTime:model.prize_time];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

//保存抽奖次数
+ (void)awardSaveAwardNumber:(NSInteger)number
{
    //检测钥匙串存储的抽奖信息有效性
    if ([RDAwardTool checkRDAwardDateIsEnable]) {
        
        
        
    }else{
        NSDictionary * dict = @{RDAwardDate : [Helper getCurrentTimeWithFormat:@"yyyyMMdd"],
                                RDAwardNumber : [NSNumber numberWithInteger:number],
                                RDAwardCurrentNumber : [NSNumber numberWithInteger:0],
                                RDAwardHangerNumber : [NSNumber numberWithInteger:(arc4random() % 5 + 1)]};
        [GCCKeyChain save:RDAwardInfo data:dict];
    }
}

//是否应该中奖
+ (BOOL)awardShouldWin
{
    //检测钥匙串存储的抽奖信息有效性
    if ([RDAwardTool checkRDAwardDateIsEnable]) {
        //如果存在有效抽奖信息，则取出信息
        NSDictionary * dict = [GCCKeyChain load:RDAwardInfo];
        
        //获取第几次应该中奖
        NSInteger hangerNumber = [[dict objectForKey:RDAwardHangerNumber] integerValue];
        //获取当前抽了几次奖
        NSInteger currentNumber = [[dict objectForKey:RDAwardCurrentNumber] integerValue];
        //判断下一次的抽奖是否应该中奖
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
        //如果存在抽奖信息，则取出信息
        NSDictionary * dict = [GCCKeyChain load:RDAwardInfo];
        
        NSString * awardDate = [dict objectForKey:RDAwardDate];
        NSString * date = [Helper getCurrentTimeWithFormat:@"yyyyMMdd"];
        
        //获取信息中的日期与当前日期进行比对，判断有效性
        if ([awardDate isEqualToString:date]) {
            return YES;
        }else{
            //若存在的是无效信息则进行删除
            [GCCKeyChain deleteDataForKey:RDAwardInfo];
            return NO;
        }
    }
    return NO;
}

@end
