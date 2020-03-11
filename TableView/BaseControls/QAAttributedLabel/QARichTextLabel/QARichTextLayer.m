//
//  QARichTextLayer.m
//  CoreText
//
//  Created by Avery An on 2020/3/4.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QARichTextLayer.h"
#import "QATextDraw.h"
#import "QAHighlightTextManager.h"
#import "QAAttributedLabel.h"
#import "QATextLayout.h"

@implementation QARichTextLayer

#pragma mark - Override Methods -
- (void)display {
    // NSLog(@"%s",__func__);
    super.contents = super.contents;

    QAAttributedLabel *attributedLabel = (QAAttributedLabel *)self.delegate;
    if (!attributedLabel) {
        [self clearAllBackup];
        self.contents = nil;
        return;
    }
    else if (!attributedLabel.text && !attributedLabel.attributedString) {
        [self clearAllBackup];
        self.contents = nil;
        return;
    }
    else if ([self.attributedText_backup isEqual:attributedLabel.attributedString] &&
             attributedLabel.srcAttributedString) {  // label赋值attributedString、并且前后两次赋值一样的情况
        if (self.currentCGImage) {
            self.contents = self.currentCGImage;
            return;
        }
    }
    
    if (attributedLabel.text) {
        [self saveTextBackup:attributedLabel.text];
    }
    else if (attributedLabel.attributedString) {
        [self saveAttributedTextBackup:attributedLabel.attributedString];
    }
    [self fillContents:attributedLabel];
}


#pragma mark - Public Apis -
- (BOOL)isDrawAvailable:(id)label {
    if (!label || ![label isKindOfClass:[QAAttributedLabel class]]) {
        return NO;
    }
    
    QAAttributedLabel *attributedLabel = (QAAttributedLabel *)label;
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        return NO;
    }
    else if ((attributedLabel.attributedString == nil || attributedLabel.attributedString.length == 0) &&
             (attributedLabel.text == nil || attributedLabel.text.length == 0)) {
        self.contents = nil;
        return NO;
    }
    return YES;
}
- (int)drawAttributedText:(NSMutableAttributedString *)attributedText
                  context:(CGContextRef)context
              contentSize:(CGSize)contentSize
                wordSpace:(CGFloat)wordSpace
         maxNumberOfLines:(NSInteger)numberOfLines
            textAlignment:(NSTextAlignment)textAlignment
        saveHighlightText:(BOOL)saveHighlightText
                justified:(BOOL)justified {
    int drawResult = [attributedText drawAttributedTextWithContext:context
                                                       contentSize:contentSize
                                                         wordSpace:wordSpace
                                                  maxNumberOfLines:numberOfLines
                                                     textAlignment:textAlignment
                                                 saveHighlightText:saveHighlightText
                                                         justified:justified];
    return drawResult;
}

- (void)drawBackgroundWithRects:(NSArray *_Nonnull)highlightRects
                backgroundColor:(UIColor *_Nullable)backgroundColor
                 attributedText:(NSMutableAttributedString *)attributedText
                          range:(NSRange)range {
    [QABackgroundDraw drawBackgroundWithRects:highlightRects
                                       radius:3
                              backgroundColor:backgroundColor];
}
- (void)drawAttributedTextAndTapedBackgroungcolor:(NSMutableAttributedString * _Nonnull)attributedText
                                          context:(CGContextRef _Nonnull)context
                                      contentSize:(CGSize)contentSize
                                        wordSpace:(CGFloat)wordSpace
                                 maxNumberOfLines:(NSInteger)numberOfLines
                                    textAlignment:(NSTextAlignment)textAlignment
                                saveHighlightText:(BOOL)saveHighlightText
                                        justified:(BOOL)justified
                                   highlightRects:(NSArray *)highlightRects
                              textBackgroundColor:(UIColor *)textBackgroundColor
                                            range:(NSRange)range {
    // 绘制高亮文案的背景色:
    if (textBackgroundColor) {
        [self drawBackgroundWithRects:highlightRects
                      backgroundColor:textBackgroundColor
                       attributedText:attributedText
                                range:range];
    }

    // 文案的绘制:
    [self drawAttributedText:attributedText
                     context:context
                 contentSize:contentSize
                   wordSpace:wordSpace
            maxNumberOfLines:numberOfLines
               textAlignment:textAlignment
           saveHighlightText:saveHighlightText
                   justified:justified];
}


#pragma mark - Private Methods -
- (void)getDrawAttributedTextWithLabel:(id)label
                            selfBounds:(CGRect)bounds
                   checkAttributedText:(BOOL(^)(NSString *content))checkBlock
                            completion:(void(^)(NSMutableAttributedString *))completion {
    QAAttributedLabel *attributedLabel = label;
    NSString *content = attributedLabel.text;
    CGFloat boundsWidth = bounds.size.width;
    
    NSMutableAttributedString *attributedText = nil;
    if (attributedLabel.srcAttributedString && attributedLabel.attributedString && attributedLabel.attributedString.string.length > 0) {
        attributedText = attributedLabel.attributedString;
        if (self.renderText == nil) {
            self.renderText = attributedLabel.attributedString;
        }
        
        if (completion) {
            completion(attributedText);
        }
        
        
        /**
         // 获取缓存 (mmap 会造成内存瞬间暴涨):
         __weak typeof(self) weakSelf = self;
         [self getCacheWithIdentifier:attributedText
                             finished:^(NSMutableAttributedString * _Nonnull identifier, UIImage * _Nullable image) {
             __strong typeof(weakSelf) strongSelf = weakSelf;

             if (image) {   // Hit Cache
                 NSLog(@"    Hit Cache ~~~");

                 UIGraphicsEndImageContext();
                 strongSelf.currentCGImage = (__bridge id _Nullable)(image.CGImage);
                 strongSelf.contents = nil;
                 strongSelf.contents = strongSelf.currentCGImage;
                 strongSelf->_drawState = QAAttributedLayer_State_Finished;
                 CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
                 CFAbsoluteTime loadTime = endTime - strongSelf->startTime_beginDraw;
                 NSLog(@"loadTime(Mmap-Cache): %f",loadTime);
                 NSLog(@" ");
                 return;
             }
             else {   // Not Hit Cache
                 NSLog(@"   Not Hit Cache ~~~");

                 if (completion) {
                     completion(attributedText, YES);
                 }
             }
         }];
         */
        
        
        /*
         if (attributedLabel.attributedString) {
             attributedText = [self getAttributedStringWithAttributedString:attributedLabel.attributedString
                                                                   maxWidth:boundsWidth];
             
             if (self.attributedText_backup) {
                 self->_attributedText_backup = attributedText;
                 self->_text_backup = nil;
             }
         }
         */
    }
    else {
        // NSLog(@"生成attributedText");
        NSMutableAttributedString *attributedText = [self getAttributedStringWithString:content
                                                                               maxWidth:boundsWidth];
        if (!attributedText) {
            [self clearAttributedBackupContent];
            if (completion) {
                completion(nil);
            }
            return;
        }
        
        [self saveAttributedTextBackup:attributedText];
        [self clearBackupContent];
        
        if (completion) {
            completion(attributedText);
        }
    }
}

@end
