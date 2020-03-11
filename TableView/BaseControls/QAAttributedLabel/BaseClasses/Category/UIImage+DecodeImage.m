//
//  UIImage+DecodeImage.m
//  CoreText
//
//  Created by Avery An on 2019/8/31.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "UIImage+DecodeImage.h"

static BOOL ProcessBytesPerRowAlignment = YES;  // 是否要进行字节对齐

@implementation UIImage (DecodeImage)

#pragma mark - Public Methods -

- (UIImage * _Nullable)decodeImage {
    if (!self) {
        return nil;
    }
    else if (self.images) {
        // Do not decode animated images
        return self;
    }
    
    @autoreleasepool {
        CGImageRef imageRef = self.CGImage;
        CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
        CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef); // 像素的每个颜色分量使用的bit数，在RGB颜色空间下值为8
        size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef); // 一个像素使用的总bit数
        size_t bytesPerRow = CGImageGetBytesPerRow(imageRef); // 位图的每一行使用的字节数，大小至少为 width * bytes per pixel 字节
        
        // 位图的每一行使用的字节数 (处理字节对齐)
        if (ProcessBytesPerRowAlignment) { // 是否要进行字节对齐
            bytesPerRow = [self getBytesPerRowAlignmentWithBitsPerPixel:bitsPerPixel];
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
        if (!context) {
            CFRelease(colorSpace);
            CGContextRelease(context);
            return nil;
        }
        
        CGContextDrawImage(context, imageRect, imageRef); // decode
        CGImageRef decodeImageRef = CGBitmapContextCreateImage(context);
        UIImage *decodeImage = [UIImage imageWithCGImage:decodeImageRef scale:self.scale orientation:self.imageOrientation];
        
        CGContextRelease(context);
        CGImageRelease(decodeImageRef);
        CFRelease(colorSpace);
        
        return decodeImage;
    }
}


#pragma mark - Private Methods -
size_t QAByteAlign(size_t width, size_t alignment) {
    return ((width + (alignment - 1)) / alignment) * alignment;  // 取alignment的整数倍
}
size_t QAByteAlignForCoreAnimation(size_t bytesPerRow) {
    return QAByteAlign(bytesPerRow, 64);
}
- (NSInteger)getBytesPerRowAlignmentWithBitsPerPixel:(size_t)bitsPerPixel {
    CGSize imageSize = self.size;
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize pixelSize = CGSizeMake(screenScale * imageSize.width, screenScale * imageSize.height);
    NSInteger bytesPerPixel = bitsPerPixel / 8;
    
    NSInteger bytesPerRow = (NSInteger)QAByteAlignForCoreAnimation(pixelSize.width * bytesPerPixel);
    return bytesPerRow;
}

@end
