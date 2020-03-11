//
//  QARichTextLabel.m
//  CoreText
//
//  Created by Avery An on 2020/3/4.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QARichTextLabel.h"
#import "QARichTextLayer.h"

@implementation QARichTextLabel

#pragma mark - Override Methods -
+ (Class)layerClass {
    return [QARichTextLayer class];
}


#pragma mark - Public Methods -
- (void)getTextContentSizeWithLayer:(id _Nonnull)layer
                            content:(id _Nonnull)content
                           maxWidth:(CGFloat)maxWidth
                    completionBlock:(GetTextContentSizeBlock _Nullable)block {
    if (!content ||
        (![content isKindOfClass:[NSAttributedString class]] && ![content isKindOfClass:[NSString class]])) {
        return;
    }
    else if (![layer isKindOfClass:[QAAttributedLayer class]]) {
        return;
    }
    self.getTextContentSizeBlock = block;

    NSMutableAttributedString *attributedString = nil;
    if ([content isKindOfClass:[NSAttributedString class]]) {
        attributedString = content;
    }
    else {
        attributedString = [layer getAttributedStringWithString:content maxWidth:maxWidth];
    }

    CGSize suggestedSize = [QAAttributedStringSizeMeasurement textSizeWithAttributeString:attributedString
                                                                     maximumNumberOfLines:self.numberOfLines
                                                                                 maxWidth:maxWidth];

    /*
     dispatch_async(dispatch_get_main_queue(), ^{
        if (self.getTextContentSizeBlock) {
            self.getTextContentSizeBlock(suggestedSize, attributedString);
        }
    });
     */

    if (self.getTextContentSizeBlock) {
        self.getTextContentSizeBlock(suggestedSize, attributedString);
    }
}

// 点击事件是否击中了高亮文本
- (BOOL)isHitHighlightTextWithPoint:(CGPoint)point
                      highlightRect:(CGRect)highlightRect
                     highlightRange:(NSString *)rangeString {
    if (CGRectContainsPoint(highlightRect, point)) {
        return YES;
    }
    return NO;
}

- (CGSize)getContentSize {
    NSMutableAttributedString *attributedText;
    if (self.attributedString && self.attributedString.string &&
        self.attributedString.length > 0 && self.attributedString.string.length > 0) {
        attributedText = self.attributedString;
    }
    else {
        NSDictionary *textAttributes = [self.textLayout getTextAttributesWithCheckBlock:^BOOL{
            return NO;
        }];
        attributedText = [[NSMutableAttributedString alloc] initWithString:self.text attributes:textAttributes];
    }
    
    CGSize size = CGSizeZero;
    if (self.textLayout) {
        [self.textLayout setupContainerSize:(CGSize){self.bounds.size.width, CGFLOAT_MAX} attributedText:attributedText];
        size = self.textLayout.textBoundSize;
    }
    else {
        size = [QAAttributedStringSizeMeasurement calculateSizeWithString:attributedText maxWidth:self.bounds.size.width];
    }
    return size;
}
- (CGImageRef)getLayerContents {
    QARichTextLayer *layer = (QARichTextLayer *)self.layer;
    CGImageRef contentsCGImage = (__bridge CGImageRef)(layer.currentCGImage);
    return contentsCGImage;
}

@end
