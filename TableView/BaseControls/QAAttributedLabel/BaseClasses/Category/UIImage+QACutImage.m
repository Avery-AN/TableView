//
//  UIImage+QACutImage.m
//  CoreText
//
//  Created by 我去 on 2018/12/17.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "UIImage+QACutImage.h"

@implementation UIImage (QACutImage)

/**
 *  根据指定大小截取image
 *
 *  @param rect  CGRect rect 要截取的区域
 */
- (UIImage *)cutWithRect:(CGRect)rect {
    if (CGSizeEqualToSize(self.size, rect.size)) {
        return self;
    }
    else if (self.size.width - rect.size.width > 0 && self.size.height - rect.size.height > 0) {
        return self;
    }
    else {
        if (self.scale - 1 <= 0.1) {  // 网络image的scale值为1
            CGImageRef sourceImageRef = [self CGImage];
            CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
            UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            CGImageRelease(newImageRef);
            
            return newImage;
        }
        else {  // 本地的image (@2x / @3x)
            CGFloat scale = [UIScreen mainScreen].scale;
            CGFloat x = rect.origin.x*scale;
            CGFloat y = rect.origin.y*scale;
            CGFloat width = rect.size.width*scale;
            CGFloat height = rect.size.height*scale;
            CGRect newRect = CGRectMake(x, y, width, height);
            
            CGImageRef sourceImageRef = [self CGImage];
            CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, newRect);
            UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            CGImageRelease(newImageRef);
            
            return newImage;
        }
    }
}

+ (CGImageRef)cutCGImage:(CGImageRef)cgImage withRect:(CGRect)rect {
    CGImageRef sourceImageRef = cgImage;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x = rect.origin.x*scale;
    CGFloat y = rect.origin.y*scale;
    CGFloat width = rect.size.width*scale;
    CGFloat height = rect.size.height*scale;
    CGRect newRect = CGRectMake(x, y, width, height);
    
    if (CGImageGetWidth(cgImage) - width == 0 &&
        CGImageGetHeight(cgImage) - height == 0) {
        return cgImage;
    }
    
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, newRect);
    return newImageRef;
}

@end
