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

@end

@implementation HSConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.labelSource = [NSMutableArray new];
    [self setupViews];
}

- (void)setupViews
{
    for (NSInteger i = 0; i < 3; i++) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.layer.cornerRadius = 5;
        label.layer.borderColor = [UIColor blackColor].CGColor;
        label.layer.borderWidth = .5f;
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.masksToBounds = YES;
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(100);
            make.size.mas_equalTo(CGSizeMake(50, 30));
            if (i == 0) {
                make.centerX.mas_equalTo(-kMainBoundsWidth / 5);
            }else if (i == 1) {
                make.centerX.mas_equalTo(0);
            }else{
                make.centerX.mas_equalTo(kMainBoundsWidth / 5);
            }
        }];
        [self.labelSource addObject:label];
    }
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    [self.textField addTarget:self action:@selector(numTextFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 30));
        make.centerX.mas_equalTo(0);
    }];
    self.textField.hidden = YES;
    [self.textField becomeFirstResponder];
}

- (void)numTextFieldDidChange
{
    NSString * number = self.textField.text;
    if (number.length > self.labelSource.count) {
        [self clearNumber];
        return;
    } else if (number.length == self.labelSource.count) {
        [self getBoxInfo:number];
    }
    for (NSUInteger i = 0; i < self.labelSource.count; i++) {
        if (i < number.length) {
            UILabel * label = [self.labelSource objectAtIndex:i];
            label.text = [number substringWithRange:NSMakeRange(i, 1)];
        }else{
            UILabel * label = [self.labelSource objectAtIndex:i];
            label.text = @"";
        }
    }
}

- (void)getBoxInfo:(NSString *)number
{
    NSString *hosturl = [NSString stringWithFormat:@"%@/command/box-info/%@", [GlobalData shared].callQRCodeURL, number];
    
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
        [self clearNumber];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [MBProgressHUD showTextHUDwithTitle:@"绑定失败"];
        [self clearNumber];
        
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
