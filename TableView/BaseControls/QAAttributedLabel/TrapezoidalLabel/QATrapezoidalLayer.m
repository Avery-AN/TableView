//
//  QATrapezoidalLayer.m
//  CoreText
//
//  Created by Avery An on 2020/3/4.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QATrapezoidalLayer.h"
#import "QAHighlightTextManager.h"
#import "QATrapezoidalLabel.h"
#import "QATextLayout.h"
#import "QAAttributedLabelConfig.h"
#import "QATrapezoidalDraw.h"
#import "QABackgroundDraw.h"

@implementation QATrapezoidalLayer

#pragma mark - Override Methods -
- (void)display {
    // NSLog(@"%s",__func__);
    super.contents = super.contents;

    QATrapezoidalLabel *attributedLabel = (QATrapezoidalLabel *)GetAttributedLabel(self);
    if (!attributedLabel) {
        [self clearAllBackup];
        self.contents = nil;
        return;
    }
    else if (!attributedLabel.trapezoidalTexts || attributedLabel.trapezoidalTexts.count == 0) {
        [self clearAllBackup];
        self.contents = nil;
        return;
    }
    
    [self fillContents:attributedLabel];
}


#pragma mark - Public Apis -
- (BOOL)isDrawAvailable:(id)label {
    if (!label || ![label isKindOfClass:[QATrapezoidalLabel class]]) {
        return NO;
    }
    
    QATrapezoidalLabel *attributedLabel = (QATrapezoidalLabel *)label;
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        return NO;
    }
    else if ((attributedLabel.trapezoidalTexts == nil || attributedLabel.trapezoidalTexts.count == 0)) {
        self.contents = nil;
        return NO;
    }
    else if (attributedLabel.trapezoidalLineHeight <= 0) {
        self.contents = nil;
        return NO;
    }
    return YES;
}
- (CGFloat)updateContentsHeightWithTrapezoidalTexts:(NSArray *)trapezoidalTexts
                                         lineWidths:(NSMutableArray *)lineWidths
                                              lines:(NSMutableArray *)lines
                               trapezoidalTexts_new:(NSMutableArray *)trapezoidalTexts_new
                                            context:(CGContextRef)context
                                       maxLineWidth:(CGFloat)maxLineWidth
                              trapezoidalLineHeight:(CGFloat)trapezoidalLineHeight {
    for (NSAttributedString *attributedString in trapezoidalTexts) {
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
         
        [self updateLine:line
                 context:context
        attributedString:attributedString
            maxLineWidth:maxLineWidth
                   lines:lines
              lineWidths:lineWidths
        trapezoidalTexts:trapezoidalTexts_new];
        
        CFRelease(line);
    }
    
    return lineWidths.count * trapezoidalLineHeight;
}
- (int)drawAttributedText:(NSMutableAttributedString *)attributedText
                  context:(CGContextRef _Nonnull)context
              contentSize:(CGSize)contentSize
                wordSpace:(CGFloat)wordSpace
         maxNumberOfLines:(NSInteger)numberOfLines
            textAlignment:(NSTextAlignment)textAlignment
        saveHighlightText:(BOOL)saveHighlightText
                justified:(BOOL)justified {
    QATrapezoidalLabel *attributedLabel = (QATrapezoidalLabel *)GetAttributedLabel(self);
    NSInteger trapezoidalLineHeight = attributedLabel.trapezoidalLineHeight;
    UIColor *lineBackgroundColor = attributedLabel.lineBackgroundColor;
    
    // 绘制整个label中line的背景色:
    if (lineBackgroundColor && ![lineBackgroundColor isEqual:[UIColor clearColor]]) {
        [self drawAttributedTextBackground:attributedText
                               contentSize:contentSize
                             textAlignment:textAlignment
                     trapezoidalLineHeight:trapezoidalLineHeight
                       lineBackgroundColor:lineBackgroundColor];
    }
    
    // 绘制文案:
    int drawResult = [self drawAttributedText:attributedText
                                  contentSize:contentSize
                                    wordSpace:wordSpace
                            saveHighlightText:saveHighlightText
                                      context:context];
    return drawResult;
}
- (int)drawAttributedText:(NSMutableAttributedString *)attributedText
              contentSize:(CGSize)contentSize
                wordSpace:(CGFloat)wordSpace
        saveHighlightText:(BOOL)saveHighlightText
                  context:(CGContextRef)context {
    QATrapezoidalLabel *attributedLabel = (QATrapezoidalLabel *)GetAttributedLabel(self);
    NSInteger trapezoidalLineHeight = attributedLabel.trapezoidalLineHeight;

    NSArray *trapezoidalTexts = nil;
    NSArray *lines = nil;
    if (saveHighlightText) {   // 绘制attributedText
        trapezoidalTexts = attributedText.trapezoidalTexts_new;
        lines = attributedText.lines;
    }
    else {   // 绘制attributedText(当绘制高亮文案的点击背景色时、此时需要绘制更新后的attributedText的富文本)
        NSMutableArray *trapezoidalTexts_ = [NSMutableArray array];
        NSMutableArray *lines_ = [NSMutableArray array];
        NSInteger location = 0;
        for (NSAttributedString *attributedString in attributedText.trapezoidalTexts_new) {
            NSInteger length = attributedString.length;
            NSAttributedString *attributedString_new = [attributedText attributedSubstringFromRange:NSMakeRange(location, length)];
            [trapezoidalTexts_ addObject:attributedString_new];
            location = location + length;

            CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString_new);
            [lines_ addObject:(__bridge id)line];
            CFRelease(line);
        }
        trapezoidalTexts = trapezoidalTexts_;
        lines = lines_;
    }

    int drawResult = [attributedText drawTrapezoidalWithLineHeight:trapezoidalLineHeight
                                                       contentSize:contentSize
                                                         wordSpace:wordSpace
                                                     textAlignment:attributedLabel.textAlignment
                                                           leftGap:QATrapezoidal_LeftGap
                                                          rightGap:QATrapezoidal_RightGap
                                                             lines:lines
                                                  trapezoidalTexts:trapezoidalTexts
                                                           context:context
                                                 saveHighlightText:saveHighlightText];
    return drawResult;
}
- (void)drawBackgroundWithRects:(NSArray * _Nonnull)highlightRects
                backgroundColor:(UIColor * _Nullable)backgroundColor
                 attributedText:(NSMutableAttributedString *)attributedText
                          range:(NSRange)range {
    // 需要确定点击的高亮文案的位置处于第几行
    NSArray *trapezoidalTexts = attributedText.trapezoidalTexts_new;
    int lineIndex = 0;
    NSInteger length = 0;
    for (int i = 0; i < trapezoidalTexts.count; i++) {
        NSAttributedString *attributedString = [trapezoidalTexts objectAtIndex:i];
        length = length + attributedString.length;
        if (length > range.location) {
            lineIndex = i;
            break;
        }
    }
    
    QATrapezoidalLabel *attributedLabel = (QATrapezoidalLabel *)GetAttributedLabel(self);
    CGFloat trapezoidalLineHeight = attributedLabel.trapezoidalLineHeight;
    
    NSInteger widthAdded = 1;
    NSMutableArray *highlightRects_new = [NSMutableArray array];
    NSArray *lineWidths = attributedText.lineWidths;
    for (int i = 0; i < highlightRects.count; i++) {
        NSValue *rectValue = [highlightRects objectAtIndex:i];
        CGRect rect = rectValue.CGRectValue;
        NSInteger currentLineIndex = lineIndex+i;
        CGFloat lineWidth = [[lineWidths objectAtIndex:currentLineIndex] floatValue];
        CGFloat offsetX = 0;
        if (attributedLabel.textAlignment == NSTextAlignmentRight) {
            offsetX = self.bounds.size.width - lineWidth + QATrapezoidal_LeftGap;
        }
        else if (attributedLabel.textAlignment == NSTextAlignmentLeft) {
            offsetX = QATrapezoidal_LeftGap;
        }
        else {  // NSTextAlignmentCenter
            offsetX = (self.bounds.size.width - lineWidth) / 2. + QATrapezoidal_LeftGap;
        }
        CGFloat offsetY = currentLineIndex*trapezoidalLineHeight;
        CGRect rect_new = CGRectMake(rect.origin.x + offsetX, rect.origin.y + offsetY, rect.size.width+widthAdded, rect.size.height);
        [highlightRects_new addObject:[NSValue valueWithCGRect:rect_new]];
    }
    
    [QABackgroundDraw drawBackgroundWithRects:highlightRects_new
                                       radius:3
                              backgroundColor:backgroundColor];
}
- (void)drawAttributedTextAndTapedBackgroungcolor:(NSMutableAttributedString * _Nonnull)attributedText
                                          context:(CGContextRef _Nonnull)context
                                      contentSize:(CGSize)contentSize
                                        wordSpace:(CGFloat)wordSpace
                                 maxNumberOfLines:(NSInteger)numberOfLines
                                    textAlignment:(NSTextAlignment)textAlignment
                                saveHighlightText:(BOOL)saveHighlightText
                                        justified:(BOOL)justified
                                   highlightRects:(NSArray *)highlightRects
                              textBackgroundColor:(UIColor *)textBackgroundColor
                                            range:(NSRange)range {
    QATrapezoidalLabel *attributedLabel = (QATrapezoidalLabel *)GetAttributedLabel(self);
    NSInteger trapezoidalLineHeight = attributedLabel.trapezoidalLineHeight;
    UIColor *lineBackgroundColor = attributedLabel.lineBackgroundColor;
    
    @autoreleasepool {
        // 绘制整个label中line的背景色:
        if (lineBackgroundColor && ![lineBackgroundColor isEqual:[UIColor clearColor]]) {
            [self drawAttributedTextBackground:attributedText
                                   contentSize:contentSize
                                 textAlignment:textAlignment
                         trapezoidalLineHeight:trapezoidalLineHeight
                           lineBackgroundColor:lineBackgroundColor];
        }
        
        // 绘制高亮文案的背景色:
        if (textBackgroundColor) {
            [self drawBackgroundWithRects:highlightRects
                          backgroundColor:textBackgroundColor
                           attributedText:attributedText
                                    range:range];
        }
        
        // 绘制文案:
        [self drawAttributedText:attributedText
                     contentSize:contentSize
                       wordSpace:wordSpace
               saveHighlightText:saveHighlightText
                         context:context];
    }
}
- (void)getBaseInfoWithContentSize:(CGSize)contentSize
                    attributedText:(NSMutableAttributedString * __strong *)attributedText
                     contentHeight:(CGFloat *)contentHeight {
    QATrapezoidalLabel *attributedLabel = (QATrapezoidalLabel *)GetAttributedLabel(self);
    NSArray *trapezoidalTexts = attributedLabel.trapezoidalTexts;
    if (!trapezoidalTexts || trapezoidalTexts.count == 0) {
        *attributedText = nil;
        *contentHeight = 0;
    }
    
    CGFloat boundsWidth = contentSize.width;
    NSMutableArray *attributedTexts = [NSMutableArray array];
    *attributedText = [self getAttributedStringWithContents:trapezoidalTexts
                                                   maxWidth:boundsWidth
                                          attributedStrings:attributedTexts];
    
    // 在赋值text的情况下更新attributedLabel的 attributedString 的属性值:
    if (attributedLabel.srcAttributedString == nil) {
        [self updateAttributeText:*attributedText forAttributedLabel:attributedLabel];
    }
    
    
    // 获取上下文:
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(contentSize.width, contentSize.height), self.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat trapezoidalLineHeight = attributedLabel.trapezoidalLineHeight;
    if (trapezoidalLineHeight - attributedLabel.font.pointSize <= 3) {  // 异常处理
        trapezoidalLineHeight = attributedLabel.font.pointSize + 4;
        attributedLabel.trapezoidalLineHeight = trapezoidalLineHeight;
    }
    
    // 创建CTLineRef & 更新trapezoidalTexts:
    NSMutableArray *trapezoidalTexts_new = [NSMutableArray array];
    NSMutableArray *lineWidths = [NSMutableArray array];
    NSMutableArray *lines = [NSMutableArray array];
    CGFloat maxLineWidth = contentSize.width - QATrapezoidal_LeftGap - QATrapezoidal_RightGap;
    [self updateContentsHeightWithTrapezoidalTexts:attributedTexts
                                        lineWidths:lineWidths
                                             lines:lines
                              trapezoidalTexts_new:trapezoidalTexts_new
                                           context:context
                                      maxLineWidth:maxLineWidth
                             trapezoidalLineHeight:trapezoidalLineHeight];
    (*attributedText).trapezoidalTexts_new = trapezoidalTexts_new;
    (*attributedText).lines = lines;
    (*attributedText).lineWidths = lineWidths;
    
    *contentHeight = lines.count * trapezoidalLineHeight;
    
    UIGraphicsEndImageContext();
}


