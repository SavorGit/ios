//
//  ScreenDocumentViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/8/4.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"

/**
 *	小热点文档投屏页，对文档进行投屏操作
 */
@interface ScreenDocumentViewController : BaseViewController

@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) BOOL isLockScreen;

@property (nonatomic, strong) NSString * path; //投屏文档所在路径

//重置条目
- (void)resetCurrentItemWithPath:(NSString *)path;

@end
