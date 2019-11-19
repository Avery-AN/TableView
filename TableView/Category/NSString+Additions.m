//
//  NSString+Additions.m
//  Additions
//
//  Created by Johnil on 13-6-15.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "NSString+Additions.h"
#import <CoreText/CoreText.h>

CTTextAlignment _CTTextAlignmentFromUITextAlignment(NSTextAlignment alignment) {
    switch (alignment) {
        case NSTextAlignmentLeft:
            return kCTTextAlignmentLeft;
        case NSTextAlignmentCenter:
            return kCTTextAlignmentCenter;
        case NSTextAlignmentRight:
            return kCTTextAlignmentRight;
            
        default:
            return kCTTextAlignmentNatural;
    }
}

CTLineBreakMode _CTLineBreakModeFromNSLineBreakMode(NSLineBreakMode lineBreakMode) {
    switch (lineBreakMode) {
        case NSLineBreakByWordWrapping:
            return kCTLineBreakByWordWrapping;
        case NSLineBreakByCharWrapping:
            return kCTLineBreakByCharWrapping;
        case NSLineBreakByClipping:
            return kCTLineBreakByClipping;
        case NSLineBreakByTruncatingHead:
            return kCTLineBreakByTruncatingHead;
        case NSLineBreakByTruncatingTail:
            return kCTLineBreakByTruncatingTail;
        case NSLineBreakByTruncatingMiddle:
            return kCTLineBreakByTruncatingMiddle;
            
        default:
            return kCTLineBreakByCharWrapping;
    }
}



@implementation NSString (Additions)

- (NSUInteger)compareTo:(NSString *)comp {
    NSComparisonResult result = [self compare:comp];
    if (result == NSOrderedSame) {
        return 0;
    }
    return result == NSOrderedAscending ? -1 : 1;
}

- (NSUInteger)compareToIgnoreCase:(NSString *)comp {
    return [[self lowercaseString] compareTo:[comp lowercaseString]];
}

- (bool)contains:(NSString *)substring {
    NSRange range = [self rangeOfString:substring];
    return range.location != NSNotFound;
}

- (bool)endsWith:(NSString *)substring {
    NSRange range = [self rangeOfString:substring];
    return range.location == [self length] - [substring length];
}

- (bool)startsWith:(NSString *)substring
{
    NSRange range = [self rangeOfString:substring];
    return range.location == 0;
}

- (NSUInteger)indexOf:(NSString *)substring {
    NSRange range = [self rangeOfString:substring options:NSCaseInsensitiveSearch];
    return range.location == NSNotFound ? -1 : range.location;
}

- (NSUInteger)indexOf:(NSString *)substring startingFrom:(NSUInteger)index {
    NSString *test = [self substringFromIndex:index];
    return index+[test indexOf:substring];
}

- (NSUInteger)lastIndexOf:(NSString *)substring {
    NSRange range = [self rangeOfString:substring options:NSBackwardsSearch];
    return range.location == NSNotFound ? -1 : range.location;
}

- (NSUInteger)lastIndexOf:(NSString *)substring startingFrom:(NSUInteger)index {
    NSString *test = [self substringFromIndex:index];
    return [test lastIndexOf:substring];
}

- (NSString *)substringFromIndex:(NSUInteger)from toIndex:(NSUInteger)to {
    NSRange range;
    range.location = from;
    range.length = to - from;
    return [self substringWithRange: range];
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSArray *)split:(NSString *)token {
    return [self split:token limit:0];
}

- (NSArray *)split:(NSString *)token limit:(NSUInteger)maxResults {
    NSMutableArray* result = [NSMutableArray arrayWithCapacity: 8];
    NSString* buffer = self;
    while ([buffer contains:token]) {
        if (maxResults > 0 && [result count] == maxResults - 1) {
            break;
        }
        NSUInteger matchIndex = [buffer indexOf:token];
        NSString* nextPart = [buffer substringFromIndex:0 toIndex:matchIndex];
        buffer = [buffer substringFromIndex:matchIndex + [token length]];
        [result addObject:nextPart];
    }
    if ([buffer length] > 0) {
        [result addObject:buffer];
    }
    
    return result;
}

- (NSString *)replace:(NSString *)target withString:(NSString *)replacement {
    return [self stringByReplacingOccurrencesOfString:target withString:replacement];
}


#pragma mark - 计算字符串所占大小 -
- (CGSize)sizeWithConstrainedToWidth:(float)width fromFont:(UIFont *)srcFont lineSpace:(float)lineSpace lineBreakMode:(NSLineBreakMode)breakMode textAlignment:(NSTextAlignment)textAlignment {
    return [self sizeWithConstrainedToSize:CGSizeMake(width, CGFLOAT_MAX) fromFont:srcFont lineSpace:lineSpace lineBreakMode:breakMode textAlignment:textAlignment];
}