#pragma mark - Private Methods -
- (void)getDrawAttributedTextWithLabel:(id)label
                            selfBounds:(CGRect)bounds
                   checkAttributedText:(BOOL(^)(NSString *content))checkBlock
                            completion:(void(^)(NSMutableAttributedString *))completion {
    QATrapezoidalLabel *attributedLabel = label;
    if (attributedLabel.srcAttributedString && attributedLabel.srcAttributedString.lines.count > 0 && completion) {
        completion(attributedLabel.srcAttributedString);
        return;
    }
    
    NSMutableAttributedString *attributedText = nil;
    CGFloat contentHeight = 0;
    [self getBaseInfoWithContentSize:bounds.size attributedText:&attributedText contentHeight:&contentHeight];
    
    if (completion) {
        completion(attributedText);
    }
}
- (NSMutableAttributedString * _Nullable)getAttributedStringWithContents:(NSArray * _Nullable)contents
                                                                maxWidth:(CGFloat)maxWidth
                                                       attributedStrings:(NSMutableArray *)attributedStrings {
    if (!contents) {
        return nil;
    }
    
    NSString *showContent = @"";
    for (NSString *content_ in contents) {
        showContent = [NSString stringWithFormat:@"%@%@",showContent,content_];
    }
    NSMutableAttributedString *attributedString_all = [self getAttributedStringWithString:showContent maxWidth:maxWidth];
    
    for (NSString *content_ in contents) {
        NSMutableAttributedString *attributedString = [self getAttributedStringWithString:content_ maxWidth:maxWidth];
        [attributedStrings addObject:attributedString];
    }
    
    return attributedString_all;
}
- (void)updateLine:(CTLineRef)line
           context:(CGContextRef)context
  attributedString:(NSAttributedString *)attributedString
      maxLineWidth:(NSInteger)maxLineWidth
             lines:(NSMutableArray *)lines
        lineWidths:(NSMutableArray *)lineWidths
  trapezoidalTexts:(NSMutableArray *)trapezoidalTexts {
    
    /**
     CGRect rect_line = CTLineGetImageBounds(line, context);  // 如果attributedString中包含runDelegate此方法返回的宽度有问题
     CGFloat lineWidth = rect_line.size.width;
     */
    
    CGFloat ascent = 0, descent = 0, leading = 0;
    CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    
    
    if (lineWidth - maxLineWidth > 0) {   // 特殊情况
        [self updateLinesWithAttributedString:attributedString
                                 maxLineWidth:maxLineWidth
                                      context:context
                                        lines:lines
                                   lineWidths:lineWidths
                            trapezoidalTexts:trapezoidalTexts];
    }
    else {
        [lines addObject:(__bridge id)line];
        
        lineWidth = lineWidth + QATrapezoidal_LeftGap + QATrapezoidal_RightGap;
        [lineWidths addObject:[NSString stringWithFormat:@"%f",lineWidth]];
        [trapezoidalTexts addObject:attributedString];
    }
}

