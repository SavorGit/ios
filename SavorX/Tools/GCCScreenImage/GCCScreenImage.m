//
//  GCCScreenImage.m
//  GCCToolCreate
//
//  Created by 郭春城 on 16/4/8.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "GCCScreenImage.h"

@interface GCCScreenImage ()

@end

@implementation GCCScreenImage

+ (UIImage *)screenFullWindow
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIGraphicsBeginImageContext(window.bounds.size);
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)screenView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (void)saveImage:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

@end
