//
//  UIImage+QACutImage.h
//  CoreText
//
//  Created by 我去 on 2018/12/17.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QACutImage)

/**
 *  根据指定大小截取image
 *
 *  @param rect  CGRect rect 要截取的区域
 */
- (UIImage *)cutWithRect:(CGRect)rect;

@end
