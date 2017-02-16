//
//  ScreenCollectionFooterView.m
//  SavorX
//
//  Created by lijiawei on 16/12/12.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "ScreenCollectionFooterView.h"

@implementation ScreenCollectionFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (NSString*)cellIdentifier{
    return NSStringFromClass(self);
}
+(id)loadFromXib {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil]lastObject];
}


@end
