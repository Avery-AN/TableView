//
//  QATrapezoidalLabel.m
//  CoreText
//
//  Created by Avery An on 2020/3/4.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QATrapezoidalLabel.h"
#import "QATrapezoidalLayer.h"
#import "QATrapezoidalDraw.h"


@interface QATrapezoidalLabel ()
@property (nonatomic, readonly) NSString *trapezoidalText;
@property (nonatomic, readonly) NSMutableAttributedString *trapezoidalAttributedText;
@property (nonatomic, readonly) NSArray *linesPosition;   // 记录trapezoidalText中需要换行的位置
@end


@implementation QATrapezoidalLabel

#pragma mark - Override Methods -
+ (Class)layerClass {
    return [QATrapezoidalLayer class];
}


#pragma mark - Public Methods -
- (void)getTextContentSizeWithLayer:(id _Nonnull)layer
                            content:(id _Nonnull)content
                           maxWidth:(CGFloat)maxWidth
                    completionBlock:(GetTextContentSizeBlock _Nullable)block {
    if (!content || ![content isKindOfClass:[NSArray class]]) {
        return;
    }
    else if (![layer isKindOfClass:[QATrapezoidalLayer class]]) {
        return;
    }
    self.getTextContentSizeBlock = block;
    
    QATrapezoidalLayer *trapezoidalLayer = layer;
    NSMutableAttributedString *attributedText = nil;
    CGFloat contentHeight = 0;
    CGSize contentSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    [trapezoidalLayer getBaseInfoWithContentSize:contentSize attributedText:&attributedText contentHeight:&contentHeight];
    if (self.getTextContentSizeBlock) {
        self.getTextContentSizeBlock(CGSizeMake(maxWidth, contentHeight), attributedText);
    }
}

- (CGSize)getContentSize {
    CGSize contentSize = CGSizeZero;
    NSMutableAttributedString *attributedText = self.attributedString;
    NSArray *lines = attributedText.lines;
    if (lines) {
        contentSize = CGSizeMake(self.bounds.size.width, lines.count*self.trapezoidalLineHeight);
    }
    else {
    }
    return contentSize;
}
- (CGImageRef)getLayerContents {
    QATrapezoidalLayer *layer = (QATrapezoidalLayer *)self.layer;
    CGImageRef contentsCGImage = (__bridge CGImageRef)(layer.currentCGImage);
    return contentsCGImage;
}

// 点击事件是否击中了高亮文本
- (BOOL)isHitHighlightTextWithPoint:(CGPoint)point
                      highlightRect:(CGRect)highlightRect
                     highlightRange:(NSString *)rangeString {
    BOOL hited = NO;
    
    NSArray *lineIndexs = [self.attributedString.highlightLineDic valueForKey:NSStringFromCGRect(highlightRect)];
    for (int i = 0; i < lineIndexs.count; i++) {
        NSString *lineIndexStr = [lineIndexs objectAtIndex:i];
        NSInteger lineIndex = lineIndexStr.integerValue;
        NSArray *lineWidths = self.attributedString.lineWidths;
        NSString *widthStr = [lineWidths objectAtIndex:lineIndex];
        CGFloat lineWidth = [widthStr floatValue];
        CGFloat offsetX = 0;
        if (self.textAlignment == NSTextAlignmentLeft) {
            offsetX = QATrapezoidal_LeftGap;
        }
        else if (self.textAlignment == NSTextAlignmentRight) {
            offsetX = (self.bounds.size.width - lineWidth) + QATrapezoidal_LeftGap;
        }
        else {
            offsetX = (self.bounds.size.width - lineWidth) / 2. + QATrapezoidal_LeftGap;
        }
        CGFloat offsetY = lineIndex*self.trapezoidalLineHeight + (self.trapezoidalLineHeight-highlightRect.size.height)/2.;
        
        CGRect newRect = CGRectMake(highlightRect.origin.x+offsetX, highlightRect.origin.y + offsetY, highlightRect.size.width, highlightRect.size.height);
        if (CGRectContainsPoint(newRect, point)) {
            hited = YES;
            break;
        }
    }
    
    return hited;
}


#pragma mark - Property -
- (void)setTrapezoidalTexts:(NSArray *)trapezoidalTexts {
    _trapezoidalTexts = [trapezoidalTexts copy];
    self.numberOfLines = 0;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self performSelector:@selector(_commitUpdate)];
#pragma clang diagnostic pop
}

@end
