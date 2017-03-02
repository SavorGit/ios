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

@property (weak, nonatomic) IBOutlet UIButton *setWifiButton;
@property (strong, nonatomic)  UILabel *wifiLabel;
@property (nonatomic, strong)  UIView *smallBgView;
@property (nonatomic, strong)  UIButton *pictureBtn;
@property (nonatomic, strong)  UIButton *fileBtn;
@property (nonatomic, strong)  UIButton *slideBtn;
@property (nonatomic, strong)  UIButton *videoBtn;
@property (nonatomic, strong)  UIButton *closeViewBtn;

@property (nonatomic, assign) WifiState state;
/**
 *  选择的block
 */
@property (nonatomic, copy) ScreenProjectionSelectViewSelectBlock selectBlock;

@end

@implementation ScreenProjectionView


+ (instancetype)shareStance{
    static ScreenProjectionView * screenObject = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        screenObject=[[ScreenProjectionView alloc] init];
    });
    return screenObject;
}

-(id)init
{
    if (self = [super init]) {
    }
    return self;
}
- (instancetype)showScreenProjectionTitle:(NSString *)title wifiState:(WifiState)wifistate  block:(ScreenProjectionSelectViewSelectBlock)selectBlock{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    //    ScreenProjectionView *self = [ScreenProjectionView loadFromXib];
    self.frame = keyWindow.bounds;
    self.bottom = keyWindow.top;
    [self creadUI];
    self.selectBlock = selectBlock;
    
    NSString *wifiLabelStr;
    if (wifistate == KWifi_NoLinkWifi) {
        wifiLabelStr = @"您当前没有连接wifi，如需投屏请确保wifi开启并与需要投屏的电视保证在同一环境下";
        [self.setWifiButton setTitle:@"去设置" forState:UIControlStateNormal];
    }else if (wifistate == kWifi_NolinkDevice) {
        wifiLabelStr = @"您当前连接的wifi网段内，没有发现可连接设备。如需投屏请确保wifi开启并与需要投屏的电视保证在同一环境下";
        [self.setWifiButton setTitle:@"去设置" forState:UIControlStateNormal];
    }else if (wifistate == kWifi_LinkRDBox) {
        wifiLabelStr = @"已连接电视，点击下方功能即可大屏分享";
        [self.setWifiButton setTitle:@"断开连接" forState:UIControlStateNormal];
    }else if (wifistate == kWifi_LinkDLNA) {
        wifiLabelStr = [NSString stringWithFormat:@"您已成功连接\"%@\"，点击下列分类选择文件即可电视投屏", [GlobalData shared].DLNADevice.name];
        [self.setWifiButton setTitle:@"断开连接" forState:UIControlStateNormal];
    }else if (wifistate == kWifi_HaveRDBox) {
        wifiLabelStr = @"您当前连接的wifi内，发现可连接设备。如需投屏请点击下方按钮进行设备连接";
        [self.setWifiButton setTitle:@"连接设备" forState:UIControlStateNormal];
    }else if (wifistate == kWifi_HaveDLNA) {
        wifiLabelStr = @"您当前连接的wifi内，发现可连接设备。如需投屏请点击下方按钮进行设备连接";
        [self.setWifiButton setTitle:@"连接设备" forState:UIControlStateNormal];
    }
    
    CGSize labelSize = {0, 0};
    labelSize = [wifiLabelStr sizeWithFont:[UIFont               systemFontOfSize:14.0]
                         constrainedToSize:CGSizeMake(200.0, 5000)
                             lineBreakMode:UILineBreakModeWordWrap];
    self.wifiLabel.numberOfLines = 0;
    self.wifiLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    self.wifiLabel.frame = CGRectMake(self.wifiLabel.frame.origin.x, self.wifiLabel.frame.origin.y, self.wifiLabel.frame.size.width, labelSize.height);
    self.wifiLabel.text = wifiLabelStr;
    
    self.state = wifistate;
    
    [keyWindow addSubview:self];
    [self showViewWithAnimationDuration:.3f];
    return self;
}

- (void)creadUI{
    
    self.smallBgView = [[UIView alloc] init];
    self.wifiLabel = [[UILabel alloc] init];
    self.wifiLabel.textColor = [UIColor whiteColor];
    
    self.closeViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeViewBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.closeViewBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.pictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pictureBtn setImage:[UIImage imageNamed:@"picture"] forState:UIControlStateNormal];
    [self.pictureBtn addTarget:self action:@selector(pictureAction:) forControlEvents:UIControlEventTouchUpInside];
    self.pictureBtn.tag = 1;
    
    self.fileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fileBtn setImage:[UIImage imageNamed:@"file"] forState:UIControlStateNormal];
    [self.fileBtn addTarget:self action:@selector(fileAction:) forControlEvents:UIControlEventTouchUpInside];
    self.fileBtn.tag = 3;
    
    self.slideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.slideBtn setImage:[UIImage imageNamed:@"slide"] forState:UIControlStateNormal];
    [self.slideBtn addTarget:self action:@selector(slideAction:) forControlEvents:UIControlEventTouchUpInside];
    self.slideBtn.tag = 2;
    
    self.videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.videoBtn setImage:[UIImage imageNamed:@"video"] forState:UIControlStateNormal];
    [self.videoBtn addTarget:self action:@selector(videoAction:) forControlEvents:UIControlEventTouchUpInside];
    self.videoBtn.tag = 0;
    
    [self addSubview:self.smallBgView];
    [self addSubview:self.wifiLabel];
    [self addSubview:self.closeViewBtn];
    [self.smallBgView addSubview:self.pictureBtn];
    [self.smallBgView addSubview:self.fileBtn];
    [self.smallBgView addSubview:self.slideBtn];
    [self.smallBgView addSubview:self.videoBtn];
    
    [self.wifiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kMainBoundsWidth - 50);
        make.top.mas_equalTo(100);
        make.left.mas_equalTo(25);
        make.right.mas_equalTo(-25);
    }];
    
    [self.smallBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(198);
        make.top.mas_equalTo(260);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.width.mas_equalTo(kMainBoundsWidth - 40);
    }];
    
    int distance = (kMainBoundsWidth - 40 - 280)/5;
    
    [self.pictureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 70));
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(self.smallBgView.mas_left).offset(distance);
        
    }];
    
    [self.fileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 70));
        make.top.mas_equalTo(20);
        make.left.mas_equalTo (self.pictureBtn.mas_right).offset(distance);
        
    }];
    
    [self.slideBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 70));
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(self.fileBtn.mas_right).offset(distance);
        
    }];
    
    [self.videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 70));
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(self.slideBtn.mas_right).offset(distance);
    }];
    
    
    [self.closeViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.smallBgView.bottom).offset(60);
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(120);
    }];
    
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
- (void)videoAction:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    [self selectBtnindex:btn.tag];
    
}
- (void)pictureAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self selectBtnindex:btn.tag];
}
- (void)slideAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self selectBtnindex:btn.tag];
}
- (void)wifiStateAction:(id)sender {
    [self dismissViewWithAnimationDuration:.4f];
    [[HomeAnimationView animationView] scanQRCode];
}
- (void)fileAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self selectBtnindex:btn.tag];
}
- (void)closeAction:(id)sender {
    self.wifiLabel.text = @"";
    [self dismissViewWithAnimationDuration:0.4f];
}

-(void)selectBtnindex:(NSInteger)index{
    if(_selectBlock){
        _selectBlock(index);
        _selectBlock = nil;
    }
    self.wifiLabel.text = @"";
    [self dismissViewWithAnimationDuration:0.4f];
}

@end
