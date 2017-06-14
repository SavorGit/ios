//
//  RDHomeScreenButton.h
//  Test - 2.1
//
//  Created by 郭春城 on 17/3/2.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RDHomeScreenButtonDelegate <NSObject>

- (void)RDHomeScreenButtonDidBeClicked;

@end

@interface RDHomeScreenButton : UIButton

@property (nonatomic, assign) id<RDHomeScreenButtonDelegate> delegate;

@end
