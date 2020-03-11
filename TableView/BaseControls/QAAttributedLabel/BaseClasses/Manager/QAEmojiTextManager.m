//
//  QAEmojiTextManager.m
//  CoreText
//
//  Created by 我去 on 2018/12/20.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QAEmojiTextManager.h"
#import "QATextRunDelegate.h"
#import "QAAttributedLabelConfig.h"

static void qa_deallocCallback(void *ref) {
    QATextRunDelegate *delegate = (__bridge_transfer QATextRunDelegate *)(ref);
    delegate = nil;
}

static CGFloat qa_ascentCallback(void *ref) {
    QATextRunDelegate *delegate = (__bridge QATextRunDelegate *)(ref);
    return delegate.ascent;
}

static CGFloat qa_descentCallback(void *ref) {
    QATextRunDelegate *delegate = (__bridge QATextRunDelegate *)(ref);
    return delegate.descent;
}

static CGFloat qa_widthCallback(void *ref) {
    QATextRunDelegate *delegate = (__bridge QATextRunDelegate *)(ref);
    return delegate.width;
}


@implementation QAEmojiTextManager

#pragma mark - Public Apis -
+ (int)processDiyEmojiText:(NSMutableAttributedString * _Nonnull)attributedString
                      font:(UIFont * _Nonnull)font
                 wordSpace:(NSUInteger)wordSpace
            textAttributes:(NSDictionary * _Nonnull)textAttributes
                completion:(QAEmojiCompletionBlock _Nullable)completion {
    @autoreleasepool {
        BOOL success = NO;
        NSMutableArray *emojiTexts = [NSMutableArray array];
        NSMutableArray *matches_tmp = [NSMutableArray array];
        
        // 通过正则表达式识别出EmojiText:
        NSRegularExpression *regExpress = [[NSRegularExpression alloc] initWithPattern:QAEmojiRegularExpression options:0 error:nil];
        NSArray *matches = [regExpress matchesInString:attributedString.string options:0 range:NSMakeRange(0, attributedString.string.length)];
        if (matches.count > 0) {
            for (NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
                NSString *emojiText = [attributedString.string substringWithRange:result.range];
                UIImage *image = nil;
                CGSize emojiSize = CGSizeZero;
                if (emojiText && emojiText.length > 2) { // [...]
                    success = YES;
                    
                    /*
                     [matches_tmp addObject:result];
                     [emojiTexts addObject:emojiText];
                     */
                    if (matches_tmp.count == 0) {
                        [matches_tmp addObject:result];
                        [emojiTexts addObject:emojiText];
                    }
                    else {
                        NSTextCheckingResult *result_first = [matches_tmp firstObject];
                        if (result_first.range.location < result.range.location) {
                            [matches_tmp insertObject:result atIndex:0];
                            [emojiTexts insertObject:emojiText atIndex:0];
                        }
                        else {
                            [matches_tmp addObject:result];
                            [emojiTexts addObject:emojiText];
                        }
                    }
                    
                    NSString *imageName = [emojiText substringWithRange:NSMakeRange(1, emojiText.length-2)];
                    image = [UIImage imageNamed:imageName];
                    if (!image) {
                        image = [UIImage imageNamed:@"emoji_default"];  // 默认emoji表情(表示没有匹配到emoji的image)
                    }
                    
                    emojiSize = CGSizeMake(image.size.width + wordSpace, image.size.height);
                    if (font.pointSize - image.size.height < 0) {
                        emojiSize = CGSizeMake(font.pointSize + wordSpace, font.pointSize);
                    }
                    
                    NSMutableAttributedString *emojiAttributedString =
                    [self qa_attachmentWithContent:image
                                    attachmentSize:emojiSize
                                       alignToFont:font
                                    textAttributes:textAttributes
                                         alignment:QATextVerticalAlignmentCenter];
                    [attributedString replaceCharactersInRange:result.range withAttributedString:emojiAttributedString];
                }
            }
        }
        
        if (completion) {
            completion(success, emojiTexts, matches_tmp);
        }
    }
    
    return 0;
}

+ (NSMutableAttributedString *)qa_attachmentWithContent:(nullable id)content
                                         attachmentSize:(CGSize)attachmentSize
                                            alignToFont:(UIFont *)font
                                         textAttributes:(NSDictionary *)textAttributes
                                              alignment:(QATextVerticalAlignment)alignment {
    QATextRunDelegate *delegate = [[QATextRunDelegate alloc] init];
    delegate.attachmentContent = content;
    //delegate.contentMode = contentMode;
    delegate.width = attachmentSize.width;
    delegate.verticalAlignment = alignment;
    switch (alignment) {
        case QATextVerticalAlignmentTop: {
            delegate.ascent = font.ascender;
            delegate.descent = attachmentSize.height - font.ascender;
            if (delegate.descent < 0) {
                delegate.descent = 0;
                delegate.ascent = attachmentSize.height;
            }
        } break;
            
        case QATextVerticalAlignmentCenter: {
            CGFloat fontHeight = font.ascender - font.descender;
            CGFloat yOffset = font.ascender - fontHeight * 0.5;
            delegate.ascent = attachmentSize.height * 0.5 + yOffset;
            delegate.descent = attachmentSize.height - delegate.ascent;
            if (delegate.descent < 0) {
                delegate.descent = 0;
                delegate.ascent = attachmentSize.height;
            }
        } break;
            
        case QATextVerticalAlignmentBottom: {
            delegate.ascent = attachmentSize.height + font.descender;
            delegate.descent = -font.descender;
            if (delegate.ascent < 0) {
                delegate.ascent = 0;
                delegate.descent = attachmentSize.height;
            }
        } break;
            
        default: {
            delegate.ascent = attachmentSize.height;
            delegate.descent = 0;
        } break;
    }
    
    CTRunDelegateCallbacks runDelegateCallbacks;
    runDelegateCallbacks.version = kCTRunDelegateCurrentVersion;
    runDelegateCallbacks.dealloc = qa_deallocCallback;
    runDelegateCallbacks.getAscent = qa_ascentCallback;
    runDelegateCallbacks.getDescent = qa_descentCallback;
    runDelegateCallbacks.getWidth = qa_widthCallback;
    CTRunDelegateRef delegateRef = CTRunDelegateCreate(&runDelegateCallbacks, (__bridge_retained void *)(delegate));
    NSMutableAttributedString *spaceString = [[NSMutableAttributedString alloc] initWithString:QAEmojiSpaceReplaceString attributes:textAttributes];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)spaceString, CFRangeMake(0, 1),
                                   kCTRunDelegateAttributeName, delegateRef);
    /**
     [spaceString addAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)delegateRef range:NSMakeRange(0, 1)];
     */
    
    // 自定义emoji图片的背景色:
    [spaceString addAttribute:(id)kCTBackgroundColorAttributeName value:(__bridge id)[UIColor clearColor].CGColor range:NSMakeRange(0, 1)];
    CFRelease(delegateRef);
    
    return spaceString;
}

@end
