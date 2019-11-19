//
//  NSMutableAttributedString+QAAttributedString.m
//  CoreText
//
//  Created by 我去 on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "NSMutableAttributedString+QAAttributedString.h"
#import <objc/runtime.h>
#import "NSString+QAReplace.h"

@implementation NSMutableAttributedString (QAAttributedString)

#pragma mark - Public Apis -
/**
 联合 "...查看全文" 或者 "...全文" 【用truncationText来截断当前的字符串】
 
 @param truncationText 需要追加的文案
 @param maximumNumberOfRows 最多显示的行数
 */
- (NSMutableAttributedString * _Nonnull)joinWithTruncationText:(NSMutableAttributedString * _Nullable)truncationText
                                                      textRect:(CGRect)textRect
                                           maximumNumberOfRows:(NSInteger)maximumNumberOfRows
                                                       ctFrame:(CTFrameRef _Nonnull)ctFrame {
    self.truncationText = truncationText;
    
    // 从CTFrame中获取所有的CTLine:
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    
    if (numberOfLines > maximumNumberOfRows) { // 如果当前的行数多于所设置的最多行数
        numberOfLines = maximumNumberOfRows;
        
        NSInteger lastLineIndex = numberOfLines - 1 < 0 ? 0 : numberOfLines - 1;
        CTLineRef lastLine = CFArrayGetValueAtIndex(lines, lastLineIndex); // 获取最后一行 (第(maximumNumberOfRows-1)行)
        CFRange lastLineRange = CTLineGetStringRange(lastLine); // 获取最后一行的range
        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
        NSMutableAttributedString *cutAttributedString = [[self attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy]; // 截取字符串到最后一行
        NSMutableAttributedString *lastLineAttributeString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy]; // 最后一行显示的字符串
        
        if (!truncationText) {
            CFArrayRef runs = CTLineGetGlyphRuns(lastLine);
            CTRunRef run = CFArrayGetValueAtIndex(runs, CFArrayGetCount(runs) - 1);
            NSDictionary *attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
            NSString *kEllipsesCharacter = @"\u2026";
            truncationText = [[NSMutableAttributedString alloc] initWithString:kEllipsesCharacter attributes:attributes];
        }
        
        /**
         此时最后一行的文案是:"原来文本最后一行的文案 + ...查看全文";
         */
        [lastLineAttributeString appendAttributedString:truncationText];
        
        NSAttributedString *cutedLastLineAttributeString = [self cutAttributeString:lastLineAttributeString withTruncationText:truncationText width:CGRectGetWidth(textRect)];
        cutAttributedString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(0, lastLineRange.location)] mutableCopy];
        [cutAttributedString appendAttributedString:cutedLastLineAttributeString];
        
        return cutAttributedString;
    }
    else {
        return self;
    }
}

/**
 获取链接以及链接的位置
 
 @param ranges 存放获取到的链接的位置数组
 @param links 存放获取到的链接数组
 */
- (void)getLinkUrlStringsSaveWithRangeArray:(NSMutableArray * _Nullable __strong *_Nullable)ranges
                                      links:(NSMutableArray * _Nullable __strong *_Nullable)links {
    NSString *content = self.string;
    [content getLinkUrlStringsSaveWithRangeArray:ranges links:links];
}

/**
 获取at以及at的位置
 
 @param ranges 存放获取到的"@user"的位置数组
 @param ats 存放获取到的"@user"数组
 */
- (void)getAtStringsSaveWithRangeArray:(NSMutableArray * _Nullable __strong *_Nullable)ranges
                                   ats:(NSMutableArray * _Nullable __strong *_Nullable)ats {
    NSString *content = self.string;
    [content getAtStringsSaveWithRangeArray:ranges ats:ats];
}

/**
 获取topic以及topic的位置
 
 @param ranges 存放获取到的"#...#"的位置数组
 @param topics 存放获取到的"#...#"数组
 */
- (void)getTopicsSaveWithRangeArray:(NSMutableArray * _Nullable __strong *_Nullable)ranges
                             topics:(NSMutableArray * _Nullable __strong *_Nullable)topics {
    NSString *content = self.string;
    [content getTopicsSaveWithRangeArray:ranges topics:topics];
}

/**
 获取链接以及链接的位置
 
 @param texts 需要搜索的文案
 @param ranges 存放搜索到的text的位置数组
 */
- (void)searchTexts:(NSArray * _Nonnull)texts
 saveWithRangeArray:(NSMutableArray * _Nullable __strong *_Nullable)ranges {
    NSString *content = self.string;
    for (NSString *text in texts) {
        [content getString:text saveWithRangeArray:ranges];
    }
}

/**
 处理高亮文案的字体属性、将相关属性更新到当前的attributeString中
 
 @param highlightColor 高亮文案的字体颜色
 @param backgroundColor 高亮文案的背景颜色
 @param highlightFont 高亮文案的字体
 @param highlightRange 高亮文案的位置
 */
