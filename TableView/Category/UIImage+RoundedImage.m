//
//  UIImage+RoundedImage.m
//  Avery
//
//  Created by Avery on 2018/7/19.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "UIImage+RoundedImage.h"

@implementation UIImage (RoundedImage)

- (instancetype)roundedImage {
    int width = self.size.width;
    int height = self.size.height;
    int radius = 0;
    CGImageRef imageRef;
    BOOL new = NO;
    if (abs(width - height) > 1) {  // 允许1像素的误差
        CGFloat x = 0;
        CGFloat y = 0;
        if (width > height) {
            x = (width - height) / 2.;
            y = 0;
            width = height;
            radius = height / 2.;
        }
        else {
            x = 0;
            y = (height - width) / 2.;
            height = width;
            radius = width / 2.;
        }
        new = YES;
        imageRef = [self cutImageWithRect:CGRectMake(x, y, width, height)];  // 处理成宽高相等的image
    }
    else {
        imageRef = self.CGImage;
    }
    CGRect rect = CGRectMake(0, 0, width, height);
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);  // 根据图形上下文创建一个空路径
    addRoundedRectToPath(context, rect, radius, radius);
    CGContextClosePath(context);  // 闭合路径
    CGContextClip(context); // 裁剪路径
    CGContextDrawImage(context, rect, imageRef);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageMasked];
    
    // 释放:
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    if (new) {
        CFRelease(imageRef);
    }
    
    return image;
}
- (CGImageRef)cutImageWithRect:(CGRect)rect {  // rect是针对于image的坐标
    if (self.scale - 1 <= 0.1) {  // 网络image的scale值为1
        CGImageRef sourceImageRef = [self CGImage];
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
        return newImageRef;
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
        return newImageRef;
    }
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight) {
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    float fw, fh;
    CGContextSaveGState(context);  // 保存当前的绘图状态。CGContextSaveGState() 函数保存的绘图状态，不仅包括当前坐标系统的状态， 也包括当前设置的填充风格、线条风格、阴影风格等各种绘图状态。但 CGContextSaveGState() 函数不会保存当前绘制的图形。
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect)); // 平移坐标系统:根据我们指定的x, y轴的值移动坐标系统的原点
    CGContextScaleCTM(context, ovalWidth, ovalHeight); // 缩放坐标系统:该方法控制坐标系统水平方向上缩放 sx，垂直方向上缩放 sy。在缩放后的坐标系统上绘制图形时，所有点的 X 坐标都相当于乘以 sx 因子，所有点的 Y 坐标都相当于乘以 sy 因子。
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context); // 恢复之前保存的绘图状态。
    
    /*
     void CGContextRotateCTM ( CGContextRef c, CGFloat angle ):旋转坐标系统。
     该方法控制坐标系统旋转 angle 弧度。在缩放后的坐标系统上绘制图形时，所有坐标点的 X、Y 坐标都相当于旋转了 angle弧度之后的坐标。
     
     // 圆心(x,y); 半径radius; 开始、结束弧度startAngle/endAngle; 绘制方向clockwise(0:顺时针; 1:逆时针)。
     CGContextAddArc(CGContextRef cg_nullable c, CGFloat x, CGFloat y, CGFloat radius, CGFloat startAngle, CGFloat endAngle, int clockwise)
     
     
     CGContextAddArcToPoint(CGContextRef cg_nullable c, CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2, CGFloat radius);
     
     
     */
    
}

@end
