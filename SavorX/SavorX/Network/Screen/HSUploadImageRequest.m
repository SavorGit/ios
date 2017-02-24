//
//  HSUploadImageRequest.m
//  SavorX
//
//  Created by 郭春城 on 17/2/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "HSUploadImageRequest.h"
#import "GCCKeyChain.h"
#import "GCCGetInfo.h"

@implementation HSUploadImageRequest

- (instancetype)initWithData:(NSData *)fileData name:(NSString *)name type:(HSUploadImageType)type
{
    if (self = [super init]) {
        self.mimeType = @"image/jpeg";
        self.uploadKey = @"iphone-image";
        self.fileName = name;
        
        [self setValue:name forParamKey:@"assetname"];
        [self setValue:@"prepare" forParamKey:@"function"];
        [self setValue:@"2screen" forParamKey:@"action"];
        [self setValue:@"pic" forParamKey:@"assettype"];
        [self setValue:@"0" forParamKey:@"play"];
        [self setIntegerValue:type forParamKey:@"isThumbnail"];
        [self setValue:[GCCKeyChain load:keychainID] forParamKey:@"deviceId"];
        [self setValue:[GCCGetInfo getIphoneName] forParamKey:@"deviceName"];
    }
    return self;
}

@end
