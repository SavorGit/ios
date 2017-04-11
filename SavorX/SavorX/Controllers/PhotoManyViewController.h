//
//  PhotoManyViewController.h
//  SavorX
//
//  Created by 郭春城 on 17/2/13.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseViewController.h"

@interface PhotoManyViewController : BaseViewController

- (instancetype)initWithPHAssetSource:(id)source andIndex:(NSInteger)index;

- (void)stopScreenImage:(BOOL)fromHomeType;

@end
