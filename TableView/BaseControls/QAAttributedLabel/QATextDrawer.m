//
//  QATextDrawer.m
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QATextDrawer.h"
#import "QAAttributedLabelConfig.h"

typedef NS_ENUM(NSUInteger, HighlightContentPosition) {
    HighlightContentPosition_Null = 0,
    HighlightContentPosition_Header,
    HighlightContentPosition_Middle,
    HighlightContentPosition_Taile
};

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
    CFIndex _currentLineIndex;
}
@property (nonatomic, assign) HighlightContentPosition highlightContentPosition;

/**
 保存需要设为高亮的文案所处的位置
 */
@property (nonatomic, strong) NSMutableArray *highlightRanges;

/**
 保存需要设为高亮的文案的字体
 */
@property (nonatomic, strong) NSMutableArray *highlightFonts;
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
    self.highlightFonts = [NSMutableArray array];
    self.highlightRanges = [NSMutableArray array];
    self.highlightFrameDic = [NSMutableDictionary dictionary];
    
    self.textTypeDic = [NSMutableDictionary dictionary];
    self.textDic = [NSMutableDictionary dictionary];
    self.textNewlineDic = [NSMutableDictionary dictionary];
    self.textFontDic = [NSMutableDictionary dictionary];
    self.textForwardColorDic = [NSMutableDictionary dictionary];
    self.textBackgroundColorDic = [NSMutableDictionary dictionary];
    
    _currentLineIndex = -1;
}


#pragma mark - Public Apis -
/**
 根据size的大小在context里绘制文本attributedString
 */
- (void)drawText:(NSMutableAttributedString *)attributedString
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

- (int)drawText:(NSMutableAttributedString *)attributedString
        context:(CGContextRef)context
    contentSize:(CGSize)size
      wordSpace:(CGFloat)wordSpace
