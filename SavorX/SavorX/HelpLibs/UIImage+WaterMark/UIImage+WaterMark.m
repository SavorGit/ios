//
//  UIImage+WaterMark.m
//  PictureWatermark
//
//  Created by AD-iOS on 15/8/3.
//  Copyright (c) 2015年 Adinnet. All rights reserved.
//

#import "UIImage+WaterMark.h"

@implementation UIImage (WaterMark)

- (UIImage*)imageWaterMarkWithImage:(UIImage *)image imageRect:(CGRect)imgRect alpha:(CGFloat)alpha
{
    return [self imageWaterMarkWithString:nil rect:CGRectZero attribute:nil image:image imageRect:imgRect alpha:alpha];
}

- (UIImage*)imageWaterMarkWithImage:(UIImage*)image imagePoint:(CGPoint)imgPoint alpha:(CGFloat)alpha
{
    return [self imageWaterMarkWithString:nil point:CGPointZero attribute:nil image:image imagePoint:imgPoint alpha:alpha];
}

- (UIImage*)imageWaterMarkWithString:(NSString*)str rect:(CGRect)strRect attribute:(NSDictionary *)attri
{
    return [self imageWaterMarkWithString:str rect:strRect attribute:attri image:nil imageRect:CGRectZero alpha:0];
}

- (UIImage*)imageWaterMarkWithString:(NSString*)str point:(CGPoint)strPoint attribute:(NSDictionary*)attri
{
    return [self imageWaterMarkWithString:str point:strPoint attribute:attri image:nil imagePoint:CGPointZero alpha:0];
}

- (UIImage*)imageWaterMarkWithString:(NSString*)str point:(CGPoint)strPoint attribute:(NSDictionary*)attri image:(UIImage*)image imagePoint:(CGPoint)imgPoint alpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContext(self.size);
    [self drawAtPoint:CGPointMake(0, 0) blendMode:kCGBlendModeNormal alpha:1.0];
    if (image) {
        [image drawAtPoint:imgPoint blendMode:kCGBlendModeNormal alpha:alpha];
    }
    
    if (str) {
        [str drawAtPoint:strPoint withAttributes:attri];
    }
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
    
}

- (UIImage*)imageWaterMarkWithString:(NSString*)str rect:(CGRect)strRect attribute:(NSDictionary *)attri image:(UIImage *)image imageRect:(CGRect)imgRect alpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    if (image) {
            [image drawInRect:imgRect blendMode:kCGBlendModeNormal alpha:alpha];
    }
    
    if (str) {
        [str drawInRect:strRect withAttributes:attri];
    }
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (UIImage *)addAlphaBlackLayer
{
    CGSize size= CGSizeMake (self. size . width , self. size . height ); // 画布大小
    
    UIGraphicsBeginImageContextWithOptions (size, NO , 0.0 );
    
    [self drawAtPoint : CGPointMake ( 0 , 0 )];
    
    // 获得一个位图图形上下文
    CGContextRef context= UIGraphicsGetCurrentContext ();
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:.3f].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextDrawPath(context, kCGPathFillStroke);
    // 返回绘制的新图形
    UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext ();
    
    UIGraphicsEndImageContext ();
    
    return newImage;
}

- (UIImage *)addFirstText:(NSString *)str withSizeOnPhone:(CGSize)phoneSize
{
    CGFloat defaultFontSize = 20;
    
    CGFloat fontScale = defaultFontSize / phoneSize.width;
    CGFloat fontSize = fontScale * self.size.width;
    
    CGFloat centerYScale = 1 / phoneSize.height;
    CGFloat centerY = centerYScale * self.size.height;
    
    CGSize size= CGSizeMake (self. size . width , self. size . height ); // 画布大小
    
    UIGraphicsBeginImageContextWithOptions (size, NO , 0.0 );
    
    [self drawAtPoint : CGPointMake ( 0 , 0 )];
    
    // 获得一个位图图形上下文
    
    CGContextRef context= UIGraphicsGetCurrentContext ();
    
    CGContextSetShadowWithColor(context, CGSizeMake(0.5, 1), 2.f, [UIColor blackColor].CGColor);
    
    CGContextDrawPath (context, kCGPathStroke );
    
    CGRect rect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName :[UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName :[ UIColor whiteColor ] } context:nil];
    
    [str drawAtPoint:CGPointMake(self.size.width / 2 - rect.size.width / 2, self.size.height / 2 - centerY - rect.size.height) withAttributes : @{ NSFontAttributeName :[UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName :[ UIColor whiteColor ] } ];
    
    // 返回绘制的新图形
    UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext ();
    
    UIGraphicsEndImageContext ();
    
    return newImage;
}

- (UIImage *)addSecondText:(NSString *)str withSizeOnPhone:(CGSize)phoneSize
{
    CGFloat defaultFontSize = 16;
    
    CGFloat fontScale = defaultFontSize / phoneSize.width;
    CGFloat fontSize = fontScale * self.size.width;
    
    CGFloat centerYScale = 1 / phoneSize.height;
    CGFloat centerY = centerYScale * self.size.height;
    
    CGSize size= CGSizeMake (self. size . width , self. size . height ); // 画布大小
    
    UIGraphicsBeginImageContextWithOptions (size, NO , 0.0 );
    
    [self drawAtPoint : CGPointMake ( 0 , 0 )];
    
    // 获得一个位图图形上下文
    
    CGContextRef context= UIGraphicsGetCurrentContext ();
    
    CGContextSetShadowWithColor(context, CGSizeMake(0.5, 1), 2.f, [UIColor blackColor].CGColor);
    
    CGContextDrawPath (context, kCGPathStroke );
    
    CGRect rect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName :[ UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName :[ UIColor whiteColor ] } context:nil];
    
    [str drawAtPoint:CGPointMake(self.size.width / 2 - rect.size.width / 2, self.size.height / 2 + centerY) withAttributes : @{ NSFontAttributeName :[ UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName :[ UIColor whiteColor ] } ];
    
    // 返回绘制的新图形
    UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext ();
    
    UIGraphicsEndImageContext ();
    
    return newImage;
}

- (UIImage *)addThirdText:(NSString *)str withSizeOnPhone:(CGSize)phoneSize
{
    CGFloat defaultFontSize = 16;
    
    CGFloat fontScale = defaultFontSize / phoneSize.width;
    CGFloat fontSize = fontScale * self.size.width;
    
    CGFloat marginScale = 15 / phoneSize.height;
    CGFloat margin = marginScale * self.size.height;
    
    CGSize size= CGSizeMake (self. size . width , self. size . height ); // 画布大小
    
    UIGraphicsBeginImageContextWithOptions (size, NO , 0.0 );
    
    [self drawAtPoint : CGPointMake ( 0 , 0 )];
    
    // 获得一个位图图形上下文
    
    CGContextRef context= UIGraphicsGetCurrentContext ();
    
    CGContextDrawPath (context, kCGPathStroke );
    
    CGRect rect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName :[ UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName :[ UIColor whiteColor ] } context:nil];
    
    [str drawAtPoint:CGPointMake(self.size.width - rect.size.width - margin, self.size.height - rect.size.height - margin) withAttributes : @{ NSFontAttributeName :[ UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName :[ UIColor whiteColor ] } ];
    
    // 返回绘制的新图形
    UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext ();
    
    UIGraphicsEndImageContext ();
    
    return newImage;
}

@end
