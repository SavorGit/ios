//
//  ImageAtlasDetailModel.h
//  SavorX
//
//  Created by 王海朋 on 2017/7/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageAtlasDetailModel : BaseModel

// 图片介绍
@property(nonatomic, strong) NSString *atext;
// 图片地址
@property(nonatomic, strong) NSString *pic_url;

@end
