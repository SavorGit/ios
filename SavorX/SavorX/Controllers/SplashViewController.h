//
//  ViewController.h
//  GuideViewController
//
//  Created by 发兵 杨 on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+SplitImageIntoTwoParts.h"

@protocol SplashViewControllerDelegate;

@interface SplashViewController : UIViewController<UIScrollViewDelegate>

@property(nonatomic,weak) id<SplashViewControllerDelegate>delegate;
@end

@protocol SplashViewControllerDelegate <NSObject>

-(void)splashViewControllerSureBtnClicked;

@end
