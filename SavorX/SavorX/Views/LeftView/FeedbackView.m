//
//  FeedbackView.m
//  SavorX
//
//  Created by lijiawei on 17/2/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "FeedbackView.h"
#import "HSSubmitFeedbackRequest.h"

@interface FeedbackView ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *adviceTextView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (nonatomic, assign) BOOL hasAdvice; //用户是否输入了意见
@property (weak, nonatomic) IBOutlet UILabel *pLabel;

@end

@implementation FeedbackView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.adviceTextView.delegate = self;
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        [self.pLabel setHidden:NO];
    }else{
        [self.pLabel setHidden:YES];
    }
}


- (IBAction)submitAction:(id)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(feedbackView:adviceText:phoneText:)])
    {
        [_delegate feedbackView:self adviceText:_adviceTextView.text phoneText:_phoneTextField.text];
    }
 
}

//若是4，4s用户，为保证绑定页的显示不影响用户操作，对键盘的收起作特定处理
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if ([self.adviceTextView isFirstResponder]) {
        [self.adviceTextView resignFirstResponder];
    }else if ([self.phoneTextField isFirstResponder]){
        [self.phoneTextField resignFirstResponder];
    }
}

@end
