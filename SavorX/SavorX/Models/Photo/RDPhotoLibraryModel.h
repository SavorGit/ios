//
//  RDPhotoLibraryModel.h
//  SavorX
//
//  Created by 郭春城 on 2017/7/4.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDPhotoLibraryModel : NSObject

@property (nonatomic, strong) PHFetchResult * fetchResult;
@property (nonatomic, copy) NSString * createTime;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * localIdentifier;

@end
