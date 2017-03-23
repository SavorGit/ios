//
//  HSConnectViewController.m
//  SavorX
//
//  Created by 郭春城 on 17/3/21.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSConnectViewController.h"
#import "RDBoxModel.h"

@interface HSConnectViewController ()

@property (nonatomic, strong) NSMutableArray * labelSource;
@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, strong) NSString *numSring;
@property (nonatomic, strong) UILabel * textLabel;
@property (nonatomic, strong) UILabel * failConectLabel;
@property (nonatomic, strong) UIButton *reConnectBtn;
@property (nonatomic, strong) UIView *maskingView;
@property (nonatomic, strong) UIImageView *animationImageView;

@end

@implementation HSConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.labelSource = [NSMutableArray new];
    self.numSring = [[NSString alloc] init];
    [self setupViews];
}

- (void)viewDidAppear:(BOOL)animated{
    [SAVORXAPI postUMHandleWithContentId:@"link_tv_enter" key:nil value:nil];
}

- (void)setupViews
{
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.userInteractionEnabled = YES;
    [bgView setImage:[UIImage imageNamed:@"ljtvsanweishu_bg"]];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 30, 370));
        make.top.mas_equalTo(15);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont systemFontOfSize:17];
    self.textLabel.text = @"请输入电视中的三位数连接电视";
    self.textLabel.textColor = UIColorFromRGB(0x333333);
    self.textLabel.backgroundColor = [UIColor clearColor];
    [bgView addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40, 30));
        make.bottom.mas_equalTo(bgView).offset(-32);
        make.centerX.mas_equalTo(bgView);
    }];
    
    self.failConectLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.failConectLabel.textAlignment = NSTextAlignmentRight;
    self.failConectLabel.font = [UIFont systemFontOfSize:17];
    self.failConectLabel.backgroundColor = [UIColor clearColor];
    self.failConectLabel.text = @"连接失败，";
    self.failConectLabel.textColor = UIColorFromRGB(0x333333);
    [bgView addSubview:self.failConectLabel];
    self.failConectLabel.hidden = YES;
    [self.failConectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.bottom.mas_equalTo(bgView.mas_bottom).offset(-32);
        make.centerX.mas_equalTo(-50);
    }];
    
    self.reConnectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.reConnectBtn.backgroundColor = [UIColor clearColor];
    self.reConnectBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.reConnectBtn setTitleColor:UIColorFromRGB(0xff2a00) forState:UIControlStateNormal];
    [self.reConnectBtn setTitle:@"重新连接？" forState:UIControlStateNormal];
    self.reConnectBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.reConnectBtn addTarget:self action:@selector(reClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:self.reConnectBtn];
    self.reConnectBtn.hidden = YES;
    [self.reConnectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.bottom.mas_equalTo(bgView.mas_bottom).offset(-32);
        make.centerX.mas_equalTo(50);
    }];
    
    for (NSInteger i = 0; i < 3; i++) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.layer.cornerRadius = 0;
        label.layer.borderColor = UIColorFromRGB(0xffd237).CGColor;
        label.layer.borderWidth = 1.5f;
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.masksToBounds = YES;
        [bgView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo (self.textLabel.mas_top).offset(-18);
            make.size.mas_equalTo(CGSizeMake(70, 50));
            if (i == 0) {
                make.centerX.mas_equalTo(-99);
            }else if (i == 1) {
                make.centerX.mas_equalTo(0);
            }else{
                make.centerX.mas_equalTo(99);
            }
        }];
        [self.labelSource addObject:label];
    }
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    [self.textField addTarget:self action:@selector(numTextFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:self.textField];
    self.textField.backgroundColor = [UIColor clearColor];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo (self.textLabel.mas_top).offset(-18);
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 50));
        make.centerX.mas_equalTo(0);
    }];
    self.textField.hidden = YES;
    [self.textField becomeFirstResponder];
    
}

// 重新连接
- (void)reClick{
    [self getBoxInfo];
    [self creatMaskingLoadingView];
}

