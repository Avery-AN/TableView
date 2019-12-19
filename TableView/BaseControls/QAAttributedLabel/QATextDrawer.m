//
//  QATextDrawer.m
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QATextDrawer.h"
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

@interface QATextDrawer () {
    NSInteger _currentPositionInRun;
    CGFloat _currentPosition_offsetXInRun;
    NSMutableDictionary *_saveUnfinishedDic;
    NSMutableDictionary *_saveLineInfoDic;
    CTRunRef _currentRun;
}

/**
 保存需要设为高亮的文案所处的位置
 */
@property (nonatomic, strong) NSMutableArray *highlightRanges;

@end


@implementation QATextDrawer

#pragma mark - Life Cycle -
- (void)dealloc {
//    NSLog(@"%s",__func__);
    
//    if (_ctFrame) {
//        CFRelease(_ctFrame);
//        _ctFrame = nil;
//    }
}
- (instancetype)init {
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}
- (void)setUp {
    self.textNewlineDic = [NSMutableDictionary dictionary];
    self.highlightFrameDic = [NSMutableDictionary dictionary];
    
    self.highlightRanges = [NSMutableArray array];
}


#pragma mark - Public Apis -
/**
 根据size的大小在context里绘制文本attributedString
 */
- (void)drawAttributedText:(NSMutableAttributedString *)attributedString
                   context:(CGContextRef)context
               contentSize:(CGSize)size {
    if (context == NULL) {
        return;
    }
    else if (!attributedString) {
        return;
    }
    
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

- (int)drawAttributedText:(NSMutableAttributedString *)attributedString
                  context:(CGContextRef)context
              contentSize:(CGSize)size
                wordSpace:(CGFloat)wordSpace
         maxNumberOfLines:(NSInteger)maxNumberOfLines
            textAlignment:(NSTextAlignment)textAlignment
           truncationText:(NSDictionary *)truncationTextInfo
        saveHighlightText:(BOOL)saveHighlightText
               checkBlock:(BOOL(^)(NSString *content))checkBlock {
    if (context == NULL || !attributedString || CGSizeEqualToSize(size, CGSizeZero)) {
        return -10;
    }
    
    @autoreleasepool {
        if (saveHighlightText) { // 保存TextInfo的情况
            
            // 异常处理:
            if (checkBlock && checkBlock(attributedString.string)) {
                return -11;
            }
            
            // 先清空数据
            [self.highlightFrameDic removeAllObjects];
            [self.highlightRanges removeAllObjects];
            [self.textNewlineDic removeAllObjects];

            if (!_saveUnfinishedDic) {
                _saveUnfinishedDic = [NSMutableDictionary dictionary];
            }
            else {
                [_saveUnfinishedDic removeAllObjects];
            }
            if (!_saveLineInfoDic) {
                _saveLineInfoDic = [NSMutableDictionary dictionary];
            }
            else {
                [_saveLineInfoDic removeAllObjects];
            }
            
            // 保存高亮文案的highlightRange & highlightFont:
            if (attributedString.textDic && attributedString.textDic.count > 0) {
                NSArray *allkeys = [attributedString.textDic allKeys];
                for (NSString *rangeKey in allkeys) { // highlightRanges & highlightFonts数组中的元素表示某一个高亮字符串的range与font (需要注意:数组中元素的index不能乱)
                    if (self.highlightRanges.count == 0) {
                        [self.highlightRanges addObject:rangeKey];
                    }
                    else {
                        NSRange range_current = NSRangeFromString(rangeKey);
                        int position = 0;
                        for (int k = 0; k < self.highlightRanges.count; k++) {
                            NSRange range_previous = NSRangeFromString([self.highlightRanges objectAtIndex:k]);
                            if (range_current.location > range_previous.location) {
                                position++;
                            }
                        }
                        
                        if (self.highlightRanges.count > position) {
                            [self.highlightRanges insertObject:rangeKey atIndex:position];
                        }
                        else {
                            [self.highlightRanges addObject:rangeKey];
                        }
                    }
                    
                }
            }
        }
        
        // 翻转坐标系:
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // 基于attributedString创建CTFramesetter:
        CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
        
        // 创建绘制路径path:
        CGRect drawRect = (CGRect) {0, 0, size};
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
            
            // 异常处理:
            if (checkBlock && checkBlock(attributedString.string)) {
                return -12;
            }
            
            CGPoint lineOrigin = lineOrigins[lineIndex];
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
            
            CGFloat lineDescent = 0.0f, lineAscent = 0.0f, lineLeading = 0.0f;
            CTLineGetTypographicBounds((CTLineRef)line, &lineAscent, &lineDescent, &lineLeading);
            CGFloat lineHeight = lineAscent + lineDescent;
            CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, QAFlushFactorForTextAlignment(textAlignment), drawRect.size.width); // 获取绘制文本时光笔所需的偏移量
            CGContextSetTextPosition(context, penOffset, lineOrigin.y); // 设置每一行位置
            CTLineDraw(line, context); // 绘制每一行的内容
            
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
                        CGFloat contentHeight = size.height;
                        int result = [self saveHighlightRangeAndFrame:line
                                                           lineOrigin:lineOrigin
                                                            lineIndex:lineIndex
                                                           lineHeight:lineHeight
                                                                  run:run
                                                        ContentHeight:contentHeight
                                                     attributedString:attributedString
                                                           checkBlock:checkBlock];
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
- (int)saveHighlightRangeAndFrame:(CTLineRef)line
                       lineOrigin:(CGPoint)lineOrigin
                        lineIndex:(CFIndex)lineIndex
                       lineHeight:(CGFloat)lineHeight
                              run:(CTRunRef)run
                    ContentHeight:(CGFloat)contentHeight
                 attributedString:(NSMutableAttributedString *)attributedString
                       checkBlock:(BOOL(^)(NSString *content))checkBlock {
    if (_currentRun != run) {
        _currentRun = run;
        _currentPositionInRun = 0;
        _currentPosition_offsetXInRun = 0;
    }

    // 异常处理:
    if (checkBlock && checkBlock(attributedString.string)) {
        return -20;
    }
    
    CFRange runRange = CTRunGetStringRange(run);
    NSRange currentRunRange = NSMakeRange(runRange.location, runRange.length);
    NSString *runContent = [attributedString.string substringWithRange:currentRunRange];
    NSMutableString *currentRunString = [NSMutableString stringWithString:runContent];
    
    for (int i = 0; i < self.highlightRanges.count; i++) {
        NSString *rangeString = [self.highlightRanges objectAtIndex:i];
        CGFloat runAscent, runDescent, runLeading;
        NSRange highlightRange = NSRangeFromString(rangeString);  // 存放高亮文本的range
        
        // 找出highlightRange与currentRunRange的重合位置:
        NSRange overlappingRange = NSIntersectionRange(highlightRange, currentRunRange);
        if (overlappingRange.length > 0) {
            CGFloat offsetX = CTLineGetOffsetForStringIndex(line, runRange.location, NULL);
            
            // 获取高亮文案:
            NSString *highlightText = [attributedString.textChangedDic valueForKey:rangeString];
            if (!highlightText || highlightText.length == 0) {
                highlightText = [attributedString.textDic valueForKey:rangeString];
                if (!highlightText || highlightText.length == 0) {
                    continue;
                }
            }
            
            // 保存高亮文案的CGRect & 以及文案的换行信息:
            if (highlightRange.location == currentRunRange.location &&
                highlightRange.length == currentRunRange.length) {
                // 获取高亮文案的Rect:
                CGRect runRect;
                runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, &runLeading);
                runRect.origin.x = lineOrigin.x + offsetX;
                runRect.origin.y = lineOrigin.y - runDescent;
                runRect.size.height = lineHeight;
                CGAffineTransform transform = CGAffineTransformMakeTranslation(0, contentHeight);
                transform = CGAffineTransformScale(transform, 1.f, -1.f);
                CGRect highlightRect = CGRectApplyAffineTransform(runRect, transform);
                
                int result = [self saveHighlightRect:highlightRect
                                       highlightText:highlightText
                                  withHighlightRange:highlightRange
                                           lineIndex:lineIndex
                                    attributedString:attributedString
                                          checkBlock:checkBlock];
                if (result < 0) {
                    return result;
                }
                
                currentRunString = nil;
            }
            else {
                if (_saveUnfinishedDic.count != 0 && i > 0) {   // 查看之前的高亮文案是否已被完整的保存
                    int position = i - 1;
                    NSString *rangeString_previous = [self.highlightRanges objectAtIndex:position];
                    NSRange highlightRange_previous = NSRangeFromString(rangeString_previous);
                    NSString *highlightText_previous = [attributedString.textDic valueForKey:rangeString_previous];
                    NSString *highlightText_previous_saved = [_saveUnfinishedDic valueForKey:rangeString_previous];
                    if (highlightText_previous_saved) {
                        NSInteger length_previousSaved_last = highlightText_previous.length - highlightText_previous_saved.length;
                        NSRange subRange_previous = NSMakeRange(0, length_previousSaved_last);
                        NSString *subHighlightText = [currentRunString substringWithRange:subRange_previous];
                        
                        // 获取高亮文案的Rect:
                        CGRect runRect;
                        runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(subRange_previous.location, subRange_previous.length), &runAscent, &runDescent, &runLeading);
                        runRect.origin.x = lineOrigin.x + offsetX;
                        runRect.origin.y = lineOrigin.y - runDescent;
                        runRect.size.height = lineHeight;
                        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, contentHeight);
                        transform = CGAffineTransformScale(transform, 1.f, -1.f);
                        CGRect highlightRect_previous = CGRectApplyAffineTransform(runRect, transform);
                        _currentPosition_offsetXInRun = runRect.size.width;
                        _currentPositionInRun = subRange_previous.length;

                        int result = [self saveHighlightRect:highlightRect_previous
                                               highlightText:subHighlightText
                                          withHighlightRange:highlightRange_previous
                                                   lineIndex:lineIndex
                                            attributedString:attributedString
                                                  checkBlock:checkBlock];
                        if (result < 0) {
                            return result;
                        }
                        
                        [currentRunString deleteCharactersInRange:subRange_previous];
                        
                        result = [self check_saveUnfinishedDicWithHighlightRange:highlightRange_previous
                                                                   highlightText:highlightText_previous
                                                                subHighlightText:nil
                                                                attributedString:attributedString
                                                                      checkBlock:checkBlock];
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
                    
                    // 获取高亮文案的Rect:
                    CGRect runRect;
                    runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(_currentPositionInRun, subRange.length), &runAscent, &runDescent, &runLeading);
                    runRect.origin.x = lineOrigin.x + offsetX + _currentPosition_offsetXInRun;
                    runRect.origin.y = lineOrigin.y - runDescent;
                    runRect.size.height = lineHeight;
                    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, contentHeight);
                    transform = CGAffineTransformScale(transform, 1.f, -1.f);
                    CGRect highlightRect = CGRectApplyAffineTransform(runRect, transform);
                    _currentPosition_offsetXInRun += runRect.size.width;
                    _currentPositionInRun += subRange.length;
                    
                    int result = [self saveHighlightRect:highlightRect
                                           highlightText:subHighlightText
                                      withHighlightRange:highlightRange
                                               lineIndex:lineIndex
                                        attributedString:attributedString
                                              checkBlock:checkBlock];
                    if (result < 0) {
                        return result;
                    }
                    
                    result = [self check_saveUnfinishedDicWithHighlightRange:highlightRange
                                                               highlightText:highlightText
                                                            subHighlightText:subHighlightText
                                                            attributedString:attributedString
                                                                  checkBlock:checkBlock];
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
                    
                    // 获取高亮文案的Rect:
                    CGRect runRect;
                    runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(_currentPositionInRun, subRange.length), &runAscent, &runDescent, &runLeading);
                    runRect.origin.x = lineOrigin.x + offsetX + _currentPosition_offsetXInRun;
                    runRect.origin.y = lineOrigin.y - runDescent;
                    runRect.size.height = lineHeight;
                    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, contentHeight);
                    transform = CGAffineTransformScale(transform, 1.f, -1.f);
                    CGRect highlightRect = CGRectApplyAffineTransform(runRect, transform);
                    
                    int result = [self saveHighlightRect:highlightRect
                                           highlightText:subHighlightText
                                      withHighlightRange:highlightRange
                                               lineIndex:lineIndex
                                        attributedString:attributedString
                                              checkBlock:checkBlock];
                    if (result < 0) {
                        return result;
                    }
                    
                    result = [self check_saveUnfinishedDicWithHighlightRange:highlightRange
                                                               highlightText:highlightText
                                                            subHighlightText:subHighlightText
                                                            attributedString:attributedString
                                                                  checkBlock:checkBlock];
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
        attributedString:(NSMutableAttributedString *)attributedString
              checkBlock:(BOOL(^)(NSString *content))checkBlock {
    NSMutableArray *highlightRects = [self.highlightFrameDic valueForKey:NSStringFromRange(highlightRange)];
    if (!highlightRects) {
        highlightRects = [NSMutableArray array];
    }
    NSMutableArray *newlineTexts = [self.textNewlineDic valueForKey:NSStringFromRange(highlightRange)];
    if (!newlineTexts) {
        newlineTexts = [NSMutableArray array];
    }
    
    // 异常处理:
    if (checkBlock && checkBlock(attributedString.string)) {
        return -30;
    }
    
    if (highlightRects.count > 0) {
        NSValue *value = [highlightRects lastObject];
        NSString *text = [newlineTexts lastObject];
        CGRect rect = value.CGRectValue;
        
        NSString *line = [_saveLineInfoDic valueForKey:NSStringFromRange(highlightRange)];
        CFIndex line_index = line.intValue;
        if (line_index == lineIndex) {  // 仍处在同一line里
            CGRect newRect = CGRectMake(rect.origin.x, highlightRect.origin.y, (rect.size.width + highlightRect.size.width), highlightRect.size.height);
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
    
    [_saveLineInfoDic setValue:@(lineIndex) forKey:NSStringFromRange(highlightRange)];
    [self.highlightFrameDic setValue:highlightRects forKey:NSStringFromRange(highlightRange)];
    [self.textNewlineDic setValue:newlineTexts forKey:NSStringFromRange(highlightRange)];
    
    return 0;
}
- (int)check_saveUnfinishedDicWithHighlightRange:(NSRange)highlightRange
                                   highlightText:(NSString *)highlightText
                                subHighlightText:(NSString *)subHighlightText
                                attributedString:(NSMutableAttributedString *)attributedString
                                      checkBlock:(BOOL(^)(NSString *content))checkBlock {
    NSArray *array = [self.textNewlineDic valueForKey:NSStringFromRange(highlightRange)];
    NSInteger totalLength = 0;
    for (NSString *text in array) {
        totalLength = totalLength + text.length;
    }
    
    // 异常处理:
    if (checkBlock && checkBlock(attributedString.string)) {
        return -40;
    }
    
    if (totalLength == highlightText.length) {
        [_saveUnfinishedDic removeObjectForKey:NSStringFromRange(highlightRange)];
    }
    else if (subHighlightText) {
        [_saveUnfinishedDic setValue:subHighlightText forKey:NSStringFromRange(highlightRange)];
    }
    
    return 0;
}


//#pragma mark - Property -
//- (void)setCtFrame:(CTFrameRef)ctFrame {
//    if (_ctFrame != ctFrame) {
//        if (_ctFrame != nil) {
//            CFRelease(_ctFrame);
//        }
//        if (ctFrame) {
//            CFRetain(ctFrame);
//        }
//        _ctFrame = ctFrame;
//    }
//}

@end

