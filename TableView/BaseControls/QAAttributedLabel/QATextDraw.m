//
//  QATextDraw.m
//  TableView
//
//  Created by Avery An on 2019/12/23.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "QATextDraw.h"
#import "QAAttributedLabelConfig.h"
#import "QATextRunDelegate.h"

static inline CGFloat QAFlushFactorForTextAlignment(NSTextAlignment textAlignment) {
    switch (textAlignment) {
        case NSTextAlignmentCenter:
            return .5;
        case NSTextAlignmentRight:
            return 1.;
        case NSTextAlignmentLeft:
            return 0.;
        default:
            return 0.;
    }
}

@interface NSMutableAttributedString ()

@property (nonatomic) NSInteger currentPositionInRun;;
@property (nonatomic) CGFloat currentPosition_offsetXInRun;;
@property (nonatomic) NSMutableDictionary *saveUnfinishedDic;
@property (nonatomic) NSMutableDictionary *saveLineInfoDic;
@property (nonatomic) CTRunRef currentRun;

/**
 保存需要设为高亮的文案所处的位置
 */
@property (nonatomic, strong) NSMutableArray *highlightRanges_sorted;

@end


@implementation NSMutableAttributedString (TextDraw)

#pragma mark - Public Apis -
/**
 根据size的大小在context里绘制文本attributedString
 */
- (void)drawAttributedTextWithContext:(CGContextRef)context
                          contentSize:(CGSize)size {
    if (context == NULL) {
        return;
    }
    
    NSMutableAttributedString *attributedString = self;
    
    @autoreleasepool {
        // 翻转坐标系:
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // 创建ctFramesetter:
        CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
        
        // 创建绘制路径path:
        CGRect drawRect = (CGRect){0, 0, size};
        CGMutablePathRef drawPath = CGPathCreateMutable();
        CGPathAddRect(drawPath, NULL, drawRect);
        
        // 创建ctFrame:
        CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, 0), drawPath, NULL);
        
        // 绘制:
        CTFrameDraw(ctFrame, context);
        
        // 释放:
        CFRelease(drawPath);
        CFRelease(ctFrame);
        CFRelease(ctFramesetter);
    }
}
- (int)drawAttributedTextWithContext:(CGContextRef)context
                         contentSize:(CGSize)contentSize
                           wordSpace:(CGFloat)wordSpace
                    maxNumberOfLines:(NSInteger)maxNumberOfLines
                       textAlignment:(NSTextAlignment)textAlignment
                   saveHighlightText:(BOOL)saveHighlightText
                           justified:(BOOL)justified {
    if (context == NULL || CGSizeEqualToSize(contentSize, CGSizeZero)) {
        return -10;
    }
    
    NSMutableAttributedString *attributedString = self;
    if (attributedString.highlightFrameDic &&
        attributedString.highlightFrameDic.count > 0) {   // 无需再次获取highlightFrameDic的值
        saveHighlightText = NO;
    }
    
    @autoreleasepool {
        if (saveHighlightText) { // 保存TextInfo的情况
            [self getSortedHighlightRanges:attributedString];
        }
        
        CGFloat contentHeight = contentSize.height;
        CGFloat contentWidth = contentSize.width;
        
        // 翻转坐标系:
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, contentHeight);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // 基于attributedString创建CTFramesetter:
        CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
        
        // 创建绘制路径path:
        CGRect drawRect = (CGRect) {0, 0, contentSize};
        CGMutablePathRef drawPath = CGPathCreateMutable();
        CGPathAddRect(drawPath, NULL, drawRect);
        
        // 创建CTFrame:
        CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, 0), drawPath, NULL);
        /*
         CTFrameDraw(ctFrame, context);
         */
        
        // 从CTFrame中获取所有的CTLine:
        CFArrayRef lines = CTFrameGetLines(ctFrame);
        NSInteger numberOfLines = CFArrayGetCount(lines);  // 展示文案所需要的总行数
        CGPoint lineOrigins[numberOfLines];
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, numberOfLines), lineOrigins);
        
        // 遍历CTFrame中的每一行CTLine:
        for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
            CGPoint lineOrigin = lineOrigins[lineIndex];
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
            
            CGFloat lineDescent = 0.0f, lineAscent = 0.0f, lineLeading = 0.0f;
            double lineWidth = CTLineGetTypographicBounds((CTLineRef)line, &lineAscent, &lineDescent, &lineLeading);
            CGFloat lineHeight = lineAscent + lineDescent;
            CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, QAFlushFactorForTextAlignment(textAlignment), drawRect.size.width); // 获取绘制文本时光笔所需的偏移量
            CGContextSetTextPosition(context, penOffset, lineOrigin.y); // 设置每一行位置
            if (justified && lineIndex == numberOfLines - 1 && lineWidth / contentWidth > 0.80) { // 处理最后一行
                line = CTLineCreateJustifiedLine(line, 1, contentWidth);  // 设置最后一行的两端对齐(当添加了"...全文"之后的情况)
                CTLineDraw(line, context); // 绘制每一行的内容
            }
            else {
                CTLineDraw(line, context); // 绘制每一行的内容
            }
            
            
            // 从CTLine中获取所有的CTRun:
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            long runCounts = CFArrayGetCount(runs);
            
            // 遍历CTLine中的每一个CTRun:
            for (int j = 0; j < runCounts; j++) {
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
                if (delegate) {
                    // 绘制附件的内容:
                    [self drawAttachmentContentInContext:context
                                                 ctframe:ctFrame
                                                    line:line
                                              lineOrigin:lineOrigin
                                                     run:run
                                                delegate:delegate
                                               wordSpace:wordSpace];
                }
                else {
                    // 保存高亮文案在字符中的NSRange以及在CTFrame中的CGRect (以便在label中处理点击事件):
                    if (saveHighlightText) {
                        int result = [self saveHighlightRangeAndFrame:line
                                                              context:context
                                                           lineOrigin:lineOrigin
                                                            lineIndex:lineIndex
                                                           lineHeight:lineHeight
                                                                  run:run
                                                        contentWidth:contentWidth
                                                        contentHeight:contentHeight
                                                     attributedString:attributedString];
                        if (result < 0) {
                            
                            CFRelease(drawPath);
                            CFRelease(ctFrame);
                            CFRelease(ctFramesetter);
                            
                            return result;
                        }
                    }
                }
            }
        }
        
        CFRelease(drawPath);
        CFRelease(ctFrame);
        CFRelease(ctFramesetter);
    }
    
    return 0;
}


