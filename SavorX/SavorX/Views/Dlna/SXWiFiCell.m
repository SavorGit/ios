//
//  SXWiFiCell.m
//  SavorX
//
//  Created by lijiawei on 16/12/13.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "SXWiFiCell.h"


@interface SXWiFiCell ()
@property (weak, nonatomic) IBOutlet UIImageView *spotImageView;
@property (weak, nonatomic) IBOutlet UILabel *wifiTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *linkButton;

@end

@implementation SXWiFiCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setDeviceModel:(DeviceModel *)deviceModel
{
    _deviceModel = deviceModel;
    self.wifiTitleLabel.text = deviceModel.name;
    NSString *uuidstr =  [GlobalData shared].DLNADevice.UUID;
    if([self.deviceModel.UUID isEqualToString:uuidstr]){
        [self showSpotImage];
        [_linkButton setBackgroundImage:[UIImage imageNamed:@"wifi_link.png"] forState:UIControlStateNormal];
        [_linkButton setTitleColor:UIColorFromRGB(0xa695728) forState:UIControlStateNormal];
        [_linkButton setTitle:@"已连接" forState:UIControlStateNormal];
        
        self.wifiTitleLabel.textColor = UIColorFromRGB(0xa5915f);
    }else{
        [_linkButton setBackgroundImage:[UIImage imageNamed:@"wifi_no_link.png"] forState:UIControlStateNormal];
        [_linkButton setTitle:@"连  接" forState:UIControlStateNormal];
         [_linkButton setTitleColor:UIColorFromRGB(0xc4b48b) forState:UIControlStateNormal];
       
        self.wifiTitleLabel.textColor = UIColorFromRGB(0xc8c0aa);
        [self hideSpotImage];
    }
}



- (void)hideSpotImage{
    
    self.spotImageView.hidden = YES;
    
}
- (void)showSpotImage{
    self.spotImageView.hidden = NO;
    
}

- (IBAction)wifiLinkButtonAction:(id)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(wifiCell:didSelected:)])
    {
        [_delegate wifiCell:self didSelected:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
