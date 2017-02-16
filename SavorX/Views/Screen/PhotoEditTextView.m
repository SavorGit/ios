//
//  PhotoEditTextView.m
//  SavorX
//
//  Created by 郭春城 on 17/2/6.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "PhotoEditTextView.h"
#import "PhotoTextLabel.h"
#import "IQKeyboardManager.h"

@interface PhotoEditTextView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIVisualEffectView * effectView;
@property (nonatomic, strong) PhotoTextLabel * textLabel;
@property (nonatomic, strong) UIView * toolView;
@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, assign) PhotoEditTextStyle style;

@end

@implementation PhotoEditTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self customSelf];
    }
    return self;
}

- (void)customSelf
{
    [[IQKeyboardManager sharedManager] setEnable:NO];
    
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [self addSubview:self.effectView];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.textLabel = [[PhotoTextLabel alloc] initWithFrame:CGRectMake(40, -70, self.bounds.size.width - 80, 70)];
    self.textLabel.font = [UIFont systemFontOfSize:18];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.text = @"请输入文字";
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textLabelDidBeClicked)];
    [self.textLabel addGestureRecognizer:tap];
    [self addSubview:self.textLabel];
    
    self.toolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 40, kMainBoundsWidth, 40)];
    self.toolView.backgroundColor = VCBackgroundColor;
    [self addSubview:self.toolView];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, kMainBoundsWidth - 70, 30)];
    self.textField.placeholder = @"点击输入文字";
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textFieldDidChangeValue) forControlEvents:UIControlEventEditingChanged];
    [self.toolView addSubview:self.textField];
    
    UIButton * OKButton = [UIButton buttonWithType:UIButtonTypeCustom];
    OKButton.frame = CGRectMake(kMainBoundsWidth - 60, 0, 60, 40);
    [OKButton setTitle:@"完成" forState:UIControlStateNormal];
    [OKButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [OKButton addTarget:self action:@selector(OKButtonDidBeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:OKButton];
    
    [[NSNotificationCenter
      defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter
      defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification object:nil];//在这里注册通知
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.style == PhotoEditTextStyleTitle) {
        if (self.textField.text.length + string.length > 16) {
            [MBProgressHUD showTextHUDwithTitle:@"最多只能添加16个字"];
            return NO;
        }
    }else if (self.textField.text.length + string.length > 20){
        [MBProgressHUD showTextHUDwithTitle:@"最多只能添加20个字"];
        return NO;
    }
    return YES;
}

- (void)textLabelDidBeClicked
{
    [self.textField becomeFirstResponder];
}

- (void)showWithEditStyle:(PhotoEditTextStyle)style onView:(UIView *)view withText:(NSString *)str
{
    self.style = style;
    if (str.length > 0) {
        if ([str isEqualToString:@"在这里添加文字"]) {
            self.textField.text = @"";
            self.textLabel.text = @"点击输入文字";
        }else{
            self.textField.text = str;
            self.textLabel.text = str;
        }
    }else{
        self.textField.text = @"";
        self.textLabel.text = @"点击输入文字";
    }
    [view addSubview:self];
    [self.textField becomeFirstResponder];
}

- (void)OKButtonDidBeClicked:(UIButton *)button
{
    [self.textField resignFirstResponder];
    
    NSString * text = self.textLabel.text;
    if ([text isEqualToString:@"点击输入文字"]) {
        text = @"";
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(PhotoTextLabelDidEndEditWith:andStyle:)]) {
        [self.delegate PhotoTextLabelDidEndEditWith:text andStyle:self.style];
    }
    
    [self removeFromSuperview];
    self.textLabel.frame = CGRectMake(40, -70, self.bounds.size.width - 80, 70);
}

- (void)textFieldDidChangeValue
{
    if (self.textField.text.length == 0) {
        self.textLabel.text = @"点击输入文字";
    }else{
        self.textLabel.text = self.textField.text;
    }
}

#pragma mark - 监听方法
/**
 * 键盘出现时调用
 */
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    // 动画的持续时间
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 键盘的frame
    CGRect keyboardF = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect toolViewFrame = self.toolView.frame;
    toolViewFrame.origin.y = self.bounds.size.height - keyboardF.size.height - toolViewFrame.size.height;
    
    CGRect labelFrame = self.textLabel.frame;
    labelFrame.origin.y = (toolViewFrame.origin.y - labelFrame.size.height) / 2;
    if (self.textLabel.frame.origin.y != labelFrame.origin.y) {
        [UIView animateWithDuration:duration animations:^{
            self.textLabel.frame = labelFrame;
        }];
    }
    // 执行动画
    [UIView animateWithDuration:duration animations:^{
        self.toolView.frame = toolViewFrame;
    }];
}

/**
 * 键盘消失时调用
 */
- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    // 动画的持续时间
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 键盘的frame
    CGRect keyboardF = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect toolViewFrame = self.toolView.frame;
    toolViewFrame.origin.y = toolViewFrame.origin.y + keyboardF.size.height;
    // 执行动画
    [UIView animateWithDuration:duration animations:^{
        self.toolView.frame = toolViewFrame;
    }];
}

- (void)dealloc
{
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
