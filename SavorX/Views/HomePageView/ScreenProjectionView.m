//
//  ScreenProjectionView.m
//  SavorX
//
//  Created by lijiawei on 17/1/20.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "ScreenProjectionView.h"
#import "HomeAnimationView.h"

@interface ScreenProjectionView ()

@property (weak, nonatomic) IBOutlet UILabel *wifiLabel;
@property (weak, nonatomic) IBOutlet UIButton *setWifiButton;
@property (nonatomic, assign) WifiState state;
/**
 *  选择的block
 */
@property (nonatomic, copy) ScreenProjectionSelectViewSelectBlock selectBlock;

@end

@implementation ScreenProjectionView

+ (instancetype)showScreenProjectionTitle:(NSString *)title wifiState:(WifiState)wifistate  block:(ScreenProjectionSelectViewSelectBlock)selectBlock{
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    ScreenProjectionView *screenProjectView = [ScreenProjectionView loadFromXib];
    screenProjectView.frame = keyWindow.bounds;
    screenProjectView.bottom = keyWindow.top;
    
    [screenProjectView.setWifiButton.layer setMasksToBounds:YES];
    [screenProjectView.setWifiButton.layer setCornerRadius:5];
    [screenProjectView.setWifiButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [screenProjectView.setWifiButton.layer setShadowRadius:10.0];
    [screenProjectView.setWifiButton.layer setBorderWidth:1.0];
    
    screenProjectView.selectBlock = selectBlock;
    
    if (wifistate == KWifi_NoLinkWifi) {
        screenProjectView.wifiLabel.text = @"您当前没有连接wifi，如需投屏请确保wifi开启并与需要投屏的电视保证在同一环境下";
        [screenProjectView.setWifiButton setTitle:@"去设置" forState:UIControlStateNormal];
    }else if (wifistate == kWifi_NolinkDevice) {
        screenProjectView.wifiLabel.text = @"您当前连接的wifi网段内，没有发现可连接设备。如需投屏请确保wifi开启并与需要投屏的电视保证在同一环境下";
        [screenProjectView.setWifiButton setTitle:@"去设置" forState:UIControlStateNormal];
    }else if (wifistate == kWifi_LinkRDBox) {
        screenProjectView.wifiLabel.text = @"已连接电视，点击下方功能即可大屏分享";
        [screenProjectView.setWifiButton setTitle:@"断开连接" forState:UIControlStateNormal];
    }else if (wifistate == kWifi_LinkDLNA) {
        screenProjectView.wifiLabel.text = [NSString stringWithFormat:@"您已成功连接\"%@\"，点击下列分类选择文件即可电视投屏", [GlobalData shared].DLNADevice.name];
        [screenProjectView.setWifiButton setTitle:@"断开连接" forState:UIControlStateNormal];
    }else if (wifistate == kWifi_HaveRDBox) {
        screenProjectView.wifiLabel.text = @"您当前连接的wifi内，发现可连接设备。如需投屏请点击下方按钮进行设备连接";
        [screenProjectView.setWifiButton setTitle:@"连接设备" forState:UIControlStateNormal];
    }else if (wifistate == kWifi_HaveDLNA) {
        screenProjectView.wifiLabel.text = @"您当前连接的wifi内，发现可连接设备。如需投屏请点击下方按钮进行设备连接";
        [screenProjectView.setWifiButton setTitle:@"连接设备" forState:UIControlStateNormal];
    }
    screenProjectView.state = wifistate;
    
    [keyWindow addSubview:screenProjectView];
    [screenProjectView showViewWithAnimationDuration:.3f];
    return screenProjectView;
}


#pragma mark - show view
-(void)showViewWithAnimationDuration:(float)duration{
    if ([GlobalData shared].isScreenProjectionView) {
        return;
    }
    [GlobalData shared].isScreenProjectionView = YES;
    [UIView animateWithDuration:duration animations:^{
        self.backgroundColor = RGBA(0, 0, 0, 0.8);
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        self.bottom = keyWindow.bottom;
    } completion:^(BOOL finished) {
    }];
}

-(void)dismissViewWithAnimationDuration:(float)duration{
    [UIView animateWithDuration:duration animations:^{

        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        self.bottom = keyWindow.top;

    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [GlobalData shared].isScreenProjectionView = NO;
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)videoAction:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    [self selectBtnindex:btn.tag];
    
}
- (IBAction)pictureAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self selectBtnindex:btn.tag];
}
- (IBAction)slideAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self selectBtnindex:btn.tag];
}
- (IBAction)wifiStateAction:(id)sender {
    [self dismissViewWithAnimationDuration:.4f];
    [[HomeAnimationView animationView] scanQRCode];
}
- (IBAction)fileAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self selectBtnindex:btn.tag];
}
- (IBAction)closeAction:(id)sender {
    
    [self dismissViewWithAnimationDuration:0.4f];
}

-(void)selectBtnindex:(NSInteger)index{
    if(_selectBlock){
        _selectBlock(index);
        _selectBlock = nil;
    }
    [self dismissViewWithAnimationDuration:0.4f];
}

@end
