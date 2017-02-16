//
//  BasicTableViewCell.h
//  SavorX
//
//  Created by 郭春城 on 16/8/12.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *	基类cell，用于展示视频文章条目
 */
@interface BasicTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView * bgImageView; //封面背景图
@property (nonatomic, strong) UILabel * titleLabel; //标题显示
@property (nonatomic, strong) UILabel * timeLabel; //时间显示

- (void)videoCanDemand:(BOOL)can;

@end
