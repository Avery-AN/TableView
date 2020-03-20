//
//  QATextLayout.m
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QATextLayout.h"
#import "QAAttributedLabelConfig.h"


@interface QATextLayout ()
@property (nonatomic) CGSize size;
@end

@implementation QATextLayout

#pragma mark - life Cycle -
- (void)dealloc {
    // NSLog(@" %s",__func__);
}
- (instancetype)initWithContainerSize:(CGSize)size attributedText:(NSMutableAttributedString *)attributedText {
    if (self = [super init]) {
        [self setUp];
        
        _size = size;
        _attributedText = attributedText;
    }
    return self;
}
+ (instancetype _Nonnull)layoutWithContainerSize:(CGSize)size
                                  attributedText:(NSMutableAttributedString * _Nonnull)attributedText {
    return [[self alloc] initWithContainerSize:size attributedText:attributedText];
}
- (void)setUp {
    _textAttributes = [NSMutableDictionary dictionary];
}


#pragma mark - Public Apis -
- (void)setupContainerSize:(CGSize)size attributedText:(NSMutableAttributedString *)attributedText {
    self.size = size;
    _attributedText = attributedText;
}
- (NSDictionary *)getTruncationTextAttributesWithCheckBlock:(BOOL(^_Nullable)(void))checkBlock {
    if (!_truncationTextAttributes) {
        _truncationTextAttributes = [NSMutableDictionary dictionary];
    }
    else {
        [_truncationTextAttributes removeAllObjects];
    }
    
    // 字号 & 字体:
    CGFloat fontSize;
    NSString *fontName;
    if (self.moreTextFont) {
        fontSize = self.moreTextFont.pointSize;
        fontName = self.moreTextFont.fontName;
    }
    else {
        fontSize = self.font.pointSize;
        fontName = self.font.fontName;
    }
    
    // 判断是否已取消:
    if (checkBlock && checkBlock()) {
        return nil;
    }
    
    // 设置字体:
    CTFontRef fontRef = NULL;
    if (!fontName || fontName.length < 1) {
        fontRef = CTFontCreateWithName(CFSTR("PingFangSC-Regular"), fontSize, NULL);
    }
    else if ([fontName isEqualToString:@".SFUI-Regular"]) {  // "[UIFont systemFontOfSize:];"时获取到的fontName
        fontRef = CTFontCreateWithName(CFSTR("TimesNewRomanPSMT"), fontSize, NULL);
    }
    else {
        fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, fontSize, NULL);
    }
    _truncationTextAttributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    CFRelease(fontRef);
    
    // 设置字体颜色:
    UIColor *textColor = self.moreTextColor;
    _truncationTextAttributes[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    
    // 设置字体背景颜色:
    UIColor *textBackgroundColor = self.moreTextBackgroundColor;
    _truncationTextAttributes[(id)kCTBackgroundColorAttributeName] = (id)textBackgroundColor.CGColor;
    
    // 设置字间距:
    int wordSpace = self.wordSpace;
    CFNumberRef wordsSpaceRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &wordSpace);
    _truncationTextAttributes[(id)kCTKernAttributeName] = (__bridge id)wordsSpaceRef;
    
    // 设置段落样式 (行间距 & 段间距 & 对齐方式 & 换行模式):
    const CFIndex kNumberOfSettings = 6;
    CGFloat lineSpcing = self.lineSpace;             // 行间距
    CGFloat paragraphSpace = self.paragraphSpace;    // 段间距
    CTTextAlignment theAlignment = kCTTextAlignmentJustified;   // 对齐方式
    CTLineBreakMode lineBreakMode = (CTLineBreakMode)self.lineBreakMode; // 换行模式
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpcing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpcing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpcing},
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &theAlignment},
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode},
        {kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpace}
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    _truncationTextAttributes[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    CFRelease(theParagraphRef);
    CFRelease(wordsSpaceRef);
    
    return _truncationTextAttributes;
}
- (NSDictionary *)getTextAttributesWithCheckBlock:(BOOL(^_Nullable)(void))checkBlock {
    if (!_textAttributes) {
        _textAttributes = [NSMutableDictionary dictionary];
    }
    else {
        [_textAttributes removeAllObjects];
    }
    
    // 判断是否已取消:
    if (checkBlock && checkBlock()) {
        return nil;
    }
    
    // 设置字体:
    CGFloat fontSize = self.font.pointSize;
    NSString *fontName = self.font.fontName;
    CTFontRef fontRef = NULL;
    if (!fontName || fontName.length < 1) {
        fontRef = CTFontCreateWithName(CFSTR("PingFangSC-Regular"), fontSize, NULL);  // CFSTR("Georgia")
    }
    else if ([fontName isEqualToString:@".SFUI-Regular"]) {  // "[UIFont systemFontOfSize:];"时获取到的fontName
        fontRef = CTFontCreateWithName(CFSTR("TimesNewRomanPSMT"), fontSize, NULL);
    }
    else {
        fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, fontSize, NULL);
    }
    _textAttributes[(NSString *)kCTFontAttributeName] = (__bridge id)fontRef;
    CFRelease(fontRef);
    // CFBridgingRelease(fontRef); // 把非OC的指针指向OC并且转换成ARC
    
    
    // 设置字体颜色:
    UIColor *textColor = self.textColor;
    _textAttributes[(NSString *)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    
    // 设置字体背景颜色:
    UIColor *textBackgroundColor = [UIColor clearColor];
    _textAttributes[(NSString *)kCTBackgroundColorAttributeName] = (id)textBackgroundColor.CGColor;
    
    // 设置字间距:
    int wordSpace = self.wordSpace;
    CFNumberRef wordsSpaceRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &wordSpace);
    _textAttributes[(NSString *)kCTKernAttributeName] = (__bridge id)wordsSpaceRef;
    CFRelease(wordsSpaceRef);
    // CFBridgingRelease(wordsSpaceRef);
    
    // 设置段落样式 (行间距 & 段间距 & 换行模式 & 对齐方式):
    const CFIndex kNumberOfSettings = 6;
    CGFloat lineSpcing = self.lineSpace;                                    // 行间距
    CGFloat paragraphSpace = self.paragraphSpace;                           // 段间距
    CTLineBreakMode lineBreakMode = (CTLineBreakMode)self.lineBreakMode;    // 换行模式
    CTTextAlignment theAlignment;                                           // 对齐方式
    switch (self.textAlignment) {
        case NSTextAlignmentLeft: {
            theAlignment = kCTTextAlignmentLeft;
        }
            break;
        case NSTextAlignmentCenter: {
            theAlignment = kCTTextAlignmentCenter;
        }
            break;
        case NSTextAlignmentRight: {
            theAlignment = kCTTextAlignmentRight;
        }
            break;
        case NSTextAlignmentJustified: {
            theAlignment = kCTTextAlignmentJustified; // (两端对齐)
        }
            break;
        case NSTextAlignmentNatural: {
            theAlignment = kCTTextAlignmentNatural;
        }
            break;
            
        default:
            break;
    }
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpcing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpcing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpcing},
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &theAlignment},
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode},
        {kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpace}
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    _textAttributes[(NSString *)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    CFRelease(theParagraphRef);
    
    return _textAttributes;
    
    /**
     kCTStrokeWidthAttributeName        笔画线条宽度 必须是CFNumberRef对象，默为0.0f，标准为3.0f
     kCTStrokeColorAttributeName        笔画的颜色属性 必须是CGColorRef 对象，默认为前景色
     kCTSuperscriptAttributeName        设置字体的上下标属性 必须是CFNumberRef对象 默认为0,可为-1为下标,1为上标，需要字体支持才行。
     kCTUnderlineColorAttributeName     字体下划线颜色属性 必须是CGColorRef对象，默认为前景色
     kCTUnderlineStyleAttributeName     字体下划线样式属性 必须是CFNumberRef对象,默为kCTUnderlineStyleNone 可以通过CTUnderlineStypleModifiers 进行修改下划线风格
     kCTVerticalFormsAttributeName      文字的字形方向属性 必须是CFBooleanRef 默认为false，false表示水平方向，true表示竖直方向
     kCTGlyphInfoAttributeName          字体信息属性 必须是CTGlyphInfo对象
     kCTRunDelegateAttributeName        CTRun 委托属性 必须是CTRunDelegate对象
     NSStrikethroughStyleAttributeName  删除线
     
     // 设置下划线颜色:
     [mabstring addAttribute:(id)kCTUnderlineColorAttributeName value:(id)[UIColor redColor].CGColor range:NSMakeRange(0, 6)];
     
     // 设置连写 (连写(Ligature)是一系列连写字母如fi、fl、ffi或ffl; 由于字些字母形状的原因经常被连写):
     long number = 1;
     CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
     [mabstring addAttribute:(id)kCTLigatureAttributeName value:(id)num range:NSMakeRange(0, [str length])];
     
     // 设置空心字:
     long number = 2;
     CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
     [mabstring addAttribute:(id)kCTStrokeWidthAttributeName value:(id)num range:NSMakeRange(0, [str length])];
     
     // 设置空心字颜色:
     [mabstring addAttribute:(id)kCTStrokeColorAttributeName value:(id)[UIColor greenColor].CGColor range:NSMakeRange(0, [str length])];
     */
}


