//
//  VoideoPlayStatusCell.h
//  SavorX
//
//  Created by lijiawei on 17/2/8.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "BaseCell.h"

@protocol VoideoPlayStatusCellDelegate;

@interface VoideoPlayStatusCell : BaseCell

@property(nonatomic,weak)id<VoideoPlayStatusCellDelegate>delegate;

@end


@protocol VoideoPlayStatusCellDelegate <NSObject>

-(void)voideoPlayStatusCellConnectAction;

@end
