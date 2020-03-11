//
//  QATrapezoidalDraw.h
//  CoreText
//
//  Created by Avery An on 2020/3/4.
//  Copyright © 2020 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QATextDraw.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (QATrapezoidalDraw)

@property (nonatomic, copy) NSMutableArray *trapezoidalTexts_new;
@property (nonatomic, copy) NSMutableArray *lineWidths;
@property (nonatomic, copy) NSMutableArray *lines;

- (int)drawTrapezoidalWithLineHeight:(NSInteger)trapezoidalLineHeight
                         contentSize:(CGSize)contentSize
                           wordSpace:(CGFloat)wordSpace
                       textAlignment:(NSTextAlignment)textAlignment
                             leftGap:(CGFloat)leftGap
                            rightGap:(CGFloat)rightGap
                               lines:(NSArray *)lines
                    trapezoidalTexts:(NSArray *)trapezoidalTexts
                             context:(CGContextRef)context
                   saveHighlightText:(BOOL)saveHighlightText;

- (NSRange)getCurrentRunRangeInQATrapezoidalLabelWithLineIndex:(NSInteger)lineIndex
                                                      runRange:(NSRange)runRange;

@end

NS_ASSUME_NONNULL_END
