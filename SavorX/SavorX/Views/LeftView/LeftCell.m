//
//  LeftCell.m
//  SavorX
//
//  Created by lijiawei on 17/1/17.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "LeftCell.h"

@interface LeftCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *RightMoreImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLabelWidth;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;

@end

@implementation LeftCell


-(void)fillCellTitle:(NSString *)title content:(NSString*)content{
    
    self.titleLabel.text = title;
    if(content.length == 0){
        self.rightLabelWidth.constant = 0;
        self.rightImageWidth.constant = 15;
    }else{
        self.contentLabel.text = content;
        self.rightImageWidth.constant = 0;
        self.rightLabelWidth.constant = 60;
    }
    self.bottomLine.backgroundColor = [UIColor colorWithRed:176/255.0 green:93/255.0 blue:106/255.0 alpha:1.0];
}

- (void)bottomLineHidden:(BOOL)hidden
{
    self.bottomLine.hidden = hidden;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
