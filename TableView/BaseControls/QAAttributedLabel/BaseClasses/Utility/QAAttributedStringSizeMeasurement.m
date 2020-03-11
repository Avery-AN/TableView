//
//  QAAttributedStringSizeMeasurement.m
//  CoreText
//
//  Created by Avery on 2018/12/12.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QAAttributedStringSizeMeasurement.h"
#import <CoreText/CoreText.h>

@implementation QAAttributedStringSizeMeasurement

+ (CGSize)calculateSizeWithString:(NSAttributedString *)attributedString
                         maxWidth:(NSInteger)maxWidth {
    // 基于attributedString创建CTFramesetter:
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    
    // 获取attributedString所占用的size:
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributedString length]), NULL, CGSizeMake(maxWidth, CGFLOAT_MAX), NULL);
    CFRelease(framesetter);
    
    return CGSizeMake(maxWidth, ceil(size.height));
}

+ (CGSize)textSizeWithAttributeString:(NSMutableAttributedString *)attributedString
                 maximumNumberOfLines:(NSInteger)maximumNumberOfLines
                             maxWidth:(NSInteger)maxWidth {
    // 基于attributedString创建CTFramesetter:
    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    
    // 创建CTFrame:
    CGSize attributedLabelSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    CGRect rect = (CGRect){0, 0, attributedLabelSize};
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, attributedString.length), path, NULL);
    
    CFRange rangeToSize = CFRangeMake(0, (CFIndex)[attributedString length]);
    
    // 从CTFrame中获取所有的CTLine:
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    NSInteger numberOfAllLines = CFArrayGetCount(lines);
    CGPoint lineOrigins[numberOfAllLines];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, numberOfAllLines), lineOrigins);
    if (maximumNumberOfLines < numberOfAllLines) {
        NSInteger lastVisibleLineIndex = 0;
        if (maximumNumberOfLines > 0) {
            lastVisibleLineIndex = MIN((CFIndex)maximumNumberOfLines, numberOfAllLines);
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex); // 取出最后一行
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        else if (maximumNumberOfLines == 0) {
            // lastVisibleLineIndex = numberOfAllLines - 1;
            rangeToSize = CFRangeMake(0, attributedString.length);
        }
    }
    
    
    /*
     CTFramesetterSuggestFrameSizeWithConstraints (
     CTFramesetterRef framesetter,
     CFRange stringRange,
     CFDictionaryRef _Nullable frameAttributes,
     CGSize constraints,
     CFRange * _Nullable fitRange)
     */
    CFRange fitRange = CFRangeMake(0, 0);
    CGSize constraints = CGSizeMake(maxWidth, CGFLOAT_MAX);
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(ctFramesetter, rangeToSize, NULL, constraints, &fitRange);
    // NSLog(@"fitRange-location: %ld; fitRange-length: %ld", fitRange.location, fitRange.length);
    // NSLog(@"suggestedSize: %@", NSStringFromCGSize(suggestedSize));
    
    CFRelease(ctFramesetter);
    CFRelease(ctFrame);
    CFRelease(path);
    
    return CGSizeMake(maxWidth, ceil(suggestedSize.height));
}

@end