- (void)updateLinesWithAttributedString:(NSAttributedString *)attributedString
                           maxLineWidth:(CGFloat)maxLineWidth
                                context:(CGContextRef)context
                                  lines:(NSMutableArray *)lines
                             lineWidths:(NSMutableArray *)lineWidths
                      trapezoidalTexts:(NSMutableArray *)trapezoidalTexts {
    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    
    // 创建CTFrame:
    CGSize contentSize = CGSizeMake(maxLineWidth, CGFLOAT_MAX);
    CGRect rect = (CGRect){0, 0, contentSize};
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, attributedString.length), path, NULL);
    
    // 从CTFrame中获取所有的CTLine:
    CFArrayRef allLines = CTFrameGetLines(ctFrame);
    NSInteger numberOfAllLines = CFArrayGetCount(allLines);
    
    for (int lineIndex = 0; lineIndex < numberOfAllLines; lineIndex++) {
        CTLineRef lineRef = CFArrayGetValueAtIndex(allLines, lineIndex);
        CFRange cfrange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(cfrange.location, cfrange.length);
        NSAttributedString *subAttributedString = [attributedString attributedSubstringFromRange:range];
        
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)subAttributedString);
       /**
        CGRect rect_line = CTLineGetImageBounds(line, context);
        CGFloat lineWidth = rect_line.size.width;
        */
        CGFloat ascent = 0, descent = 0, leading = 0;
        CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        [lines addObject:(__bridge id)line];
        CFRelease(line);
        
        lineWidth = lineWidth + QATrapezoidal_LeftGap + QATrapezoidal_RightGap;
        [lineWidths addObject:[NSString stringWithFormat:@"%f",lineWidth]];
        [trapezoidalTexts addObject:subAttributedString];
    }
    
    CFRelease(path);
    CFRelease(ctFramesetter);
    CFRelease(ctFrame);
}
- (void)drawAttributedTextBackground:(NSMutableAttributedString *)attributedText
                         contentSize:(CGSize)contentSize
                       textAlignment:(NSTextAlignment)textAlignment
               trapezoidalLineHeight:(CGFloat)trapezoidalLineHeight
                 lineBackgroundColor:lineBackgroundColor {
    // 设置绘制背景:
    if (textAlignment == NSTextAlignmentLeft) {
        [QABackgroundDraw drawBackgroundWithMaxWidth:contentSize.width
                                          lineWidths:attributedText.lineWidths
                                          lineHeight:trapezoidalLineHeight
                                              radius:6
                                       textAlignment:Background_TextAlignment_Left
                                     backgroundColor:lineBackgroundColor];
    }
    else if (textAlignment == NSTextAlignmentRight) {
        [QABackgroundDraw drawBackgroundWithMaxWidth:contentSize.width
                                          lineWidths:attributedText.lineWidths
                                          lineHeight:trapezoidalLineHeight
                                              radius:6
                                       textAlignment:Background_TextAlignment_Right
                                     backgroundColor:lineBackgroundColor];
    }
    else {   // NSTextAlignmentCenter 其它情况
        [QABackgroundDraw drawBackgroundWithMaxWidth:contentSize.width
                                          lineWidths:attributedText.lineWidths
                                          lineHeight:trapezoidalLineHeight
                                              radius:6
                                       textAlignment:Background_TextAlignment_Center
                                     backgroundColor:lineBackgroundColor];
    }
}

@end
