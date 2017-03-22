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

- (void)setupViews
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40, 340));
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
    }];
    
    UIImageView *tvImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    tvImageView.backgroundColor = [UIColor brownColor];
    tvImageView.userInteractionEnabled = YES;
    [bgView addSubview:tvImageView];
    [tvImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(bgView.width - 60, 180));
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
    }];
    
    for (NSInteger i = 0; i < 3; i++) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.layer.cornerRadius = 5;
        label.layer.borderColor = [UIColor blackColor].CGColor;
        label.layer.borderWidth = .5f;
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.masksToBounds = YES;
        [bgView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo (tvImageView.mas_bottom).offset(20);
            make.size.mas_equalTo(CGSizeMake(65, 45));
            if (i == 0) {
                make.centerX.mas_equalTo(-kMainBoundsWidth / 4);
            }else if (i == 1) {
                make.centerX.mas_equalTo(0);
            }else{
                make.centerX.mas_equalTo(kMainBoundsWidth / 4);
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
        make.top.mas_equalTo(tvImageView.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 45));
        make.centerX.mas_equalTo(0);
    }];
    self.textField.hidden = YES;
    [self.textField becomeFirstResponder];
    
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.textLabel.text = @"请输入电视中的三位数连接电视";
    self.textLabel.backgroundColor = [UIColor clearColor];
    [bgView addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 40, 30));
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10);
        make.centerX.mas_equalTo(bgView);
    }];
    
    self.failConectLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.failConectLabel.textAlignment = NSTextAlignmentRight;
    self.failConectLabel.font = [UIFont systemFontOfSize:16];
    self.failConectLabel.backgroundColor = [UIColor clearColor];
    self.failConectLabel.text = @"连接失败，";
    [bgView addSubview:self.failConectLabel];
    self.failConectLabel.hidden = YES;
    [self.failConectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10);
        make.centerX.mas_equalTo(-50);
    }];
    
    self.reConnectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.reConnectBtn.backgroundColor = [UIColor clearColor];
    self.reConnectBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.reConnectBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.reConnectBtn setTitle:@"重新连接？" forState:UIControlStateNormal];
    self.reConnectBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.reConnectBtn addTarget:self action:@selector(reClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:self.reConnectBtn];
    self.reConnectBtn.hidden = YES;
    [self.reConnectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10);
        make.centerX.mas_equalTo(50);
    }];

}

// 重新连接
- (void)reClick{
    [self getBoxInfo];
    [self creatMaskingLoadingView];
}

- (void)creatMaskingLoadingView{
    
    self.maskingView = [[UIView alloc] initWithFrame:CGRectZero];
    self.maskingView.backgroundColor = [UIColor blackColor];
    self.maskingView.alpha = 0.66;
    
    UIWindow *keyWindow = [[[UIApplication sharedApplication] windows] lastObject];
    self.maskingView.frame = keyWindow.bounds;
    self.maskingView.bottom = keyWindow.top;
    [keyWindow addSubview:self.maskingView];
    [self showViewWithAnimationDuration:0.0];
    
    UIView *smallWindowView = [[UIView alloc] initWithFrame:CGRectZero];
    smallWindowView.backgroundColor = [UIColor whiteColor];
    smallWindowView.layer.cornerRadius = 5;
    smallWindowView.layer.borderColor = [UIColor blackColor].CGColor;
    smallWindowView.layer.borderWidth = .5f;
    smallWindowView.layer.masksToBounds = YES;
    [self.maskingView addSubview:smallWindowView];
    [smallWindowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(180, 180));
        make.centerX.mas_equalTo(self.maskingView);
        make.centerY.mas_equalTo(self.maskingView);
    }];
    
    UIImageView *loadIconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    loadIconImageView.backgroundColor = [UIColor brownColor];
    [smallWindowView addSubview:loadIconImageView];
    [loadIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 60));
        make.top.mas_equalTo(40);
        make.centerX.mas_equalTo(self.maskingView);
    }];
    
    self.animationImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.animationImageView.backgroundColor = [UIColor brownColor];
    [smallWindowView addSubview:self.animationImageView];
    [self.animationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 30));
        make.top.mas_equalTo(loadIconImageView.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.maskingView);
    }];
    
    // 播放一组图片，设置一共有多少张图片生成的动画
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
    for (int i = 1; i < 4; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"index_%d.jpg", i]];
        [imageArray addObject:image];
    }
    self.animationImageView.animationImages = imageArray;
    self.animationImageView.animationDuration = 0.5;
    self.animationImageView.animationRepeatCount = 1000;
    [self.animationImageView startAnimating];

}

- (void)hidenMaskingLoadingView{
    
    [self.maskingView removeFromSuperview];
    [self.animationImageView stopAnimating];
    
}
#pragma mark - show view
-(void)showViewWithAnimationDuration:(float)duration{
    
    [UIView animateWithDuration:duration animations:^{
        self.maskingView.backgroundColor = RGBA(0, 0, 0, 0.66);
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
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [MBProgressHUD showTextHUDwithTitle:@"绑定失败"];
        [self hidenMaskingLoadingView];
        self.failConectLabel.hidden = NO;
        self.reConnectBtn.hidden = NO;
        self.textLabel.hidden = YES;
        
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
