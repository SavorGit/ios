//
//  RDTabScrollItem.h
//  小热点切换
//
//  Created by 郭春城 on 2017/6/29.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDTabScrollItem : UIView

- (instancetype)initWithFrame:(CGRect)frame info:(NSString *)name index:(NSInteger)index;

- (void)configWithInfo:(NSString *)name index:(NSInteger)index;

@end
