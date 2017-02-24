//
//  HSUploadImageRequest.h
//  SavorX
//
//  Created by 郭春城 on 17/2/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

typedef enum : NSUInteger {
    HSUPLOADIMAGETYPE_MIN,
    HSUPLOADIMAGETYPE_MAX
} HSUploadImageType;

#import <BGNetwork/BGNetwork.h>

@interface HSUploadImageRequest : BGUploadRequest

- (instancetype)initWithData:(NSData *)fileData name:(NSString *)name type:(HSUploadImageType)type;

@end