#pragma mark - Private Methods -
- (void)getSortedHighlightRanges:(NSMutableAttributedString *)attributedString {
    // 先清空数据
    if (!self.textNewlineDic) {
        self.textNewlineDic = [NSMutableDictionary dictionary];
    }
    else {
        [self.textNewlineDic removeAllObjects];
    }
    if (!self.highlightFrameDic) {
        self.highlightFrameDic = [NSMutableDictionary dictionary];
    }
    else {
        [self.highlightFrameDic removeAllObjects];
    }
    if (!self.highlightRanges_sorted) {
        self.highlightRanges_sorted = [NSMutableArray array];
    }
    else {
        [self.highlightRanges_sorted removeAllObjects];
    }
    if (!self.saveUnfinishedDic) {
        self.saveUnfinishedDic = [NSMutableDictionary dictionary];
    }
    else {
        [self.saveUnfinishedDic removeAllObjects];
    }
    if (!self.saveLineInfoDic) {
        self.saveLineInfoDic = [NSMutableDictionary dictionary];
    }
    else {
        [self.saveLineInfoDic removeAllObjects];
    }
    
    // 保存高亮文案的highlightRange & highlightFont:
    if (attributedString.highlightTextDic && attributedString.highlightTextDic.count > 0) {
        NSArray *allkeys = [attributedString.highlightTextDic allKeys];
        for (NSString *rangeKey in allkeys) { // highlightRanges & highlightFonts数组中的元素表示某一个高亮字符串的range与font (需要注意:数组中元素的index不能乱)
            if (self.highlightRanges_sorted.count == 0) {
                [self.highlightRanges_sorted addObject:rangeKey];
            }
            else {
                NSRange range_current = NSRangeFromString(rangeKey);
                int position = 0;
                for (int k = 0; k < self.highlightRanges_sorted.count; k++) {
                    NSRange range_previous = NSRangeFromString([self.highlightRanges_sorted objectAtIndex:k]);
                    if (range_current.location > range_previous.location) {
                        position++;
                    }
                }
                
                if (self.highlightRanges_sorted.count > position) {
                    [self.highlightRanges_sorted insertObject:rangeKey atIndex:position];
                }
                else {
                    [self.highlightRanges_sorted addObject:rangeKey];
                }
            }
        }
    }
}

