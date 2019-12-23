//
//  QAImageFormat.h
//  TestProject
//
//  Created by Avery An on 2019/11/11.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QAImageFormat : NSObject

typedef NS_ENUM(NSUInteger, QAImageFormatProtectionMode) {
    QAImageFormatProtectionMode_None,
    QAImageFormatProtectionMode_Complete,
    QAImageFormatProtectionMode_CompleteUntilFirstUserAuthentication,
};

typedef NS_ENUM(NSUInteger, QAImageFormatStyle) {
    QAImageFormatStyle_32BitBGRA,
    QAImageFormatStyle_32BitBGR,
    QAImageFormatStyle_16BitBGR,
    QAImageFormatStyle_8BitGrayscale,
};

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CGSize pixelSize;
@property (nonatomic, assign) QAImageFormatProtectionMode protectionMode;

/**
 The bitmap info associated with the images created with this image format.
 */
@property (nonatomic, assign, readonly) CGBitmapInfo bitmapInfo;

/**
 The number of bytes each pixel of an image created with this image format occupies.
 */
@property (nonatomic, assign, readonly) NSInteger bytesPerPixel;

/**
 The number of bits each pixel component (e.g., blue, green, red color channels) uses for images created with this image format.
 */
@property (nonatomic, assign, readonly) NSInteger bitsPerComponent;

/**
 Whether or not the the images represented by this image format are grayscale.
 */
@property (nonatomic, assign, readonly) BOOL isGrayscale;

/**
 QAImageFormatStyle32BitBGRA: Full-color image format with alpha channel. 8 bits per color component, and 8 bits for the alpha channel.
 QAImageFormatStyle32BitBGR: Full-color image format with no alpha channel. 8 bits per color component. The remaining 8 bits are unused.
 QAImageFormatStyle16BitBGR: Reduced-color image format with no alpha channel. 5 bits per color component. The remaining bit is unused.
 QAImageFormatStyle8BitGrayscale: Grayscale-only image format with no alpha channel.
 */
@property (nonatomic, assign) QAImageFormatStyle formatStyle;

@end

NS_ASSUME_NONNULL_END
