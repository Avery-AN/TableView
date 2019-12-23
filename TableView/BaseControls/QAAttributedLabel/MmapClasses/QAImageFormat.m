//
//  QAImageFormat.m
//  TestProject
//
//  Created by Avery An on 2019/11/11.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "QAImageFormat.h"
#import <objc/runtime.h>

@implementation QAImageFormat

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@"%s", __func__);
}


#pragma mark - Property -
- (void)setImageSize:(CGSize)imageSize {
    BOOL currentSizeEqualToNewSize = CGSizeEqualToSize(imageSize, _imageSize);
    if (currentSizeEqualToNewSize == NO) {
        _imageSize = imageSize;
        
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        _pixelSize = CGSizeMake(screenScale * _imageSize.width, screenScale * _imageSize.height);
    }
}

- (CGBitmapInfo)bitmapInfo {
    CGBitmapInfo info;
    switch (_formatStyle) {
        case QAImageFormatStyle_32BitBGRA:
            info = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
            break;
        case QAImageFormatStyle_32BitBGR:
            info = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
            break;
        case QAImageFormatStyle_16BitBGR:
            info = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder16Host;
            break;
        case QAImageFormatStyle_8BitGrayscale:
            info = (CGBitmapInfo)kCGImageAlphaNone;
            break;
    }
    return info;
}

- (NSInteger)bytesPerPixel {
    NSInteger bytesPerPixel;
    switch (_formatStyle) {
        case QAImageFormatStyle_32BitBGRA:
        case QAImageFormatStyle_32BitBGR:
            bytesPerPixel = 4;
            break;
        case QAImageFormatStyle_16BitBGR:
            bytesPerPixel = 2;
            break;
        case QAImageFormatStyle_8BitGrayscale:
            bytesPerPixel = 1;
            break;
    }
    return bytesPerPixel;
}

- (NSInteger)bitsPerComponent {
    NSInteger bitsPerComponent;
    switch (_formatStyle) {
        case QAImageFormatStyle_32BitBGRA:
        case QAImageFormatStyle_32BitBGR:
        case QAImageFormatStyle_8BitGrayscale:
            bitsPerComponent = 8;
            break;
        case QAImageFormatStyle_16BitBGR:
            bitsPerComponent = 5;
            break;
    }
    return bitsPerComponent;
}

- (BOOL)isGrayscale {
    BOOL isGrayscale;
    switch (_formatStyle) {
        case QAImageFormatStyle_32BitBGRA:
        case QAImageFormatStyle_32BitBGR:
        case QAImageFormatStyle_16BitBGR:
            isGrayscale = NO;
            break;
        case QAImageFormatStyle_8BitGrayscale:
            isGrayscale = YES;
            break;
    }
    return isGrayscale;
}

- (NSString *)protectionModeString {
    NSString *protectionModeString = nil;
    switch (_protectionMode) {
        case QAImageFormatProtectionMode_None:
            protectionModeString = NSFileProtectionNone;
            break;
        case QAImageFormatProtectionMode_Complete:
            protectionModeString = NSFileProtectionComplete;
            break;
        case QAImageFormatProtectionMode_CompleteUntilFirstUserAuthentication:
            protectionModeString = NSFileProtectionCompleteUntilFirstUserAuthentication;
            break;
    }
    return protectionModeString;
}

@end
