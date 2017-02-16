//
//  HSCategoryListRequest.m
//  HotSpot
//
//  Created by lijiawei on 16/12/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "HSCategoryListRequest.h"
#import "HSCategoryModel.h"
#import "Jastor.h"

@implementation HSCategoryListRequest

-(instancetype)init{
    
    if(self = [super init]){
        self.methodName = @"getCategoryList";
        self.httpMethod = BGNetworkRequestHTTPPost;
    }
    return self;
}

-(id)processResponseObject:(id)responseObject{
    
    NSDictionary *dic = (NSDictionary *)responseObject;
    NSArray *listAry = dic[@"result"];
    
    NSMutableArray *mutableArr = [NSMutableArray array];
    for(NSDictionary *dict in listAry){
        HSCategoryModel *model = [[HSCategoryModel alloc] initWithDictionary:dict];
        [mutableArr addObject:model];
    }
    
    [SAVORXAPI saveFileOnPath:CategoryListCache withArray:listAry];
    
    return mutableArr;
}

@end
