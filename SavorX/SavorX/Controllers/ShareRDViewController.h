//
//  ShareRDViewController.h
//  SavorX
//
//  Created by 郭春城 on 2017/4/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseViewController.h"

typedef enum : NSUInteger {
    SHARERDTYPE_APPLICATION,
    SHARERDTYPE_GAME
} SHARERDTYPE;

@interface ShareRDViewController : BaseViewController

- (instancetype)initWithType:(SHARERDTYPE)type;

@end
