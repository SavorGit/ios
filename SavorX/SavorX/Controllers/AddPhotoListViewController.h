//
//  AddPhotoListViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/11/1.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"

@protocol AddPhotoListDelegate <NSObject>

- (void)PhotoDidCreateByIDArray:(NSArray *)array;

@end

/**
 *	小热点幻灯片添加选择相册页，主要用于添加幻灯片时，选择某一个相册
 */
@interface AddPhotoListViewController : BaseViewController

@property (nonatomic, assign) id<AddPhotoListDelegate> delegate;
@property (nonatomic, assign) NSInteger currentNum;
@property (nonatomic, copy) NSString * libraryTitle;
@property (nonatomic, strong) NSMutableArray *results; //记录当前相册集合

@end
