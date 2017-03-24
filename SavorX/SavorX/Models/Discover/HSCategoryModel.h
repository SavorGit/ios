//
//  HSCategoryModel.h
//  HotSpot
//
//  Created by lijiawei on 16/12/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseModel.h"

@interface HSCategoryModel : BaseModel

@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString * englishName;

@end
