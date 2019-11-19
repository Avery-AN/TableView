//
//  UIImage+ClipsToBounds.m
//  TestProject
//
//  Created by Avery An on 2019/9/9.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "UIImage+ClipsToBounds.h"

@implementation UIImage (ClipsToBounds)

- (UIImage *)clipsToBoundsWithSize:(CGSize)size {
    if (!self) {
        return nil;
    }
    else if (CGSizeEqualToSize(size, CGSizeZero)) {
        return nil;
    }
    else if (self.images) {
        // Do not decode animated images
        return self;
    }
    
    CGImageRef imageRef = self.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGFloat rate = size.width / size.height;
    CGFloat imageRate = imageSize.width / imageSize.height;
    CGFloat startX = 0;
    CGFloat startY = 0;
    if (imageRate - rate > 0) {
        CGFloat height = imageSize.height;
        CGFloat width = height * rate;
        startX = fabs((imageSize.width - width)/2.);
        imageSize = CGSizeMake(width, height);
    }
    else {
        CGFloat width = imageSize.width;
        CGFloat height = width / rate;
        startY = fabs((imageSize.height - height)/2.);
        imageSize = CGSizeMake(width, height);
    }
    CGRect imageRect = (CGRect) {.origin = CGPointZero, .size = imageSize};
    
    
    CGRect newRect = CGRectMake(startX, startY, imageSize.width, imageSize.height);
    CGImageRef sourceImageRef = [self CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, newRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(sourceImageRef);
    imageRef = newImage.CGImage;
    
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef); // 像素的每个颜色分量使用的bit数，在RGB颜色空间下值为8
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef); // 一个像素使用的总bit数
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef); // 位图的每一行使用的字节数，大小至少为 width * bytes per pixel 字节
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    
    // BGRA8888 (premultiplied) or BGRX8888
    // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    
    // CGBitmapContextCreate(void * __nullable data, size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow, CGColorSpaceRef cg_nullable space, uint32_t bitmapInfo);
    CGContextRef context = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, bitsPerComponent, 0, colorSpace, bitmapInfo);
    if (!context)
        return NULL;
    CGContextDrawImage(context, imageRect, imageRef); // decode
    CGImageRef decodeImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *decodeImage = [UIImage imageWithCGImage:decodeImageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(decodeImageRef);
    return decodeImage;
}

@end