#pragma mark - Properties -
- (void)setFont:(UIFont *)font {
    _font = font;
}
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    _lineBreakMode = lineBreakMode;
}
- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
}
- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    _numberOfLines = numberOfLines;
}
- (void)setLineSpace:(CGFloat)lineSpace {
    _lineSpace = lineSpace;
}
- (void)setWordSpace:(int)wordSpace {
    _wordSpace = wordSpace;
}
- (void)setParagraphSpace:(CGFloat)paragraphSpace {
    _paragraphSpace = paragraphSpace;
}
- (void)setMoreTextFont:(UIFont *)moreTextFont {
    _moreTextFont = moreTextFont;
}
- (void)setMoreTextColor:(UIColor *)moreTextColor {
    _moreTextColor = moreTextColor;
}
- (void)setMoreTextBackgroundColor:(UIColor *)moreTextBackgroundColor {
    _moreTextBackgroundColor = moreTextBackgroundColor;
}
- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
}

- (CGSize)textBoundSize {
    if (self.attributedText && self.attributedText.string &&
        self.attributedText.length > 0 && self.attributedText.string.length > 0) {
        
        self.renderText = self.attributedText;
        CGSize size = [QAAttributedStringSizeMeasurement textSizeWithAttributeString:self.renderText
                                                                maximumNumberOfLines:self.numberOfLines
                                                                            maxWidth:self.size.width];
        
        return size;
    }
    else {
        return CGSizeMake(0, 0);
    }
}

@end