- (void)creatMaskingLoadingView{
    
    self.maskingView = [[UIView alloc] initWithFrame:CGRectZero];
    self.maskingView.backgroundColor = [UIColor blackColor];
    self.maskingView.alpha = 0.88;
    
    UIWindow *keyWindow = [[[UIApplication sharedApplication] windows] lastObject];
    self.maskingView.frame = keyWindow.bounds;
    self.maskingView.bottom = keyWindow.top;
    [keyWindow addSubview:self.maskingView];
    [self showViewWithAnimationDuration:0.0];
    
    UIImageView *smallWindowView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [smallWindowView setImage:[UIImage imageNamed:@"lianjie_bg"]];
    [self.maskingView addSubview:smallWindowView];
    [smallWindowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(190, 160));
        make.centerX.mas_equalTo(self.maskingView);
        make.centerY.mas_equalTo(self.maskingView);
    }];
    
    self.animationImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.animationImageView.backgroundColor = [UIColor clearColor];
    [smallWindowView addSubview:self.animationImageView];
    [self.animationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 20));
        make.bottom.mas_equalTo(smallWindowView.mas_bottom).offset(- 20);
        make.centerX.mas_equalTo(self.maskingView);
    }];
    
    // 播放一组图片，设置一共有多少张图片生成的动画
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
    for (int i = 1; i < 4; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"connecting%d.png", i]];
        [imageArray addObject:image];
    }
    self.animationImageView.animationImages = imageArray;
    self.animationImageView.animationDuration = 0.5;
    self.animationImageView.animationRepeatCount = 10000;
    [self.animationImageView startAnimating];

}

- (void)hidenMaskingLoadingView{
    
    [self.maskingView removeFromSuperview];
    [self.animationImageView stopAnimating];
    
}
#pragma mark - show view
-(void)showViewWithAnimationDuration:(float)duration{
    
    [UIView animateWithDuration:duration animations:^{
        self.maskingView.backgroundColor = RGBA(0, 0, 0, 0.88);
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        self.maskingView.bottom = keyWindow.bottom;
    } completion:^(BOOL finished) {
    }];
}
- (void)numTextFieldDidChange
{
    NSString * number = self.textField.text;
    
    if (number.length == self.labelSource.count) {
        self.numSring = number;
        [self getBoxInfo];
        [self creatMaskingLoadingView];
    }
    if (number.length > self.labelSource.count) {
        self.textField.text = [number substringWithRange:NSMakeRange(0,3)];
    }
    NSLog(@"---%@",self.textField.text);
    for (NSUInteger i = 0; i < self.labelSource.count; i++) {
        if (i < number.length) {
            UILabel * label = [self.labelSource objectAtIndex:i];
            label.text = [number substringWithRange:NSMakeRange(i, 1)];
        }else{
            UILabel * label = [self.labelSource objectAtIndex:i];
            label.text = @"";
        }
        if (self.numSring.length == 3 && number.length == 2) {
            self.failConectLabel.hidden = YES;
            self.reConnectBtn.hidden = YES;
            self.textLabel.hidden = NO;
            self.numSring = @"";
        }
    }
}

- (void)getBoxInfo
{
    NSString *hosturl = [NSString stringWithFormat:@"%@/command/box-info/%@", [GlobalData shared].callQRCodeURL, self.numSring];
    
    [SAVORXAPI getWithURL:hosturl parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *result) {
        
        NSInteger code = [[result objectForKey:@"code"] integerValue];
        if (code == 10000) {
            result = [result objectForKey:@"result"];
            RDBoxModel * model = [[RDBoxModel alloc] init];
            model.BoxIP = [[result objectForKey:@"box_ip"] stringByAppendingString:@":8080"];
            model.BoxID = [result objectForKey:@"box_mac"];
            model.hotelID = [[result objectForKey:@"hotel_id"] integerValue];
            model.roomID = [[result objectForKey:@"room_id"] integerValue];
            model.sid = [result objectForKey:@"ssid"];
            [[GlobalData shared] bindToRDBoxDevice:model];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD showTextHUDwithTitle:[result objectForKey:@"msg"]];
        }
        [self hidenMaskingLoadingView];
        self.failConectLabel.hidden = YES;
        self.reConnectBtn.hidden = YES;
        self.textLabel.hidden = NO;
        [SAVORXAPI postUMHandleWithContentId:@"link_tv_input_num" key:@"link_tv_input_num" value:@"success"];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [MBProgressHUD showTextHUDwithTitle:@"绑定失败"];
        [self hidenMaskingLoadingView];
        self.failConectLabel.hidden = NO;
        self.reConnectBtn.hidden = NO;
        self.textLabel.hidden = YES;
        [SAVORXAPI postUMHandleWithContentId:@"link_tv_input_num" key:@"link_tv_input_num" value:@"fail"];
        
    }];
}

- (void)clearNumber
{
    self.textField.text = @"";
    for (NSInteger i = 0; i < self.labelSource.count; i++) {
        UILabel * label = [self.labelSource objectAtIndex:i];
        label.text = @"";
    }
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"link_tv_back" key:nil value:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
