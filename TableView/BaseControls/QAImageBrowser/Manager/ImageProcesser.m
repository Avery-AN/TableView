//
//  ImageProcesser.m
//  TableView
//
//  Created by Avery An on 2019/12/2.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "ImageProcesser.h"

@implementation ImageProcesser

+ (CGRect)caculateOriginImageSizeWith:(UIImage *)image {
    CGFloat originImageHeight = [self processImage:image withTargetWidth:ScreenWidth].size.height;
    CGRect frame = CGRectMake(0, (ScreenHeight-originImageHeight)*0.5, ScreenWidth, originImageHeight);
    
    return frame;
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
