//
//  SXWiFiCell.h
//  SavorX
//
//  Created by lijiawei on 16/12/13.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCell.h"
#import "DeviceModel.h"

@protocol SXWiFiCellDelegate;

@interface SXWiFiCell : BaseCell

@property(nonatomic,weak)id<SXWiFiCellDelegate>delegate;
@property (nonatomic, strong) DeviceModel * deviceModel;

@end

@protocol SXWiFiCellDelegate <NSObject>

-(void)wifiCell:(SXWiFiCell *)cell didSelected:(BOOL)isSelected;

@end
