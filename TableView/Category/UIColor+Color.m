//
//  UIColor+Color.m
//  Avery
//
//  Created by Avery on 16/4/19.
//  Copyright © 2016年 Avery. All rights reserved.
//

#import "UIColor+Color.h"

@implementation UIColor (Color)

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;

    return [UIColor colorWithRed:r / 255.
                           green:g / 255.
                            blue:b / 255.
                           alpha:1.];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) {
        return nil;
    }
    
    return [UIColor colorWithRGBHex:hexNum];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;

    return [UIColor colorWithRed:r / 255.
                           green:g / 255.
                            blue:b / 255.
                           alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha {
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) {
        return nil;
    }
    
    return [UIColor colorWithRGBHex:hexNum alpha:alpha];
}

+ (UIColor *)randomColor {
    CGFloat red = (arc4random() % 255 / 255.);
    CGFloat green = (arc4random() % 255 / 255.);
    CGFloat blue = (arc4random() % 255 / 255.);
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.];
}

@end