- (void)drawAttachmentContentInContext:(CGContextRef)context
                               ctframe:(CTFrameRef)ctFrame
                                  line:(CTLineRef)line
                            lineOrigin:(CGPoint)lineOrigin
                                   run:(CTRunRef)run
                              delegate:(CTRunDelegateRef)delegate
                             wordSpace:(CGFloat)wordSpace {
    QATextRunDelegate *runDelegate = CTRunDelegateGetRefCon(delegate);
    if ([runDelegate isKindOfClass:[QATextRunDelegate class]]) {
        id attachmentContent = runDelegate.attachmentContent;
        if (attachmentContent) {
            if ([attachmentContent isKindOfClass:[UIImage class]]) { // 绘制自定义的Emoji表情
                UIImage *image = (UIImage *)attachmentContent;
                
                // 获取当前CTRun的CGSize:
                CGRect runBounds;
                CGFloat ascent;
                CGFloat descent;
                CGFloat leading;
                {
                    runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading) - wordSpace; // kCTTextAlignmentJustified对齐方式会影响到runBounds.size.width的值
                    runBounds.size.width = runDelegate.width - wordSpace;
                    runBounds.size.height = ascent + descent;
                }
                
                // 获取当前CTRun的CGPoint:
                {
                    CGPoint runPosition = CGPointZero;
                    CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
                    // NSLog(@" runPosition : %@",NSStringFromCGPoint(runPosition));
                    
                    runBounds.origin.x = lineOrigin.x + runPosition.x;
                    runBounds.origin.y = lineOrigin.y;
                    runBounds.origin.y -= descent;
                    
                    // CGFloat offsetX = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                    // NSLog(@"   offsetX : %lf",offsetX);
                }
                
                CGPathRef pathRef = CTFrameGetPath(ctFrame);
                CGRect boundingBox = CGPathGetBoundingBox(pathRef);
                CGRect delegateRect = CGRectOffset(runBounds, boundingBox.origin.x, boundingBox.origin.y);
                
                CGContextDrawImage(context, delegateRect, image.CGImage);  // 绘制image
            }
            else {    // 绘制自定义的其它控件
                /**
                 ......
                 ......
                 */
            }
        }
        else {
            NSLog(@"runDelegate设置有误!");
        }
    }
}
- (CGRect)getRunRectWithAttributedString:(NSMutableAttributedString *)attributedString
                                 context:(CGContextRef)context
                                     run:(CTRunRef)run
                            contentWidth:(CGFloat)contentWidth
                           contentHeight:(CGFloat)contentHeight {
    // 获取高亮文案的Rect:
    /**
     // 获得CTRun的size大小(紧贴文字的bounds、不含文字开头&结尾处的空白)、这个方法比较精确! 但是得到的rect的x的值只有火星人才能搞的懂!
     CTRunGetImageBounds(run, context, CFRangeMake(0, 0));
     
     // 获得CTRun的width(包含文字开头&结尾处的空白):
     CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, &runLeading);
     */
    
    CGRect srcRect = CTRunGetImageBounds(run, context, CFRangeMake(0, 0));
    CGPoint *runPositionsPointer = (CGPoint *)CTRunGetPositionsPtr(run);  // Returns a direct pointer for the glyph position
    CGSize runImageBounds = srcRect.size;
    CGRect runRect = CGRectZero;
    CGFloat originX = (*runPositionsPointer).x;
    CGFloat widthAddedValue = 0;
    if (originX - 1. > 0) {
        runRect.origin.x = originX-1;
        widthAddedValue = 3;
    }
    else {
        runRect.origin.x = originX;
        widthAddedValue = 1.5;
    }
    // runRect.origin.y = floor(contentHeight - (srcRect.origin.y + srcRect.size.height)) - 4;
    runRect.origin.y = contentHeight - (srcRect.origin.y + srcRect.size.height) - 4;
    
    CGFloat forecastWidth = ceil(runImageBounds.width) + widthAddedValue;
    CGFloat diff_forecast = (runRect.origin.x + forecastWidth) - contentWidth;
    CGFloat width = diff_forecast > 0 ? forecastWidth - diff_forecast : forecastWidth;
    CGFloat height = runImageBounds.height+8;  // 此处也可以对最大高度做类似于最大宽度的判断
    runRect.size = CGSizeMake(width, height);
    
    return runRect;
}
- (int)saveHighlightRangeAndFrame:(CTLineRef)line
                          context:(CGContextRef)context
                       lineOrigin:(CGPoint)lineOrigin
                        lineIndex:(CFIndex)lineIndex
                       lineHeight:(CGFloat)lineHeight
                              run:(CTRunRef)run
                     contentWidth:(CGFloat)contentWidth
                    contentHeight:(CGFloat)contentHeight
                 attributedString:(NSMutableAttributedString *)attributedString {
    if (self.currentRun != run) {
        self.currentRun = run;
        self.currentPositionInRun = 0;
        self.currentPosition_offsetXInRun = 0;
    }
    
    CFRange runRange = CTRunGetStringRange(run);
    NSRange currentRunRange = NSMakeRange(runRange.location, runRange.length);
    NSString *runContent = [attributedString.string substringWithRange:currentRunRange];
    NSMutableString *currentRunString = [NSMutableString stringWithString:runContent];
    
    
    for (int i = 0; i < self.highlightRanges_sorted.count; i++) {
        NSString *rangeString = [self.highlightRanges_sorted objectAtIndex:i];
        NSRange highlightRange = NSRangeFromString(rangeString);  // 存放高亮文本的range
        
        // 找出highlightRange与currentRunRange的重合位置:
        NSRange overlappingRange = NSIntersectionRange(highlightRange, currentRunRange);
        if (overlappingRange.length > 0) {
            // 获取高亮文案:
            NSString *highlightText = [attributedString.highlightTextChangedDic valueForKey:rangeString];
            if (!highlightText || highlightText.length == 0) {
                highlightText = [attributedString.highlightTextDic valueForKey:rangeString];
                if (!highlightText || highlightText.length == 0) {
                    continue;
                }
            }
            
            // 保存高亮文案的CGRect & 以及文案的换行信息:
            if (highlightRange.location == currentRunRange.location &&
                highlightRange.length == currentRunRange.length) {
                
                CGRect highlightRect = [self getRunRectWithAttributedString:attributedString
                                                                    context:context
                                                                        run:run
                                                               contentWidth:contentWidth
                                                              contentHeight:contentHeight];
                
                int result = [self saveHighlightRect:highlightRect
                                       highlightText:highlightText
                                  withHighlightRange:highlightRange
                                           lineIndex:lineIndex
                                    attributedString:attributedString];
                if (result < 0) {
                    return result;
                }
                
                currentRunString = nil;
            }
            else {
                if (self.saveUnfinishedDic.count != 0 && i > 0) {   // 检查前一个高亮文案是否已被完整的保存
                    int position = i - 1;
                    NSString *rangeString_previous = [self.highlightRanges_sorted objectAtIndex:position];
                    NSRange highlightRange_previous = NSRangeFromString(rangeString_previous);
                    NSString *highlightText_previous = [attributedString.highlightTextDic valueForKey:rangeString_previous];
                    NSString *highlightText_previous_saved = [self.saveUnfinishedDic valueForKey:rangeString_previous];
                    if (highlightText_previous_saved) {
                        NSInteger length_previousSaved_last = highlightText_previous.length - highlightText_previous_saved.length;
                        NSRange subRange_previous = NSMakeRange(0, length_previousSaved_last);
                        NSString *subHighlightText = [currentRunString substringWithRange:subRange_previous];

                        CGRect highlightRect_previous = [self getRunRectWithAttributedString:attributedString
                                                                                     context:context
                                                                                         run:run
                                                                                contentWidth:contentWidth
                                                                               contentHeight:contentHeight];
                        
                        self.currentPosition_offsetXInRun = highlightRect_previous.size.width;
                        self.currentPositionInRun = subRange_previous.length;

                        int result = [self saveHighlightRect:highlightRect_previous
                                               highlightText:subHighlightText
                                          withHighlightRange:highlightRange_previous
                                                   lineIndex:lineIndex
                                            attributedString:attributedString];
                        if (result < 0) {
                            return result;
                        }
                        
                        [currentRunString deleteCharactersInRange:subRange_previous];
                        
                        result = [self check_saveUnfinishedDicWithHighlightRange:highlightRange_previous
                                                                   highlightText:highlightText_previous
                                                                subHighlightText:nil
                                                                attributedString:attributedString];
                        if (result < 0) {
                            return result;
                        }
                    }
                }
                
                while ([currentRunString hasPrefix:highlightText]) {
                    NSArray *newLineTexts = [self.textNewlineDic valueForKey:NSStringFromRange(highlightRange)];
                    NSInteger totalLength = 0;
                    for (NSString *text in newLineTexts) {
                        totalLength += text.length;
                    }
                    if (totalLength == highlightText.length) {
                        break;
                    }
                    
                    NSRange subRange = NSMakeRange(0, highlightText.length);
                    NSString *subHighlightText = [currentRunString substringWithRange:subRange];

                    CGRect highlightRect = [self getRunRectWithAttributedString:attributedString
                                                                        context:context
                                                                            run:run
                                                                   contentWidth:contentWidth
                                                                  contentHeight:contentHeight];
                    
                    self.currentPosition_offsetXInRun += highlightRect.size.width;
                    self.currentPositionInRun += subRange.length;
                    
                    int result = [self saveHighlightRect:highlightRect
                                           highlightText:subHighlightText
                                      withHighlightRange:highlightRange
                                               lineIndex:lineIndex
                                        attributedString:attributedString];
                    if (result < 0) {
                        return result;
                    }
                    
                    result = [self check_saveUnfinishedDicWithHighlightRange:highlightRange
                                                               highlightText:highlightText
                                                            subHighlightText:subHighlightText
                                                            attributedString:attributedString];
                    if (result < 0) {
                        return result;
                    }
                    
                    [currentRunString deleteCharactersInRange:subRange];
                    NSInteger length = currentRunString.length;
                    subRange = NSMakeRange(0, length);
                    if (currentRunString.length == 0) {
                        break;
                    }
                }
                
                NSRange subRange = NSMakeRange(0, overlappingRange.length);
                while ([highlightText containsString:currentRunString]) {
                    NSArray *newLineTexts = [self.textNewlineDic valueForKey:NSStringFromRange(highlightRange)];
                    NSInteger totalLength = 0;
                    for (NSString *text in newLineTexts) {
                        totalLength += text.length;
                    }
                    if (totalLength == highlightText.length) {
                        break;
                    }
                    
                    if (subRange.length > currentRunString.length) {
                        subRange = NSMakeRange(subRange.location, currentRunString.length);
                    }
                    NSString *subHighlightText = [currentRunString substringWithRange:subRange];
                    
                    CGRect highlightRect = [self getRunRectWithAttributedString:attributedString
                                                                        context:context
                                                                            run:run
                                                                   contentWidth:contentWidth
                                                                  contentHeight:contentHeight];
                    
                    int result = [self saveHighlightRect:highlightRect
                                           highlightText:subHighlightText
                                      withHighlightRange:highlightRange
                                               lineIndex:lineIndex
                                        attributedString:attributedString];
                    if (result < 0) {
                        return result;
                    }
                    
                    result = [self check_saveUnfinishedDicWithHighlightRange:highlightRange
                                                               highlightText:highlightText
                                                            subHighlightText:subHighlightText
                                                            attributedString:attributedString];
                    if (result < 0) {
                        return result;
                    }
                    
                    [currentRunString deleteCharactersInRange:subRange];
                    NSInteger length = currentRunString.length;
                    subRange = NSMakeRange(0, length);
                    if (currentRunString.length == 0) {
                        break;
                    }
                }
            }
            
            if (!currentRunString || currentRunString.length == 0) {
                break;
            }
        }
    }
    
    return 0;
}
- (int)saveHighlightRect:(CGRect)highlightRect
           highlightText:(NSString *)highlightText
      withHighlightRange:(NSRange)highlightRange
               lineIndex:(CFIndex)lineIndex
        attributedString:(NSMutableAttributedString *)attributedString {
    NSMutableArray *highlightRects = [self.highlightFrameDic valueForKey:NSStringFromRange(highlightRange)];
    if (!highlightRects) {
        highlightRects = [NSMutableArray array];
    }
    NSMutableArray *newlineTexts = [self.textNewlineDic valueForKey:NSStringFromRange(highlightRange)];
    if (!newlineTexts) {
        newlineTexts = [NSMutableArray array];
    }
    
    if (highlightRects.count > 0) {
        NSValue *value = [highlightRects lastObject];
        NSString *text = [newlineTexts lastObject];
        CGRect rect = value.CGRectValue;
        
        NSString *line = [self.saveLineInfoDic valueForKey:NSStringFromRange(highlightRange)];
        CFIndex line_index = line.intValue;
        if (line_index == lineIndex) {  // 仍处在同一line里
            CGRect newRect = CGRectMake(rect.origin.x, highlightRect.origin.y, (highlightRect.origin.x - rect.origin.x + highlightRect.size.width), highlightRect.size.height);
            [highlightRects replaceObjectAtIndex:(highlightRects.count-1) withObject:[NSValue valueWithCGRect:newRect]];
            [newlineTexts replaceObjectAtIndex:(highlightRects.count-1) withObject:[NSString stringWithFormat:@"%@%@",text,highlightText]];
        }
        else {
            [highlightRects addObject:[NSValue valueWithCGRect:highlightRect]];
            [newlineTexts addObject:highlightText];
        }
    }
    else {
        [highlightRects addObject:[NSValue valueWithCGRect:highlightRect]];
        [newlineTexts addObject:highlightText];
    }
    
    [self.saveLineInfoDic setValue:@(lineIndex) forKey:NSStringFromRange(highlightRange)];
    [self.highlightFrameDic setValue:highlightRects forKey:NSStringFromRange(highlightRange)];
    [self.textNewlineDic setValue:newlineTexts forKey:NSStringFromRange(highlightRange)];
    
    return 0;
}
- (int)check_saveUnfinishedDicWithHighlightRange:(NSRange)highlightRange
                                   highlightText:(NSString *)highlightText
                                subHighlightText:(NSString *)subHighlightText
                                attributedString:(NSMutableAttributedString *)attributedString {
    NSArray *array = [self.textNewlineDic valueForKey:NSStringFromRange(highlightRange)];
    NSInteger totalLength = 0;
    for (NSString *text in array) {
        totalLength = totalLength + text.length;
    }
    
    if (totalLength == highlightText.length) {
        // [_saveUnfinishedDic removeObjectForKey:NSStringFromRange(highlightRange)];
        [self.saveUnfinishedDic removeAllObjects];
    }
    else if (subHighlightText) {
        [self.saveUnfinishedDic setValue:subHighlightText forKey:NSStringFromRange(highlightRange)];
    }
    
    return 0;
}


