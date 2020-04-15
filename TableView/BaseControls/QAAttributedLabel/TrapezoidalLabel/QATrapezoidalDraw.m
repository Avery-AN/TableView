//
//  QATrapezoidalDraw.m
//  CoreText
//
//  Created by Avery An on 2020/3/4.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QATrapezoidalDraw.h"
#import "QAAttributedLabelConfig.h"

@implementation NSMutableAttributedString (QATrapezoidalDraw)

#pragma mark - Public Apis -
- (NSRange)getCurrentRunRangeInQATrapezoidalLabelWithLineIndex:(NSInteger)lineIndex
                                                      runRange:(NSRange)runRange {
    NSArray *trapezoidalTexts = self.trapezoidalTexts_new;
    NSInteger location = runRange.location;
    for (NSUInteger i = 0; i < lineIndex; i++) {
        NSAttributedString *attributedString = [trapezoidalTexts objectAtIndex:i];
        NSString *string = attributedString.string;
        location = location + string.length;
    }
    return NSMakeRange(location, runRange.length);
}

- (int)drawTrapezoidalWithLineHeight:(NSInteger)trapezoidalLineHeight
                         contentSize:(CGSize)contentSize
                           wordSpace:(CGFloat)wordSpace
                       textAlignment:(NSTextAlignment)textAlignment
                             leftGap:(CGFloat)leftGap
                            rightGap:(CGFloat)rightGap
                               lines:(NSArray *)lines
                    trapezoidalTexts:(NSArray *)trapezoidalTexts
                             context:(CGContextRef)context
                   saveHighlightText:(BOOL)saveHighlightText {
    if (context == NULL || CGSizeEqualToSize(contentSize, CGSizeZero)) {
        return -10;
    }
    
    BOOL sorted = NO;
    @autoreleasepool {
        // 翻转坐标系:
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, contentSize.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // 绘制line:
        NSInteger numberOfLines = lines.count;
        for (NSUInteger lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
            id obj = [lines objectAtIndex:lineIndex];
            CTLineRef line = (__bridge CTLineRef)obj;
            
            CGFloat descent = 0.0f, ascent = 0.0f, leading = 0.0f;
            CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGFloat lineHeight = ascent + fabs(descent) + leading;  // ascent & descent & leading的值由字体来确定、无法修改。
            
            /**
             CGRect rect_line = CTLineGetImageBounds(line, context);
             CGFloat lineWidth = rect_line.size.width;   // 文字的最左端与文字的最右端之间的距离
             */
            CGRect rect_line = CTLineGetImageBounds(line, context);
            
            CGFloat offsetX = 0;
            if (textAlignment == NSTextAlignmentLeft) {     // 左对齐
                offsetX = leftGap;
            }
            else if (textAlignment == NSTextAlignmentRight) {   // 右对齐
                offsetX = contentSize.width - rightGap - lineWidth;
            }
            else {   // 居中对齐
                offsetX = (contentSize.width - lineWidth) / 2.;
            }
            
            /**
             CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, .5, contentSize.width);  // 居中对齐
             CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, 0, contentSize.width) + DrawBackground_LeftGap;  // 左对齐
             CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, 1, contentSize.width) - DrawBackground_RightGap; // 右对齐
             */
            
            // 绘制line:
            CGFloat offsetY = ((lines.count-1)-lineIndex)*trapezoidalLineHeight + (trapezoidalLineHeight - lineHeight)/2 + fabs(descent);
            offsetY = offsetY + contentSize.height-(lines.count * trapezoidalLineHeight);
            CGContextSetTextPosition(context, offsetX, offsetY);
            CTLineDraw(line, context);
            
            
            
            
            
            


            NSMutableAttributedString *attributedText = self;
            if (sorted == NO && saveHighlightText) {   // 这里只需调用一次!
                sorted = YES;
                [self getSortedHighlightRanges:attributedText];
            }
            
            

            // 从CTLine中获取所有的CTRun:
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            long runCounts = CFArrayGetCount(runs);
            
            // 遍历CTLine中的每一个CTRun:
            for (NSUInteger j = 0; j < runCounts; j++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                
                /*
                 CFDictionaryRef attributes = CTRunGetAttributes(run);
                 */
                
                /*
                 void CTRunDraw(CTRunRef run, CGContextRef context, CFRange range)
                 
                 range: The range of glyphs to be drawn, with the entire range having a  location of 0 and a length of CTRunGetGlyphCount. If the length of the range is set to 0, then the operation will continue from the range's start index to the end of the run.
                 */
                
                /*
                 CTRunDraw(run, context, CFRangeMake(0, 0));    // 绘制每一个run的内容
                 */
                
                NSDictionary *runAttributes = (__bridge NSDictionary *)CTRunGetAttributes(run);
                CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
                if (delegate) {  // 此时需要绘制附件的内容
                    // 基于attributedString创建CTFramesetter:
                    NSMutableAttributedString *attributedString = [trapezoidalTexts objectAtIndex:lineIndex];
                    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);

                    // 创建绘制路径path:
                    CGRect drawRect = (CGRect) {0, 0, CGSizeMake(lineWidth, rect_line.size.height)};
                    CGMutablePathRef drawPath = CGPathCreateMutable();
                    CGPathAddRect(drawPath, NULL, drawRect);

                    // 创建CTFrame:
                    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, 0), drawPath, NULL);
                    
                    // 绘制附件:
                    [self drawAttachmentContentInContext:context
                                                 ctframe:ctFrame
                                                    line:line
                                              lineOrigin:CGPointMake(offsetX, offsetY)
                                                     run:run
                                                delegate:delegate
                                               wordSpace:wordSpace];
                    
                    CFRelease(ctFramesetter);
                    CFRelease(drawPath);
                    CFRelease(ctFrame);
                }
                else {
                    // 保存高亮文案在字符中的NSRange以及CGRect (以便在label中处理点击事件):
                    if (saveHighlightText) {
                        int result = [self saveHighlightRangeAndFrameWithLineIndex:lineIndex
                                                                        lineOrigin:CGPointMake(offsetX, offsetY)
                                                                      contentWidth:lineWidth
                                                                     contentHeight:trapezoidalLineHeight
                                                                  attributedString:attributedText
                                                                           context:context
                                                                              line:line
                                                                               run:run];
                        if (result < 0) {
                            return result;
                        }
                    }
                }
            }
        }
    }
    
    return 0;
}


#pragma mark - Property -
- (void)setTrapezoidalTexts_new:(NSMutableArray *)trapezoidalTexts_new {
    objc_setAssociatedObject(self, @selector(trapezoidalTexts_new), trapezoidalTexts_new, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSMutableArray *)trapezoidalTexts_new {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLines:(NSMutableArray *)lines {
    objc_setAssociatedObject(self, @selector(lines), lines, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSMutableArray *)lines {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLineWidths:(NSMutableArray *)lineWidths {
    objc_setAssociatedObject(self, @selector(lineWidths), lineWidths, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSMutableArray *)lineWidths {
    return objc_getAssociatedObject(self, _cmd);
}

@end
