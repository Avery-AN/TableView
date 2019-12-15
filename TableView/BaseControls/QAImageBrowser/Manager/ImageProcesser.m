//
//  ImageProcesser.m
//  TableView
//
//  Created by Avery An on 2019/12/2.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "ImageProcesser.h"

static BOOL ProcessBytesPerRowAlignment = YES;  // 是否要进行字节对齐

@implementation ImageProcesser

#pragma mark - Public Methods -
+ (CGRect)caculateOriginImageSize:(UIImage *)image {
    CGFloat width = QAImageBrowserScreenWidth;  // 固定宽度为屏幕的宽度
    CGFloat height = width / (image.size.width / image.size.height);
    return CGRectMake(0, (QAImageBrowserScreenHeight - height)/2., width, height);
    
    /*
     CGFloat originImageHeight = [self processImage:image withTargetWidth:ScreenWidth].size.height;
     CGRect frame = CGRectMake(0, (ScreenHeight-originImageHeight)*0.5, ScreenWidth, originImageHeight);

     return frame;
     */
}

+ (UIImage *)decodeImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    else if (image.images) {
        // Do not decode animated images
        return image;
    }
    
    @autoreleasepool {
        CGImageRef imageRef = image.CGImage;
        CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
        CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef); // 像素的每个颜色分量使用的bit数，在RGB颜色空间下值为8
        size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef); // 一个像素使用的总bit数
        size_t bytesPerRow = CGImageGetBytesPerRow(imageRef); // 位图的每一行使用的字节数，大小至少为 width * bytes per pixel 字节
        
        // 位图的每一行使用的字节数 (处理字节对齐)
        if (ProcessBytesPerRowAlignment) { // 是否要进行字节对齐
            bytesPerRow = [self getBytesPerRowAlignmentWithBitsPerPixel:bitsPerPixel image:image];
        }
        
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
        CGContextRef context = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
        if (!context)
            return NULL;
        
        CGContextDrawImage(context, imageRect, imageRef); // decode
        CGImageRef decodeImageRef = CGBitmapContextCreateImage(context);
        UIImage *decodeImage = [UIImage imageWithCGImage:decodeImageRef scale:image.scale orientation:image.imageOrientation];
        
        CGContextRelease(context);
        CGImageRelease(decodeImageRef);
        
        return decodeImage;
    }
}


#pragma mark - Private Methods -
size_t QAByteAlign_QAImageProcesser(size_t width, size_t alignment) {
    return ((width + (alignment - 1)) / alignment) * alignment;  // 取alignment的整数倍
}
size_t QAByteAlignForCoreAnimation_QAImageProcesser(size_t bytesPerRow) {
    return QAByteAlign_QAImageProcesser(bytesPerRow, 64);
}
+ (NSInteger)getBytesPerRowAlignmentWithBitsPerPixel:(size_t)bitsPerPixel image:(UIImage *)image {
    CGSize imageSize = image.size;
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize pixelSize = CGSizeMake(screenScale * imageSize.width, screenScale * imageSize.height);
    NSInteger bytesPerPixel = bitsPerPixel / 8;
    
    NSInteger bytesPerRow = (NSInteger)QAByteAlignForCoreAnimation_QAImageProcesser(pixelSize.width * bytesPerPixel);
    return bytesPerRow;
}

+ (UIImage *)processImage:(UIImage *)sourceImage
          withTargetWidth:(CGFloat)targetWidth {
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    CGFloat targetHeight = imageHeight / (imageWidth / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO) {
        CGFloat widthFactor = targetWidth / imageWidth;
        CGFloat heightFactor = targetHeight / imageHeight;
        if(widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        }
        else {
            scaleFactor = heightFactor;
        }
        scaledWidth = imageWidth * scaleFactor;
        scaledHeight = imageHeight * scaleFactor;
        
        if(widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if(widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
