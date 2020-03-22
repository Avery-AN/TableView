//
//  QATrapezoidalLabel.h
//  CoreText
//
//  Created by Avery An on 2020/3/4.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QAAttributedLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QATrapezoidalLabel : QAAttributedLabel

/**
 设置此属性时、文案将会全部被展示、不会去做文案的截断等操作(即:视numberOfLines的值为0)
 */
@property (nonatomic, copy, nullable) NSArray *trapezoidalTexts;  // 展示的文案(数组中的每个元素均占有单独的一行)
@property (nonatomic, assign) NSInteger trapezoidalLineHeight;   // 单行行高
@property (nonatomic) UIColor *lineBackgroundColor;

/**
 获取文案所占用的size
 */
- (void)getTextContentSizeWithLayer:(QAAttributedLayer * _Nonnull)layer
                            content:(id _Nonnull)contents
                           maxWidth:(CGFloat)width
                    completionBlock:(GetTextContentSizeBlock _Nullable)block;

- (void)setText:(NSString * _Nullable)text __attribute__((unavailable("该方法不可用")));
- (void)setAttributedString:(NSMutableAttributedString * _Nullable)attributedString __attribute__((unavailable("该方法不可用")));

@end

NS_ASSUME_NONNULL_END
