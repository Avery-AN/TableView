//
//  QATrapezoidalLayer.h
//  CoreText
//
//  Created by Avery An on 2020/3/4.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QAAttributedLayer.h"

// 设置左右间距(背景色和文字之间的间隔):
static CGFloat QATrapezoidal_LeftGap = 10;
static CGFloat QATrapezoidal_RightGap = 10;


NS_ASSUME_NONNULL_BEGIN

@interface QATrapezoidalLayer : QAAttributedLayer

- (void)getBaseInfoWithContentSize:(CGSize)contentSize
                  trapezoidalTexts:(NSArray *)trapezoidalTexts
                    attributedText:(NSMutableAttributedString * _Nonnull __strong *_Nonnull)attributedText
                     contentHeight:(CGFloat *)contentHeight;

@end

NS_ASSUME_NONNULL_END
