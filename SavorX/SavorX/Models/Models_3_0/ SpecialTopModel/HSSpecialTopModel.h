//
//  HSSpecialTopModel.h
//  SavorX
//
//  Created by 王海朋 on 2017/7/11.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseModel.h"

@interface HSSpecialTopModel : BaseModel

@property(nonatomic, assign) NSInteger artid;
@property(nonatomic, strong) NSString *sort_num;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *imageURL;
@property(nonatomic, strong) NSString *contentURL;
@property(nonatomic, strong) NSString *shareTitle;
@property(nonatomic, strong) NSString *updateTime;
@property(nonatomic, assign) NSInteger collected;
//非接口返回
@property(nonatomic, assign) NSInteger type;

@end