maxNumberOfLines:(NSInteger)maxNumberOfLines
  textAlignment:(NSTextAlignment)textAlignment
 truncationText:(NSDictionary *)truncationTextInfo
 isSaveTextInfo:(BOOL)isSave
          check:(BOOL(^)(NSString *content))check
         cancel:(void(^)(void))cancel {
    if (context == NULL || !attributedString || CGSizeEqualToSize(size, CGSizeZero)) {
        return -1;
    }
    
    // 异常处理:
    if (check && check(attributedString.string)) {
        if (cancel) {
            cancel();
        }
        return -1;
    }
    
    @autoreleasepool {
        // 先清空数据
        [self.highlightFrameDic removeAllObjects];
        [self.highlightFonts removeAllObjects];
        [self.highlightRanges removeAllObjects];
        [self.textNewlineDic removeAllObjects];
        
        // 保存TextInfo的情况
        if (isSave) {
            // 保存高亮文案的highlightRange & highlightFont:
            if (self.textFontDic && self.textFontDic.count > 0) {
                NSArray *allkeys = [self.textFontDic allKeys];
                for (NSString *rangeKey in allkeys) { // highlightRanges & highlightFonts数组中的元素表示某一个高亮字符串的range与font (需要注意:数组中元素的index不能乱)
                    [self.highlightRanges addObject:rangeKey];
                    
                    UIFont *font = (UIFont *)[self.textFontDic valueForKey:rangeKey];
                    [self.highlightFonts addObject:font];
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
                    if (isSave) {
                        CGFloat contentHeight = size.height;
                        int result = [self saveHighlightRangeAndFrame:line
                                                           lineOrigin:lineOrigin
                                                            lineIndex:lineIndex
                                                           lineHeight:lineHeight
                                                                  run:run
                                                        ContentHeight:contentHeight
                                                     attributedString:attributedString
                                                                check:check];
                        if (result == -1) {
                            if (cancel) {
                                cancel();
                            }
                            
                            CFRelease(drawPath);
                            CFRelease(ctFrame);
                            CFRelease(ctFramesetter);
                            
                            return -1;
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
                            check:(BOOL(^)(NSString *content))check {
    CFRange runRange = CTRunGetStringRange(run);
    NSRange currentRunRange = NSMakeRange(runRange.location, runRange.length);
    
    for (int k = 0; k < self.highlightRanges.count; k++) {
        NSString *rangeString = [self.highlightRanges objectAtIndex:k];
        // UIFont *highlightFont = [self.highlightFonts objectAtIndex:k];
        CGFloat runAscent, runDescent, runLeading;
        NSRange highlightRange = NSRangeFromString(rangeString);
        
        // 找出highlightRange与currentRunRange的重合位置:
        if (NSIntersectionRange(highlightRange, currentRunRange).length > 0) {
            CGFloat offsetX = CTLineGetOffsetForStringIndex(line, runRange.location, NULL);
            
            if (_currentLineIndex == -1) {
                _currentLineIndex = lineIndex;  // 保存高亮文案的初始line位置
            }
            
            // 获取高亮文案:
            NSString *highlightText = [self.textDic valueForKey:rangeString];
            if (!highlightText) {
                continue;
            }
            
            // 获取高亮文案的Rect:
            CGRect runRect;
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, &runLeading);
            runRect.origin.x = lineOrigin.x + offsetX;
            runRect.origin.y = lineOrigin.y - runDescent;
            runRect.size.height = lineHeight;
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, contentHeight);
            transform = CGAffineTransformScale(transform, 1.f, -1.f);
            CGRect highlightRect = CGRectApplyAffineTransform(runRect, transform);
            
            
            //NSString *encodedKey = [NSString stringWithString:[highlightText stringByRemovingPercentEncoding]];
            NSString *keyString = [NSString stringWithFormat:@"%@%@", attributedString.string, highlightText];
            NSString *encodedKey = [keyString md5Hash];
            
            // 异常处理:
            if (check && check(attributedString.string)) {
                return -1;
            }
            
            // 获取当前CTRunRef展示的文案:
            NSRange range = NSMakeRange((currentRunRange.location - highlightRange.location), currentRunRange.length);
            NSString *currentString = [highlightText substringWithRange:range];
            
            // 保存高亮文案的CGRect & 以及文案的换行信息:
            if (highlightRange.location == currentRunRange.location &&
                highlightRange.length == currentRunRange.length) {
                self.highlightFrameDic[NSStringFromRange(highlightRange)] = [NSArray arrayWithObject:[NSValue valueWithCGRect:highlightRect]];
                
                NSMutableArray *newlineTexts = [NSMutableArray array];
                [newlineTexts addObject:highlightText];
                [self.textNewlineDic setValue:newlineTexts forKey:encodedKey];
            }
            else {
                NSMutableArray *highlightRects = [self.highlightFrameDic valueForKey:NSStringFromRange(highlightRange)];
                if (!highlightRects) {
                    highlightRects = [NSMutableArray array];
                }
                
                NSMutableArray *newlineTexts = [self.textNewlineDic valueForKey:encodedKey];
                if (_currentLineIndex == lineIndex) {
                    if (highlightRects.count > 0) {
                        NSValue *rectValue = [highlightRects lastObject];
                        CGRect rect = [rectValue CGRectValue];
                        CGRect newRect = CGRectMake(rect.origin.x, highlightRect.origin.y, (rect.size.width + highlightRect.size.width), highlightRect.size.height);
                        [highlightRects replaceObjectAtIndex:(highlightRects.count-1) withObject:[NSValue valueWithCGRect:newRect]];
                    }
                    else {
                        [highlightRects addObject:[NSValue valueWithCGRect:highlightRect]];
                    }
                    
                    if (newlineTexts.count > 0) {
                        NSString *previousString = [newlineTexts lastObject];
                        NSString *newString = [NSString stringWithFormat:@"%@%@",previousString,currentString];
                        [newlineTexts replaceObjectAtIndex:(newlineTexts.count-1) withObject:newString];
                    }
                    else {
                        [newlineTexts addObject:currentString];
                    }
                    
                    if ((currentRunRange.location + currentRunRange.length) == (highlightRange.location + highlightRange.length)) { // 高亮文本的尾部
                        // NSLog(@"self.highlightFrameDic: %@",self.highlightFrameDic);
                        // NSLog(@"self.textNewlineDic: %@",self.textNewlineDic);
                        _currentLineIndex = -1;
                    }
                }
                else {  // 已换行
                    [highlightRects addObject:[NSValue valueWithCGRect:highlightRect]];
                    [newlineTexts addObject:currentString];
                    
                    if ((currentRunRange.location + currentRunRange.length) == (highlightRange.location + highlightRange.length)) { // 高亮文本的尾部
                        // NSLog(@"self.highlightFrameDic: %@",self.highlightFrameDic);
                        // NSLog(@"self.textNewlineDic: %@",self.textNewlineDic);
                        _currentLineIndex = -1;
                    }
                    else {
                        _currentLineIndex = lineIndex;
                    }
                }
                
                [self.highlightFrameDic setValue:highlightRects forKey:NSStringFromRange(highlightRange)];
                [self.textNewlineDic setValue:newlineTexts forKey:encodedKey];
            }
        }
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