- (CGSize)sizeWithConstrainedToSize:(CGSize)size fromFont:(UIFont *)srcFont lineSpace:(float)lineSpace lineBreakMode:(NSLineBreakMode)breakMode textAlignment:(NSTextAlignment)textAlignment {
    CGFloat minimumLineHeight = srcFont.pointSize,maximumLineHeight = minimumLineHeight, linespace = lineSpace;
    CTFontRef font;
    if (!srcFont.fontName || [srcFont.fontName isEqualToString:@".SFUI-Regular"]) {
        font = CTFontCreateWithName(CFSTR("TimesNewRomanPSMT"), srcFont.pointSize, NULL);
    }
    else {
        font = CTFontCreateWithName((__bridge CFStringRef)srcFont.fontName, srcFont.pointSize, NULL);
    }
    
    CTLineBreakMode lineBreakMode = _CTLineBreakModeFromNSLineBreakMode(breakMode);
    CTTextAlignment alignment = _CTTextAlignmentFromUITextAlignment(textAlignment);

    //Apply paragraph settings
    CTParagraphStyleRef style = CTParagraphStyleCreate((CTParagraphStyleSetting[6]) {
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
        {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(minimumLineHeight),&minimumLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineHeight,sizeof(maximumLineHeight),&maximumLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(linespace), &linespace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(linespace), &linespace},
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakMode}
    },6);
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font,(NSString*)kCTFontAttributeName,(__bridge id)style,(NSString*)kCTParagraphStyleAttributeName,nil];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self attributes:attributes];
    //    [self clearEmoji:string start:0 font:font1];
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)string;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGSize result = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [string length]), NULL, size, NULL);
    CFRelease(framesetter);
    CFRelease(font);
    CFRelease(style);
    string = nil;
    attributes = nil;

    return result;
}




/*
 
 // 这种绘制的方式可以实现自动换行 (参考“ios页面的渲染(包含image的4个圆角的设置)”工程):
 - (void)drawRect:(CGRect)rect
 {
 CGRect bounds = self.bounds;
 
 NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
 paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
 NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:self.font, NSFontAttributeName,[NSNumber numberWithFloat:lineOffset], NSBaselineOffsetAttributeName, textBackgroundColor,NSBackgroundColorAttributeName, textColor, NSForegroundColorAttributeName, @(NSUnderlineStyleSingle), NSStrikethroughStyleAttributeName, [UIColor greenColor], NSStrikethroughColorAttributeName, @(NSUnderlineStyleSingle), NSUnderlineStyleAttributeName, [UIColor brownColor], NSUnderlineColorAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
 
 CGSize size = [self.diyContent boundingRectWithSize:CGSizeMake(bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
 [self.diyContent drawWithRect:CGRectMake(startX, startY, bounds.size.width - startX*2, size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
 }
 */



#pragma mark - 文本绘制 -
- (void)drawInContext:(CGContextRef)context withPosition:(CGPoint)position font:(UIFont *)font textColor:(UIColor *)color height:(float)height width:(float)width lineBreakMode:(NSLineBreakMode)breakMode textAlignment:(NSTextAlignment)textAlignment {
    CGSize size = CGSizeMake(width, font.pointSize+2);
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0,height);
    CGContextScaleCTM(context,1.0,-1.0);
    
    //Determine default text color
    UIColor* textColor = color;
    
    //Set line height, font, color and break mode
    CTFontRef font1;
    if (!font.fontName || [font.fontName isEqualToString:@".SFUI-Regular"]) {
        font1 = CTFontCreateWithName(CFSTR("TimesNewRomanPSMT"), font.pointSize, NULL);
    }
    else {
        font1 = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    }
    
    //Apply paragraph settings
    CGFloat minimumLineHeight = font.pointSize, maximumLineHeight = minimumLineHeight+2, linespace = 1;
    CTLineBreakMode lineBreakMode = _CTLineBreakModeFromNSLineBreakMode(breakMode);
    CTTextAlignment alignment = _CTTextAlignmentFromUITextAlignment(textAlignment);
    
    //Apply paragraph settings
    CTParagraphStyleRef style = CTParagraphStyleCreate((CTParagraphStyleSetting[6]) {
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
        {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(minimumLineHeight),&minimumLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineHeight,sizeof(maximumLineHeight),&maximumLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(linespace), &linespace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(linespace), &linespace},
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakMode}
    },6);
    
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font1,(NSString*)kCTFontAttributeName,
                                textColor.CGColor,kCTForegroundColorAttributeName,
                                style,kCTParagraphStyleAttributeName,
                                nil];
    //Create path to work with a frame with applied margins
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path,NULL,CGRectMake(position.x, height-position.y-size.height,(size.width),(size.height)));
    
    //Create attributed string, with applied syntax highlighting
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:self attributes:attributes];
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)attributedStr;
    
    //Draw the frame
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(0,CFAttributedStringGetLength(attributedString)),path,NULL);
    CTFrameDraw(ctframe,context);
    CGPathRelease(path);
    CFRelease(font1);
    CFRelease(framesetter);
    CFRelease(ctframe);
    CFRelease(style);
    [[attributedStr mutableString] setString:@""];
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0, height);
    CGContextScaleCTM(context,1.0,-1.0);
}

- (void)drawInContext:(CGContextRef)context withPosition:(CGPoint)position font:(UIFont *)font textColor:(UIColor *)color height:(float)height lineBreakMode:(NSLineBreakMode)breakMode textAlignment:(NSTextAlignment)textAlignment {
    [self drawInContext:context withPosition:position font:font textColor:color height:height width:CGFLOAT_MAX lineBreakMode:breakMode textAlignment:textAlignment];
}

- (void)drawInContext:(CGContextRef)context withPosition:(CGPoint)position font:(UIFont *)font textColor:(UIColor *)color width:(float)width lineBreakMode:(NSLineBreakMode)breakMode textAlignment:(NSTextAlignment)textAlignment {
    [self drawInContext:context withPosition:position font:font textColor:color height:CGFLOAT_MAX width:width lineBreakMode:breakMode textAlignment:textAlignment];
}


- (CGFloat)widthForFont:(UIFont *)font {
    CGSize size = [self sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
    return size.width;
}

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

@end
