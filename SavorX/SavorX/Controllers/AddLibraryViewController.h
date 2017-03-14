//
//  AddLibraryViewController.h
//  SavorX
//
//  Created by 郭春城 on 16/10/20.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "BaseViewController.h"
#import <Photos/Photos.h>
#import "PhotoLibraryModel.h"

@protocol AddLibraryDelegate <NSObject>

@optional
- (void)libraryDidCreateByUserWithModel:(PhotoLibraryModel *)model;
- (void)libraryDidCreateByIDArray:(NSArray *)array;

@end

/**
 *	小热点幻灯片添加选择相片页，主要用于添加幻灯片时，选择某一个相片
 */
@interface AddLibraryViewController : BaseViewController

@property (nonatomic, copy) NSString * libraryTitle;
@property (nonatomic, assign) NSInteger currentNum;
@property (nonatomic, strong) PhotoLibraryModel * model;
@property (nonatomic, assign) id<AddLibraryDelegate> delegate;

@end
