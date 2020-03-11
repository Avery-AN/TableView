//
//  QABackgroundDraw.h
//  CoreText
//
//  Created by Avery An on 2020/2/25.
//  Copyright © 2020 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, Background_TextAlignment) {
    Background_TextAlignment_Left = 1,      // 左对齐
    Background_TextAlignment_Center,        // 中间对齐
    Background_TextAlignment_Right          // 右对齐
};


NS_ASSUME_NONNULL_BEGIN

@interface QABackgroundDraw : NSObject

+ (void)drawBackgroundWithRects:(NSArray * _Nonnull)rects
                         radius:(CGFloat)radius
                backgroundColor:(UIColor * _Nonnull)backgroundColor;

+ (UIBezierPath * _Nullable)drawBackgroundWithMaxWidth:(CGFloat)maxWidth
                                            lineWidths:(NSArray * _Nonnull)lineWidths
                                            lineHeight:(CGFloat)lineHeight
                                                radius:(CGFloat)radius
                                         textAlignment:(Background_TextAlignment)textAlignment
                                       backgroundColor:(UIColor * _Nonnull)backgroundColor;

@end

NS_ASSUME_NONNULL_END
