//
//  SXDlnaView.h
//  SavorX
//
//  Created by lijiawei on 16/12/13.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseView.h"
@protocol SXDlnaViewDelegate;

@interface SXDlnaView : BaseView

@property (weak, nonatomic) IBOutlet UIImageView *wifiBgView;
@property (weak, nonatomic) IBOutlet UILabel *wifiCountLabel;

@property(nonatomic,weak)id<SXDlnaViewDelegate>delegate;

-(void)startWiFiAnimation;
-(void)stopWiFiAnimation;

@end



@protocol SXDlnaViewDelegate <NSObject>

-(void)dlnaView:(SXDlnaView *)view;

@end
