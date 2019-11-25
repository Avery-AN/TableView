//
//  UIColor+Color.h
//  Avery
//
//  Created by Avery on 16/4/19.
//  Copyright © 2016年 Avery. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Color)

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha;
+ (UIColor *)randomColor;

@end
