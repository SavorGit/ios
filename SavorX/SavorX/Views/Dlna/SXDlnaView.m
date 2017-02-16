//
//  SXDlnaView.m
//  SavorX
//
//  Created by lijiawei on 16/12/13.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "SXDlnaView.h"

@interface SXDlnaView()

@property (weak, nonatomic) IBOutlet UIImageView *wifiImageView;

@property (weak, nonatomic) IBOutlet UILabel *wifTitleLabel;

@end

@implementation SXDlnaView


-(void)awakeFromNib
{
    [super awakeFromNib];
    NSArray *wifiImageArys = @[[UIImage imageNamed:@"wifi1.png"],[UIImage imageNamed:@"wifi2.png"],[UIImage imageNamed:@"wifi3.png"],[UIImage imageNamed:@"wifi4.png"]];
    _wifiImageView.image = [UIImage imageNamed:@"wifi4.png"];
    self.backgroundColor = [UIColor clearColor];
    _wifiImageView.animationImages = wifiImageArys;
    _wifiImageView.contentMode = UIViewContentModeScaleAspectFill;
    _wifiImageView.clipsToBounds = YES;
    _wifiImageView.animationDuration = 2;
    _wifiImageView.animationRepeatCount = 0;
    
    NSString *wifiName = [Helper getWifiName];
    self.wifTitleLabel.text = wifiName.length?wifiName:@"未连接到WiFi";
    
}

-(void)startWiFiAnimation{
    
    [_wifiImageView startAnimating];
}

-(void)stopWiFiAnimation{
    
    [_wifiImageView stopAnimating];
}


- (IBAction)wifiButonAction:(id)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(dlnaView:)])
    {
        [_delegate dlnaView:self];
    }
}

@end
