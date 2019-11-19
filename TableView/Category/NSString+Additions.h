//
//  NSString+Additions.h
//  Additions
//
//  Created by Johnil on 13-6-15.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>


@interface NSString (Additions)

- (NSUInteger)compareTo:(NSString *)comp;
- (NSUInteger)compareToIgnoreCase:(NSString *)comp;
- (bool)contains:(NSString *)substring;
- (bool)endsWith:(NSString *)substring;
- (bool)startsWith:(NSString *)substring;
- (NSUInteger)indexOf:(NSString *)substring;
- (NSUInteger)indexOf:(NSString *)substring startingFrom:(NSUInteger)index;
- (NSUInteger)lastIndexOf:(NSString *) substring;
- (NSUInteger)lastIndexOf:(NSString *)substring startingFrom:(NSUInteger)index;
- (NSString *)substringFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;
- (NSString *)trim;
- (NSArray *)split:(NSString *)token;
- (NSString *)replace:(NSString *)target withString:(NSString *)replacement;
- (NSArray *)split:(NSString *)token limit:(NSUInteger)maxResults;

//计算字符串所占大小:
- (CGSize)sizeWithConstrainedToWidth:(float)width fromFont:(UIFont *)srcFont lineSpace:(float)lineSpace  lineBreakMode:(NSLineBreakMode)breakMode textAlignment:(NSTextAlignment)textAlignment;
- (CGSize)sizeWithConstrainedToSize:(CGSize)size fromFont:(UIFont *)srcFont lineSpace:(float)lineSpace lineBreakMode:(NSLineBreakMode)breakMode textAlignment:(NSTextAlignment)textAlignment;

//计算文字宽度
- (CGFloat)widthForFont:(UIFont *)font;
- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

//文本的绘制
- (void)drawInContext:(CGContextRef)context withPosition:(CGPoint)position font:(UIFont *)font textColor:(UIColor *)color height:(float)height width:(float)width lineBreakMode:(NSLineBreakMode)breakMode textAlignment:(NSTextAlignment)textAlignment;
- (void)drawInContext:(CGContextRef)context withPosition:(CGPoint)position font:(UIFont *)font textColor:(UIColor *)color height:(float)height lineBreakMode:(NSLineBreakMode)breakMode textAlignment:(NSTextAlignment)textAlignment;

@end
