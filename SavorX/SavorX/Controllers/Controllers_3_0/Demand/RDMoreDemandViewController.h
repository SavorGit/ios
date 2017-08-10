//
//  RDMoreDemandViewController.h
//  SavorX
//
//  Created by 郭春城 on 2017/8/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseViewController.h"

@protocol RDMoreDemandDelegate <NSObject>

- (void)playOnTVButtonDidClickedWithModel:(CreateWealthModel *)model;

@end

@interface RDMoreDemandViewController : BaseViewController

@property (nonatomic, assign) id<RDMoreDemandDelegate> delegate;

- (instancetype)initWithModelSource:(NSArray *)source;

@end