#pragma mark - Property -
- (void)setTextNewlineDic:(NSMutableDictionary *)textNewlineDic {
    objc_setAssociatedObject(self, @selector(textNewlineDic), textNewlineDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary *)textNewlineDic {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHighlightFrameDic:(NSMutableDictionary *)highlightFrameDic {
    objc_setAssociatedObject(self, @selector(highlightFrameDic), highlightFrameDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary *)highlightFrameDic {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHighlightRanges_sorted:(NSMutableArray *)highlightRanges_sorted {
    objc_setAssociatedObject(self, @selector(highlightRanges_sorted), highlightRanges_sorted, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableArray *)highlightRanges_sorted {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCurrentPositionInRun:(NSInteger)currentPositionInRun {
    objc_setAssociatedObject(self, @selector(currentPositionInRun), @(currentPositionInRun), OBJC_ASSOCIATION_ASSIGN);
}
- (NSInteger)currentPositionInRun {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setCurrentPosition_offsetXInRun:(CGFloat)currentPosition_offsetXInRun {
    objc_setAssociatedObject(self, @selector(currentPosition_offsetXInRun), @(currentPosition_offsetXInRun), OBJC_ASSOCIATION_ASSIGN);
}
- (CGFloat)currentPosition_offsetXInRun {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

- (void)setSaveUnfinishedDic:(NSMutableDictionary *)saveUnfinishedDic {
    objc_setAssociatedObject(self, @selector(saveUnfinishedDic), saveUnfinishedDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary *)saveUnfinishedDic {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSaveLineInfoDic:(NSMutableDictionary *)saveLineInfoDic {
    objc_setAssociatedObject(self, @selector(saveLineInfoDic), saveLineInfoDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary *)saveLineInfoDic {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCurrentRun:(CTRunRef)currentRun {
    objc_setAssociatedObject(self, @selector(currentRun), (__bridge id _Nullable)(currentRun), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CTRunRef)currentRun {
    return (__bridge CTRunRef)(objc_getAssociatedObject(self, _cmd));
}


@end