- (void)updateAttributeStringWithHighlightColor:(UIColor * _Nonnull)highlightColor
                                backgroundColor:(UIColor * _Nullable)backgroundColor
                                  highlightFont:(UIFont * _Nonnull)highlightFont
                                 highlightRange:(NSRange)highlightRange {
    // 高亮字体颜色:
    [self removeAttribute:(NSString *)kCTForegroundColorAttributeName
                    range:highlightRange];
    [self addAttribute:(NSString *)kCTForegroundColorAttributeName
                 value:(id)highlightColor.CGColor
                 range:highlightRange];
    
    // 高亮字体背景色:
    [self removeAttribute:(NSString *)kCTBackgroundColorAttributeName
                    range:highlightRange];
    [self addAttribute:(NSString *)kCTBackgroundColorAttributeName
                 value:(id)backgroundColor.CGColor
                 range:highlightRange];
    
    // 高亮字体:
    CGFloat fontSize = highlightFont.pointSize;
    NSString *fontName = highlightFont.fontName;
    CTFontRef fontRef = NULL;
    if (!fontName || fontName.length < 1) {
        fontRef = CTFontCreateWithName(CFSTR("PingFangSC-Regular"), fontSize, NULL);
    }
    else if ([fontName isEqualToString:@".SFUI-Regular"]) {
        fontRef = CTFontCreateWithName(CFSTR("TimesNewRomanPSMT"), fontSize, NULL);
    }
    else {
        fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, fontSize, NULL);
    }
    [self removeAttribute:(NSString *)kCTFontAttributeName
                    range:highlightRange];
    [self addAttribute:(NSString *)kCTFontAttributeName
                 value:(__bridge id)fontRef
                 range:highlightRange];
    CFRelease(fontRef);
}


#pragma mark - Private Methods -
/**
 此时attributeString的文案是:"原来文本最后一行的文案 + ...查看全文";
 */
- (NSAttributedString *)cutAttributeString:(NSMutableAttributedString *)attributeString
                        withTruncationText:(NSAttributedString *)truncationText
                                     width:(CGFloat)width {
    // 根据合并后的文案创建CTLine:
    CTLineRef needCutedLine = CTLineCreateWithAttributedString((CFAttributedStringRef)attributeString);
    
    // 获取CTLine的宽度:
    CGFloat lastLineWidth = (CGFloat)CTLineGetTypographicBounds(needCutedLine, nil, nil, nil);
    CFRelease(needCutedLine);
    
    if (lastLineWidth - width > 0) { // 如果最后一行的宽度超出其一行的显示区域、就从后往前1位1位的删除之前的文案
        NSString *lastLineString = attributeString.string;
        
        /*
         NSRange range = [lastLineString rangeOfComposedCharacterSequencesForRange:NSMakeRange(lastLineString.length - truncationText.string.length - 1, 1)];
         [attributeString deleteCharactersInRange:range];
         return [self cutAttributeString:attributeString withTruncationText:truncationText width:width];
        */
        
        
        
        
        // 解决Emoji的问题 (PS: 一个系统自带的Emoji表情的长度都大于1):
        NSInteger length = 0;
        NSRange range = [lastLineString rangeOfComposedCharacterSequencesForRange:NSMakeRange(lastLineString.length - truncationText.string.length - 1, length)];
        NSUInteger stringUtf8Length = 0;
        while (stringUtf8Length == 0) {
            length++;
            NSString *contentString = [lastLineString substringToIndex:(lastLineString.length - truncationText.string.length)];
            contentString = [contentString substringToIndex:contentString.length-1];
            stringUtf8Length = [contentString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            lastLineString = [NSString stringWithFormat:@"%@%@",contentString,truncationText.string];
        }
        range.length = length;
        [attributeString deleteCharactersInRange:range];
        return [self cutAttributeString:attributeString withTruncationText:truncationText width:width];
    }
    else {
        return attributeString;
    }
}


#pragma mark - Properties -
- (void)setHighlightRanges:(NSMutableDictionary *)highlightRanges {
    objc_setAssociatedObject(self, @selector(highlightRanges), highlightRanges, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSMutableDictionary *)highlightRanges {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHighlightContents:(NSMutableDictionary *)highlightContents {
    objc_setAssociatedObject(self, @selector(highlightContents), highlightContents, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSMutableDictionary *)highlightContents {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSearchRanges:(NSMutableArray *)searchRanges {
    objc_setAssociatedObject(self, @selector(searchRanges), searchRanges, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSMutableArray *)searchRanges {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSearchAttributeInfo:(NSDictionary *)searchAttributeInfo {
    objc_setAssociatedObject(self, @selector(searchAttributeInfo), searchAttributeInfo, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSDictionary *)searchAttributeInfo {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTruncationInfo:(NSDictionary *)truncationInfo {
    objc_setAssociatedObject(self, @selector(truncationInfo), truncationInfo, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSDictionary *)truncationInfo {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTruncationText:(NSAttributedString *)truncationText {
    objc_setAssociatedObject(self, @selector(truncationText), truncationText, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSAttributedString *)truncationText {
    return objc_getAssociatedObject(self, _cmd);
}

@end
