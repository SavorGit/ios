//
//  CreateWealthModel.h
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/3.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateWealthModel : NSObject

@property(nonatomic, assign) NSInteger type;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *subTitle;
@property(nonatomic, strong) NSString *source;
@property(nonatomic, strong) NSString *time;
@property(nonatomic, strong) NSString *sourceImage;
@property(nonatomic, strong) NSString *imageUrl;

@end
