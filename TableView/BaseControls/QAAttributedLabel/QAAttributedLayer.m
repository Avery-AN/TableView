//
//  QAAttributedLayer.m
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QAAttributedLayer.h"
#import "QAAttributedLabel.h"
#import "QATextLayout.h"
#import "QATextDrawer.h"
#import "QAAttributedLabelConfig.h"

@interface QAAttributedLayer () {
    NSRange _currentTapedRange;  // 当点击高亮文案时保存点击处的range
    __block NSDictionary *_currentTapedAttributeInfo;  // 当点击高亮文案时保存点击处的attributeInfo
    __block NSMutableArray *_currentTapedAttributeInfo_other;  // 当点击高亮文案时保存点击处文案里包含的其它高亮文本的attributeInfo (PS: 高亮文案中包含有搜索到的高亮文案)
}
@property (nonatomic, strong, nullable) NSMutableAttributedString *renderText;
@property (nonatomic, copy, nullable, readonly) NSMutableAttributedString *attributedText_backup;
@property (nonatomic, copy, nullable, readonly) NSString *text_backup;
@end

@implementation QAAttributedLayer

#pragma mark - Life Cycle -
- (void)dealloc {
//    NSLog(@"%s",__func__);
}
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}


#pragma mark - Override Methods -
- (void)display {
    [super display];
    
    QAAttributedLabel *attributedLabel = (QAAttributedLabel *)self.delegate;
    if (!attributedLabel) {
        self->_attributedText_backup = nil;
        self->_text_backup = nil;
        self.contents = nil;
        return;
    }
    else if ([self.attributedText_backup isEqual:attributedLabel.attributedText]) {
        if (self.currentCGImage) {
            self.contents = self.currentCGImage;
        }
        return;
    }
    else {  // 前后两次display时文案不一致的情况
        if (attributedLabel.attributedText) {
            self->_attributedText_backup = attributedLabel.attributedText;
        }
        else if (attributedLabel.text) {
            self->_text_backup = attributedLabel.text;
        }
        [self fillContents:attributedLabel];
    }
}


#pragma mark - Public Apis -
- (NSMutableAttributedString * _Nullable)getAttributedStringWithString:(NSString * _Nonnull)content
                                                              maxWidth:(CGFloat)width {
    NSString *showContent = [content copy];
    QAAttributedLabel *attributedLabel = (QAAttributedLabel *)self.delegate;

    // 获取需要高亮显示的文案与位置 (link & @user & topic):
    NSMutableDictionary *highlightContents = [NSMutableDictionary dictionary];
    NSMutableDictionary *highlightRanges = [NSMutableDictionary dictionary];
    [QAHighlightTextManager getHighlightInfoWithContent:&showContent
                                        isLinkHighlight:attributedLabel.linkHighlight
                                        isShowShortLink:attributedLabel.showShortLink
                                              shortLink:attributedLabel.shortLink
                                          isAtHighlight:attributedLabel.atHighlight
                                       isTopicHighlight:attributedLabel.topicHighlight
                                      highlightContents:&highlightContents
                                        highlightRanges:&highlightRanges];
    
    // 生成NSMutableAttributedString:
    if (!attributedLabel.textLayout.textAttributes ||
        attributedLabel.textLayout.textAttributes.count == 0) {
        [attributedLabel.textLayout getTextAttributes];
    }
    
    /* 转换UTF8
     [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  // iOS 9以前
     [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];  // iOS 9以后
     */
    __block NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:showContent attributes:attributedLabel.textLayout.textAttributes];
    
    // 处理自定义的Emoji:
    [QAEmojiTextManager processDiyEmojiText:attributedText
                                       font:attributedLabel.font
                                  wordSpace:attributedLabel.wordSpace
                             textAttributes:attributedLabel.textLayout.textAttributes
                                 completion:^(BOOL success, NSArray * _Nullable emojiTexts, NSArray * _Nullable matches) {
                                     if (success && emojiTexts.count > 0 && highlightRanges.count > 0) {
                                         for (int i = 0; i < emojiTexts.count; i++) {
                                             NSString *emojiText = [emojiTexts objectAtIndex:i];
                                             NSTextCheckingResult *result = [matches objectAtIndex:i];
                                             
                                             NSMutableArray *linkRanges = [highlightRanges valueForKey:@"link"];
                                             if (linkRanges && linkRanges.count > 0) {
                                                 [self processEmojiRangeWithRanges:linkRanges emojiText:emojiText result:result];
                                             }
                                             
                                             NSMutableArray *atRanges = [highlightRanges valueForKey:@"at"];
                                             if (atRanges && atRanges.count > 0) {
                                                 [self processEmojiRangeWithRanges:atRanges emojiText:emojiText result:result];
                                             }

                                             NSMutableArray *topicRanges = [highlightRanges valueForKey:@"topic"];
                                             if (topicRanges && topicRanges.count > 0) {
                                                 [self processEmojiRangeWithRanges:topicRanges emojiText:emojiText result:result];
                                             }
                                         }
                                     }
                                 }];
    
    // 处理SeeMoreText & 生成renderText (更新了attributedText中SeeMoreText的文本属性):
    if (attributedLabel.numberOfLines == 0) {  // numberOfLines值为0时表示需要显示所有文本
        self.renderText = attributedText;
        self.truncationInfo = nil;
    }
    else {
        CGSize size = CGSizeMake(width, CGFLOAT_MAX);
        [self processSeemoreText:attributedText
                            size:size
                      completion:^(BOOL showMoreTextEffected, NSMutableAttributedString * _Nonnull attributedString) {
                                  if (showMoreTextEffected == YES) {
                                      attributedText = attributedString;

                                      // 特殊情况处理:
                                      if (self.truncationInfo && self.truncationInfo.count > 0
                                          && highlightRanges.count > 0) {
                                        NSString *truncationRangeString = [self.truncationInfo valueForKey:@"truncationRange"];
                                        if (truncationRangeString) {
                                            NSRange truncationRange = NSRangeFromString(truncationRangeString);

                                            NSMutableArray *linkRanges = [highlightRanges valueForKey:@"link"];
                                            NSMutableArray *linkContents = [highlightContents valueForKey:@"link"];
                                            if (linkRanges && linkRanges.count > 0 &&
                                                linkContents && linkContents.count > 0) {
                                                [self processSeemoreRangeWithRanges:linkRanges
                                                                           contents:linkContents
                                                                    truncationRange:truncationRange];
                                            }
                                            
                                            NSMutableArray *atRanges = [highlightRanges valueForKey:@"at"];
                                            NSMutableArray *atContents = [highlightContents valueForKey:@"at"];
                                            if (atRanges && atRanges.count > 0 &&
                                                atContents && atContents.count > 0) {
                                                [self processSeemoreRangeWithRanges:atRanges
                                                                           contents:atContents
                                                                    truncationRange:truncationRange];
                                            }

                                            NSMutableArray *topicRanges = [highlightRanges valueForKey:@"topic"];
                                            NSMutableArray *topicContents = [highlightContents valueForKey:@"topic"];
                                            if (topicRanges && topicRanges.count > 0 &&
                                                topicContents && topicContents.count > 0) {
                                                [self processSeemoreRangeWithRanges:topicRanges
                                                                           contents:topicContents
                                                                    truncationRange:truncationRange];
                                            }
                                        }
                                    }
                                  }
                                }];
    }
    
    // 获取highLightTexts设置的需要高亮显示文案的range
    if (attributedLabel.highLightTexts.count > 0) {
        NSMutableDictionary *highlightRanges = [NSMutableDictionary dictionary];
        [QAHighlightTextManager getHighlightRangeWithContent:attributedText.string
                                              highLightTexts:attributedLabel.highLightTexts
                                             highlightRanges:&highlightRanges];

        [self setHighlightAttributeInfoForAttributedText:attributedText
                                         highlightRanges:highlightRanges];
    }

    // 设置attributedText中需要高亮显示的文本(link & at & topic)的属性:
    if (highlightRanges.count > 0) {
        [self setHighlightAttributeInfoForAttributedText:attributedText
                                         highlightRanges:highlightRanges];
    }
    
    /**
     保存高亮相关信息(link & at & topic & Seemore)到attributedText中 (drawTextBackgroundWithAttributedString时使用、从内存的角度上
     来说不太友好):
     */
    attributedText.highlightRanges = highlightRanges;
    attributedText.highlightContents = highlightContents;
    attributedText.truncationInfo = self.truncationInfo;
    if (attributedText.textTypeDic == nil) {
        attributedText.textTypeDic = [NSMutableDictionary dictionary];
    }
    if (attributedText.textDic == nil) {
        attributedText.textDic = [NSMutableDictionary dictionary];
    }
    if (attributedText.textChangedDic == nil) {
        attributedText.textChangedDic = [NSMutableDictionary dictionary];
    }

    // 更新attributedLabel的 attributedText & text 的属性值:
    [self updateAttributeText:attributedText forAttributedLabel:attributedLabel];
    
    return attributedText;
}
- (void)drawHighlightColor:(NSRange)range {
    self.currentCGImage = self.contents;   // 保存当前的self.contents以供clearHighlightColor方法中使用
    
    QAAttributedLabel *attributedLabel = (QAAttributedLabel *)self.delegate;
    NSMutableAttributedString *attributedText = attributedLabel.attributedText;
    CGRect bounds = attributedLabel.bounds;
    
    if ((attributedLabel.text && [attributedLabel.text isKindOfClass:[NSString class]] && attributedLabel.text.length > 0) ||
        (attributedText && [attributedText isKindOfClass:[NSAttributedString class]] && attributedText.length > 0)) {
        if (attributedText.showMoreTextEffected &&
            attributedLabel.showMoreText && attributedLabel.numberOfLines != 0 && attributedText.showMoreTextEffected &&
            (range.location == attributedText.length - attributedLabel.seeMoreText.length)) {  // 处理SeeMore的高亮
            [self drawContentsImage:attributedText
                             bounds:bounds
                            inRange:range
                          textColor:attributedLabel.moreTapedTextColor
                textBackgroundColor:attributedLabel.moreTapedBackgroundColor
                         truncation:YES];
        }
        else {  // 处理 Links & At & Topic 的高亮
            NSString *contentType = [attributedText.textTypeDic valueForKey:NSStringFromRange(range)];
            UIColor *tapedTextColor = nil;
            UIColor *tapedBackgroundColor = nil;
            [self getTapedTextColor:&tapedTextColor
               tapedBackgroundColor:&tapedBackgroundColor
                    withContentType:contentType
                            inLabel:attributedLabel];
            
            [self drawContentsImage:attributedText
                             bounds:bounds
                            inRange:range
                          textColor:tapedTextColor
                textBackgroundColor:tapedBackgroundColor
                         truncation:NO];
        }
    }
}

/**
 针对ranges处的text批量进行高亮绘制 (SearchText时使用)
 */
- (void)drawHighlightColorWithSearchRanges:(NSArray * _Nonnull)ranges
                             attributeInfo:(NSDictionary * _Nonnull)info {
    QAAttributedLabel *attributedLabel = (QAAttributedLabel *)self.delegate;
    NSMutableAttributedString *attributedText = attributedLabel.attributedText;
    CGRect bounds = attributedLabel.bounds;
    
    // 更新attributedText的相关属性设置 (设置attributedText中搜索到的文案的高亮属性):
    UIColor *textColor = [info valueForKey:@"textColor"];
    UIColor *textBackgroundColor = [info valueForKey:@"textBackgroundColor"];
    for (NSString *rangeString in ranges) {
        NSRange range = NSRangeFromString(rangeString);
        [self updateAttributeText:attributedText
                    withTextColor:textColor
              textBackgroundColor:textBackgroundColor
                            range:range];
    }
    
    // 更新attributedLabel的 attributedText & text 的属性值:
    [self updateAttributeText:attributedText forAttributedLabel:attributedLabel];
    
    // 获取上下文:
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(bounds.size.width, bounds.size.height), self.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 文案的绘制:
    NSInteger numberOfLines = attributedLabel.numberOfLines;
    [self.textDrawer drawAttributedText:attributedText
                                context:context
                            contentSize:bounds.size
                              wordSpace:attributedLabel.wordSpace
                       maxNumberOfLines:numberOfLines
                          textAlignment:attributedLabel.textAlignment
                         truncationText:attributedText.truncationInfo
                      saveHighlightText:NO
                    checkAttributedText:nil
                                 cancel:nil];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.contents = (__bridge id _Nullable)(image.CGImage);
    
    self.currentCGImage = self.contents;   // 保存当前的self.contents以供clearHighlightColor方法中使用
}

- (void)clearHighlightColor:(NSRange)range {
    if (self.currentCGImage) {
        self.contents = self.currentCGImage;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 清除当点击高亮文案时所做的文案高亮属性的修改 (将点击时添加的高亮颜色去掉、并恢复到点击之前的颜色状态):
            QAAttributedLabel *attributedLabel = (QAAttributedLabel *)self.delegate;
            NSMutableAttributedString *attributedText = attributedLabel.attributedText;
            if (attributedText) {
                // 更新attributedText的相关属性设置:
                [self updateAttributeText:attributedText
                            withTextColor:nil
                      textBackgroundColor:nil
                                    range:self->_currentTapedRange];
            }
            
            self->_currentTapedRange = NSMakeRange(0, 0);  // 清理
            self->_currentTapedAttributeInfo = nil;
            self->_currentTapedAttributeInfo_other = nil;
        });
    }
}
- (void)drawTextBackgroundWithAttributedString:(NSMutableAttributedString * _Nonnull)attributedString {
    dispatch_async(dispatch_queue_create("DrawTextBackground_asyncQueue", NULL), ^{
        QAAttributedLabel *attributedLabel = (QAAttributedLabel *)self.delegate;
        CGRect bounds = attributedLabel.bounds;
        CGFloat boundsWidth = bounds.size.width;
        CGFloat boundsHeight = bounds.size.height;
        
        // 保存高亮相关信息(link & at & topic & Seemore)到layer的textDraw中:
        [self saveHighlightRanges:attributedString.highlightRanges
                highlightContents:attributedString.highlightContents
                   truncationInfo:attributedString.truncationInfo
                  attributedLabel:attributedLabel
                 attributedString:attributedString
              checkAttributedText:nil
                           cancel:nil];
        
        // 获取上下文:
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(bounds.size.width, bounds.size.height), self.opaque, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGSize contentSize = CGSizeMake(ceil(boundsWidth), ceil(boundsHeight));
        NSInteger numberOfLines = attributedLabel.numberOfLines;
        [self.textDrawer drawAttributedText:attributedString
                                    context:context
                                contentSize:contentSize
                                  wordSpace:attributedLabel.wordSpace
                           maxNumberOfLines:numberOfLines
                              textAlignment:attributedLabel.textAlignment
                             truncationText:attributedString.truncationInfo
                          saveHighlightText:YES
                        checkAttributedText:nil
                                     cancel:nil];
    });
}


#pragma mark - Private Methods -
- (void)fillContents:(QAAttributedLabel *)attributedLabel {
    // NSLog(@"   %s",__func__);
    
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        return;
    }
    else if (attributedLabel.attributedText == nil || attributedLabel.attributedText.length == 0) {
        if (attributedLabel.text == nil || attributedLabel.text.length == 0) {
            self.contents = nil;
            return;
        }
    }
    
    if (attributedLabel.display_async) {
        [self fillContents_async:attributedLabel];
    }
    else {
        [self fillContents_sync:attributedLabel];
    }
}
- (void)fillContents_async:(QAAttributedLabel *)attributedLabel {
    // NSLog(@"   %s",__func__);
    
    CGColorRef backgroundCgcolor = attributedLabel.backgroundColor.CGColor;
    CGRect bounds = self.bounds;
    
    dispatch_async(dispatch_queue_create("SetFillContents_asyncQueue", NULL), ^{
        // 获取上下文:
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(bounds.size.width, bounds.size.height), self.opaque, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // 给上下文填充背景色:
        CGContextSetFillColorWithColor(context, backgroundCgcolor);
        CGContextFillRect(context, bounds);
        
        // 绘制文案:
        __weak typeof(self) weakSelf = self;
        [self fillContentsWithContext:context
                                label:attributedLabel
                           selfBounds:bounds
                  checkAttributedText:^BOOL (NSString *content) {
                                    // 检查绘制是否应该被取消:
                                    return [self checkWithContent:content];
                                } cancel:^{
                                    NSLog(@"绘制被取消!!!");
                                    UIGraphicsEndImageContext();
                                } completion:^{
                                    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                                    image = [image decodeImage];  // image的解码
                                    weakSelf.currentCGImage = (__bridge id _Nullable)(image.CGImage);
                                    UIGraphicsEndImageContext();
            
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        self.contents = weakSelf.currentCGImage;
                                    });
                                }];
    });
}
- (void)fillContents_sync:(QAAttributedLabel *)attributedLabel {
    // NSLog(@"   %s",__func__);
    
    // 获取上下文:
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.bounds.size.width, self.bounds.size.height), self.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 给上下文填充背景色:
    CGContextSetFillColorWithColor(context, attributedLabel.backgroundColor.CGColor);
    CGContextFillRect(context, attributedLabel.bounds);
    
    // 绘制文案:
    [self fillContentsWithContext:context
                            label:attributedLabel
                       selfBounds:self.bounds
              checkAttributedText:^BOOL (NSString *content) {
                                    // 检查绘制是否应该被取消:
                                    return [self checkWithContent:content];
                                } cancel:^{
                                    NSLog(@"绘制被取消!!!");
                                    UIGraphicsEndImageContext();
                                } completion:^{
                                    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                                    UIGraphicsEndImageContext();
                                    image = [image decodeImage];  // image的解码
                                    self.currentCGImage = (__bridge id _Nullable)(image.CGImage);
                                    self.contents = self.currentCGImage;
                                }];
}
- (void)fillContentsWithContext:(CGContextRef)context
                          label:(QAAttributedLabel *)attributedLabel
                     selfBounds:(CGRect)bounds
            checkAttributedText:(BOOL(^)(NSString *content))checkAttributedText
                         cancel:(void(^)(void))cancel
                     completion:(void(^)(void))completion {
    NSString *content = attributedLabel.text;
    CGFloat boundsWidth = bounds.size.width;
    CGFloat boundsHeight = bounds.size.height;
    
    NSMutableAttributedString *attributedText = nil;
    if (attributedLabel.attributedText &&
        attributedLabel.attributedText.string &&
        attributedLabel.attributedText.string.length > 0) {
        attributedText = [attributedLabel.attributedText mutableCopy];
        NSDictionary *dic = [attributedLabel.attributedText getInstanceProperty];
        [attributedText setFunctions:dic];
    }
    else {
        if (content == nil) {
            return;
        }
        attributedText = [self getAttributedStringWithString:content
                                                    maxWidth:boundsWidth];
        
        if (self.text_backup) {
            self->_attributedText_backup = attributedText;
            self->_text_backup = nil;
        }
    }
    
    // 保存高亮相关信息(link & at & Topic & Seemore)到attributedText中:
    int saveResult = [self saveHighlightRanges:attributedText.highlightRanges
                             highlightContents:attributedText.highlightContents
                                truncationInfo:attributedText.truncationInfo
                               attributedLabel:attributedLabel
                              attributedString:attributedText
                           checkAttributedText:checkAttributedText
                                        cancel:cancel];
    if (saveResult == -1) {
        return;
    }
    
    CGSize contentSize = CGSizeMake(ceil(boundsWidth), ceil(boundsHeight));
    NSInteger numberOfLines = attributedLabel.numberOfLines;
    int drawResult = [self.textDrawer drawAttributedText:attributedText
                                                 context:context
                                             contentSize:contentSize
                                               wordSpace:attributedLabel.wordSpace
                                        maxNumberOfLines:numberOfLines
                                           textAlignment:attributedLabel.textAlignment
                                          truncationText:attributedText.truncationInfo
                                       saveHighlightText:YES
                                     checkAttributedText:checkAttributedText
                                                  cancel:cancel];
    if (drawResult == -1) {
        return;
    }
    
    if (completion) {
        completion();
    }
}
- (void)getTapedTextColor:(UIColor * __strong *)tapedTextColor
     tapedBackgroundColor:(UIColor * __strong *)tapedBackgroundColor
          withContentType:(NSString *)contentType
                  inLabel:(QAAttributedLabel *)attributedLabel {
    if ([contentType isEqualToString:@"link"]) {
        *tapedTextColor = attributedLabel.highlightLinkTapedTextColor;
        if (!*tapedTextColor) {
            *tapedTextColor = attributedLabel.highlightTapedTextColor;
        }
        *tapedBackgroundColor = attributedLabel.highlightTapedBackgroundColor;
    }
    else if ([contentType isEqualToString:@"at"]) {
        *tapedTextColor = attributedLabel.highlightAtTapedTextColor;
        if (!*tapedTextColor) {
            *tapedTextColor = attributedLabel.highlightTapedTextColor;
        }
        *tapedBackgroundColor = attributedLabel.highlightTapedBackgroundColor;
    }
    else if ([contentType isEqualToString:@"topic"]) {
        *tapedTextColor = attributedLabel.highlightTopicTapedTextColor;
        if (!*tapedTextColor) {
            *tapedTextColor = attributedLabel.highlightTapedTextColor;
        }
        *tapedBackgroundColor = attributedLabel.highlightTapedBackgroundColor;
    }
}
- (void)setHighlightAttributeInfoForAttributedText:(NSMutableAttributedString *)attributedText
                                   highlightRanges:(NSDictionary *)highlightRanges {
    QAAttributedLabel *attributedLabel = (QAAttributedLabel *)self.delegate;
    
    UIColor *highlightTextColor = attributedLabel.highlightTextColor;
    if (!highlightTextColor) {
        highlightTextColor = HighlightTextColor_DEFAULT;
    }
    UIColor *highlightTextBackgroundColor = attributedLabel.highlightTextBackgroundColor;
    if (!highlightTextBackgroundColor) {
        highlightTextBackgroundColor = HighlightTextBackgroundColor_DEFAULT;
    }
    UIFont *highlightFont = attributedLabel.highlightFont;
    if (!highlightFont) {
        highlightFont = attributedLabel.font;
    }
    
    @autoreleasepool {
        NSMutableArray *highLightTextRanges = [highlightRanges valueForKey:@"highLightText"];
        NSMutableArray *linkRanges = [highlightRanges valueForKey:@"link"];
        NSMutableArray *atRanges = [highlightRanges valueForKey:@"at"];
        NSMutableArray *topicRanges = [highlightRanges valueForKey:@"topic"];
        if (highLightTextRanges && highLightTextRanges.count > 0) {
            UIColor *color = [highlightRanges valueForKey:@"highLightTextColor"];
            if (color) {
                highlightTextColor = color;
            }
            for (int i = 0; i < highLightTextRanges.count; i++) {
                NSString *rangeString = [highLightTextRanges objectAtIndex:i];
                NSRange highlightRange = NSRangeFromString(rangeString);
                
                [attributedText updateAttributeStringWithHighlightColor:highlightTextColor
                                                        backgroundColor:highlightTextBackgroundColor
                                                          highlightFont:highlightFont
                                                         highlightRange:highlightRange];
            }
        }
        if (linkRanges && linkRanges.count > 0) {
            UIColor *color = attributedLabel.highlightLinkTextColor;
            if (color) {
                highlightTextColor = color;
            }
            for (int i = 0; i < linkRanges.count; i++) {
                NSString *rangeString = [linkRanges objectAtIndex:i];
                NSRange highlightRange = NSRangeFromString(rangeString);
                
                [attributedText updateAttributeStringWithHighlightColor:highlightTextColor
                                                        backgroundColor:highlightTextBackgroundColor
                                                          highlightFont:highlightFont
                                                         highlightRange:highlightRange];
            }
        }
        if (atRanges && atRanges.count > 0) {
            UIColor *color = attributedLabel.highlightAtTextColor;
            if (color) {
                highlightTextColor = color;
            }
            for (int i = 0; i < atRanges.count; i++) {
                NSString *rangeString = [atRanges objectAtIndex:i];
                NSRange highlightRange = NSRangeFromString(rangeString);
                
                [attributedText updateAttributeStringWithHighlightColor:highlightTextColor
                                                        backgroundColor:highlightTextBackgroundColor
                                                          highlightFont:highlightFont
                                                         highlightRange:highlightRange];
            }
        }
        if (topicRanges && topicRanges.count > 0) {
            UIColor *color = attributedLabel.highlightTopicTextColor;
            if (color) {
                highlightTextColor = color;
            }
            for (int i = 0; i < topicRanges.count; i++) {
                NSString *rangeString = [topicRanges objectAtIndex:i];
                NSRange highlightRange = NSRangeFromString(rangeString);
                
                [attributedText updateAttributeStringWithHighlightColor:highlightTextColor
                                                        backgroundColor:highlightTextBackgroundColor
                                                          highlightFont:highlightFont
                                                         highlightRange:highlightRange];
            }
        }
    }
}
- (int)saveHighlightRanges:(NSMutableDictionary *)highlightRanges
         highlightContents:(NSMutableDictionary *)highlightContents
            truncationInfo:(NSDictionary *)truncationInfo
           attributedLabel:(QAAttributedLabel *)attributedLabel
          attributedString:(NSMutableAttributedString *)attributedText
       checkAttributedText:(BOOL(^)(NSString *content))checkAttributedText
                    cancel:(void(^)(void))cancel {
    UIColor *highlightTextColor = attributedLabel.highlightTextColor;
    if (!highlightTextColor) {
        highlightTextColor = HighlightTextColor_DEFAULT;
    }
    UIColor *highlightTextBackgroundColor = attributedLabel.highlightTextBackgroundColor;
    if (!highlightTextBackgroundColor) {
        highlightTextBackgroundColor = HighlightTextBackgroundColor_DEFAULT;
    }
    UIFont *highlightFont = attributedLabel.highlightFont;
    if (!highlightFont) {
        highlightFont = attributedLabel.font;
    }
    
    // 异常处理:
    if (checkAttributedText && checkAttributedText(attributedText.string)) {
        if (cancel) {
            cancel();
        }
        return - 1;
    }
    
    @autoreleasepool {
        NSMutableArray *ranges = nil;
        NSMutableArray *contents = nil;
        
        NSMutableArray *linkRanges = [highlightRanges valueForKey:@"link"];
        NSMutableArray *linkContents = [highlightContents valueForKey:@"link"];
        if (linkRanges && [linkRanges isKindOfClass:[NSArray class]] && linkRanges.count > 0) {
            UIColor *color = attributedLabel.highlightLinkTextColor;
            if (color) {
                highlightTextColor = color;
            }
            ranges = linkRanges;
            contents = linkContents;
            [self saveHighlightTextWithType:@"link"
                                     ranges:ranges
                                   contents:contents
                         highlightTextColor:highlightTextColor
               highlightTextBackgroundColor:highlightTextBackgroundColor
                              highlightFont:highlightFont
                           attributedString:attributedText];
        }
        
        NSMutableArray *atRanges = [highlightRanges valueForKey:@"at"];
        NSMutableArray *atContents = [highlightContents valueForKey:@"at"];
        if (atRanges && [atRanges isKindOfClass:[NSArray class]] && atRanges.count > 0) {
            UIColor *color = attributedLabel.highlightAtTextColor;
            if (color) {
                highlightTextColor = color;
            }
            ranges = atRanges;
            contents = atContents;
            [self saveHighlightTextWithType:@"at"
                                     ranges:ranges
                                   contents:contents
                         highlightTextColor:highlightTextColor
               highlightTextBackgroundColor:highlightTextBackgroundColor
                              highlightFont:highlightFont
                           attributedString:attributedText];
        }
        
        NSMutableArray *topicRanges = [highlightRanges valueForKey:@"topic"];
        NSMutableArray *topicContents = [highlightContents valueForKey:@"topic"];
        if (topicRanges && [topicRanges isKindOfClass:[NSArray class]] && topicRanges.count > 0) {
            UIColor *color = attributedLabel.highlightAtTextColor;
            if (color) {
                highlightTextColor = color;
            }
            ranges = topicRanges;
            contents = topicContents;
            [self saveHighlightTextWithType:@"topic"
                                     ranges:ranges
                                   contents:contents
                         highlightTextColor:highlightTextColor
               highlightTextBackgroundColor:highlightTextBackgroundColor
                              highlightFont:highlightFont
                           attributedString:attributedText];
        }
        
        if (attributedText.showMoreTextEffected && truncationInfo && truncationInfo.count > 0) {
            UIFont *truncationFont = attributedLabel.font;
            UIColor *highlightTextColor = attributedLabel.moreTapedTextColor;
            UIColor *highlightTextBackgroundColor = attributedLabel.moreTapedBackgroundColor;
            truncationFont = [truncationInfo valueForKey:@"truncationFont"];
            NSString *truncationRangeString = [truncationInfo valueForKey:@"truncationRange"];
            NSString *truncationText = [truncationInfo valueForKey:@"truncationText"];
            
            if (truncationRangeString && truncationText) {
                ranges = [NSMutableArray arrayWithObject:truncationRangeString];
                contents = [NSMutableArray arrayWithObject:truncationText];
                [self saveHighlightTextWithType:@"seeMore"
                                         ranges:ranges
                                       contents:contents
                             highlightTextColor:highlightTextColor
                   highlightTextBackgroundColor:highlightTextBackgroundColor
                                  highlightFont:highlightFont
                               attributedString:attributedText];
            }
        }
    }
    
    return 0;
}
- (void)saveHighlightTextWithType:(NSString *)type
                           ranges:(NSMutableArray *)ranges
                         contents:(NSMutableArray *)contents
               highlightTextColor:(UIColor *)highlightTextColor
     highlightTextBackgroundColor:(UIColor *)highlightTextBackgroundColor
                    highlightFont:(UIFont *)highlightFont
                 attributedString:(NSMutableAttributedString *)attributedText {
    QAAttributedLabel *attributedLabel = (QAAttributedLabel *)self.delegate;
    
    for (int i = 0; i < ranges.count; i++) {
        NSString *rangeString = [ranges objectAtIndex:i];
        NSRange highlightRange = NSRangeFromString(rangeString);
        NSString *highlightContent = [contents objectAtIndex:i];
        
        [attributedText.textTypeDic setValue:type forKey:NSStringFromRange(highlightRange)];
        [attributedText.textDic setValue:highlightContent forKey:NSStringFromRange(highlightRange)];
        if ([type isEqualToString:@"link"]) {
            if (attributedLabel.showShortLink) {
                NSString *shortLink = attributedLabel.shortLink;
                shortLink = shortLink ? : ShortLink_Default;
                [attributedText.textChangedDic setValue:shortLink forKey:NSStringFromRange(highlightRange)];
            }
            else {
                [attributedText.textChangedDic removeAllObjects];
            }
        }
    }
}

/**
 处理"...查看全文"
 */
- (void)processSeemoreText:(NSMutableAttributedString * _Nonnull)attributedText
                      size:(CGSize)size
                completion:(void(^)(BOOL showMoreTextEffected, NSMutableAttributedString * _Nonnull attributedString))completion {
    QAAttributedLabel *attributedLabel = (QAAttributedLabel *)self.delegate;
    self.renderText = nil;
    
    // 基于attributedText创建CTFrame:
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedText);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, (CGRect) {0, 0, size});
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributedText length]), path, NULL);
    
    // 从CTFrame中获取所有的CTLine:
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    NSInteger numberOfLines = CFArrayGetCount(lines);  // 展示文案时总共所需要的行数

    BOOL showMoreTextEffected = NO;
    NSInteger maximumNumberOfLines = attributedLabel.numberOfLines;  // 展示文案时最多展示的行数 (用户设定的numberoflines)
    if (numberOfLines > maximumNumberOfLines) {
        if (attributedLabel.showMoreText == YES) {
            showMoreTextEffected = YES;
            NSString *truncationText = attributedLabel.seeMoreText ? : SeeMoreText_DEFAULT;
            attributedLabel.seeMoreText = truncationText;
            if (!self.renderText) {
                NSDictionary *attributes = [attributedLabel.textLayout getTruncationTextAttributes];  // SeemoreText的相关属性
                NSMutableAttributedString *muTruncationText = [[NSMutableAttributedString alloc] initWithString:truncationText attributes:attributes];
                
                self.renderText = [attributedText joinWithTruncationText:muTruncationText
                                                                textRect:(CGRect) {0, 0, size}
                                                     maximumNumberOfRows:maximumNumberOfLines
                                                                 ctFrame:ctFrame];
            }
            
            // 保存attributedLabel的truncationInfo:
            {
                self.truncationInfo = nil;
                if (attributedLabel.showMoreText) {
                    NSMutableDictionary *truncationInfo = [NSMutableDictionary dictionary];
                    if (attributedLabel.moreTextFont) {
                        [truncationInfo setValue:attributedLabel.moreTextFont forKey:@"truncationFont"];
                    }
                    else {
                        [truncationInfo setValue:attributedLabel.font forKey:@"truncationFont"];
                    }
                    NSInteger location = self.renderText.string.length - attributedLabel.seeMoreText.length;
                    [truncationInfo setValue:NSStringFromRange(NSMakeRange(location, attributedLabel.seeMoreText.length)) forKey:@"truncationRange"];
                    [truncationInfo setValue:truncationText forKey:@"truncationText"];
                    self.truncationInfo = truncationInfo;
                }
            }
        }
        else { // 末尾处理成"..."
            self.renderText = [attributedText joinWithTruncationText:nil
                                                            textRect:(CGRect) {0, 0, size}
                                                 maximumNumberOfRows:maximumNumberOfLines
                                                             ctFrame:ctFrame];
        }
    }
    
    CFRelease(path);
    CFRelease(ctFrame);
    CFRelease(framesetter);
    
    if (!self.renderText) {
        self.renderText = attributedText;
    }
    [self.renderText setShowMoreTextEffected:showMoreTextEffected];
    
    if (completion) {
        completion(showMoreTextEffected, self.renderText);
    }
}
- (void)processEmojiRangeWithRanges:(NSMutableArray *)ranges
                        emojiText:(NSString *)emojiText
                           result:(NSTextCheckingResult *)result {
    for (int i = 0; i < ranges.count; i++) {
        NSString *rangestring = [ranges objectAtIndex:i];
        NSRange highlightRange = NSRangeFromString(rangestring);
        NSInteger dif = highlightRange.location - result.range.location;
        if (dif > 0) {
            NSRange tmp;
            tmp.location = highlightRange.location - (emojiText.length-1);
            tmp.length = highlightRange.length;
            
            [ranges removeObjectAtIndex:i];
            [ranges insertObject:NSStringFromRange(tmp) atIndex:i];
        }
    }
}
- (void)processSeemoreRangeWithRanges:(NSMutableArray *)ranges
                             contents:(NSMutableArray *)contents
                      truncationRange:(NSRange)truncationRange {
    @autoreleasepool {
        NSRange range;
        NSMutableArray * __autoreleasing tmp_ranges = [[NSMutableArray alloc] initWithArray:ranges copyItems:YES];
        for (int i = 0; i < tmp_ranges.count; i++) {
            NSString *rangeString = [tmp_ranges objectAtIndex:i];
            range = NSRangeFromString(rangeString);
            
            // 处理range重叠的情况:
            if (range.location + range.length > truncationRange.location &&
                range.location < truncationRange.location) {
                range.length = truncationRange.location - range.location;
                if (range.length > 0) {
                    NSString *rangeString = NSStringFromRange(range);
                    [ranges replaceObjectAtIndex:i withObject:rangeString];
                }
            }
            
            // 处理已被截取掉的字符串中包含有高亮字体的情况:
            if (range.location >= truncationRange.location) {
                NSUInteger index = [ranges indexOfObject:rangeString];
                if (index != NSNotFound) {
                    [ranges removeObjectAtIndex:index];
                    [contents removeObjectAtIndex:index];
                }
            }
        }
        [tmp_ranges removeAllObjects];
    }
}

/**
 修改attributedText文案指定range处的背景色、并交由textDrawer进行绘制
 
 @param attributedText 需要修改的attributedText
 @param range 需要修改的位置
 @param textColor 字体需要修改成的颜色
 @param textBackgroundColor 字体背景需要修改成的颜色
 @param truncation 修改的是否是"...全文"的相关颜色
 */
- (void)drawContentsImage:(NSMutableAttributedString * _Nonnull)attributedText
                   bounds:(CGRect)bounds
                  inRange:(NSRange)range
                textColor:(UIColor * _Nonnull)textColor
      textBackgroundColor:(UIColor * _Nonnull)textBackgroundColor
               truncation:(BOOL)truncation {
    if (!textBackgroundColor && !textColor) {
        return;
    }
    else if (!attributedText || attributedText.string.length == 0) {
        return;
    }
    
    // 获取上下文:
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(bounds.size.width, bounds.size.height), self.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 高亮文案与Seemore重叠的特殊情况:
    if (truncation == NO && attributedText.truncationText) {
        NSInteger totalLength = attributedText.length - attributedText.truncationText.length;  // 有效文案的长度
        NSInteger num = (range.location + range.length) - totalLength;
        if (num > 0) {  // 有可能截取了高亮文案的一部分内容
            range.length = totalLength - range.location;
        }
    }
    _currentTapedRange = range;
    
    // 更新attributedText的相关属性设置:
    [self updateAttributeText:attributedText
                withTextColor:textColor
          textBackgroundColor:textBackgroundColor
                        range:range];
    
    // 文案的绘制:
    QAAttributedLabel *attributedLabel = (QAAttributedLabel *)self.delegate;
    NSInteger numberOfLines = attributedLabel.numberOfLines;
    [self.textDrawer drawAttributedText:attributedText
                                context:context
                            contentSize:bounds.size
                              wordSpace:attributedLabel.wordSpace
                       maxNumberOfLines:numberOfLines
                          textAlignment:attributedLabel.textAlignment
                         truncationText:attributedText.truncationInfo
                      saveHighlightText:NO
                    checkAttributedText:nil
                                 cancel:nil];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.contents = (__bridge id _Nullable)(image.CGImage);
}
- (void)updateAttributeText:(NSMutableAttributedString *)attributedText
              withTextColor:(UIColor *)textColor
        textBackgroundColor:(UIColor *)textBackgroundColor
                      range:(NSRange)range {
    if (!textColor && !textBackgroundColor && !NSEqualRanges(range, NSMakeRange(0, 0))) {  // 清除点击时的高亮颜色时调用
        /**
         由于点击高亮文本时只是修改了字体的颜色或者字体的背景色、所以这里只需获取_currentTapedAttributeInfo中的这两个属性值即可
         */
        [self restoreAttributedInfo:_currentTapedAttributeInfo
                            inRange:range
                  forAttributedText:attributedText];
        
        if (_currentTapedAttributeInfo_other && _currentTapedAttributeInfo_other.count > 0) {
            for (NSDictionary *dic in _currentTapedAttributeInfo_other) {
                NSDictionary *attributeInfo = [dic valueForKey:@"attributeInfo"];
                NSRange range = NSRangeFromString([dic valueForKey:@"range"]);
                
                [self restoreAttributedInfo:attributeInfo
                                    inRange:range
                          forAttributedText:attributedText];
            }
        }
    }
    else {
        if (self.currentCGImage) {
            // 保存当前点击处的attributeInfo:
            NSRange effectiveRange = NSMakeRange(0, 0);
            self->_currentTapedAttributeInfo = [attributedText attributesAtIndex:range.location effectiveRange:&effectiveRange];  //effectiveRange参数是引用参数，该参数反映了在所检索的位置上字符串中具有当前属性的范围
            self->_currentTapedAttributeInfo_other = [NSMutableArray array];
            for (NSString *searchRangeString in attributedText.searchRanges) {
                NSRange searchRange = NSRangeFromString(searchRangeString);
                NSRange intersectionRange = NSIntersectionRange(searchRange, range);
                if (!NSEqualRanges(intersectionRange, NSMakeRange(0, 0))) {
                    effectiveRange = NSMakeRange(0, 0);
                    NSDictionary *attributeInfo = [attributedText attributesAtIndex:intersectionRange.location effectiveRange:&effectiveRange];
                    NSMutableDictionary *info = [NSMutableDictionary dictionary];
                    [info setValue:attributeInfo forKey:@"attributeInfo"];
                    [info setValue:NSStringFromRange(intersectionRange) forKey:@"range"];
                    [self->_currentTapedAttributeInfo_other addObject:info];
                }
            }
        }
        
        if (textColor) {
            [attributedText removeAttribute:(__bridge NSString *)kCTForegroundColorAttributeName
                                      range:range];
            [attributedText addAttribute:(__bridge NSString *)kCTForegroundColorAttributeName
                                   value:(id)textColor.CGColor
                                   range:range];
        }
        
        if (textBackgroundColor) {
            [attributedText removeAttribute:(__bridge NSString *)kCTBackgroundColorAttributeName
                                      range:range];
            [attributedText addAttribute:(__bridge NSString *)kCTBackgroundColorAttributeName
                                   value:(id)textBackgroundColor.CGColor
                                   range:range];
        }
        else {   // (PS: 这里也可以保留之前的背景色、不将背景色设为clearColor)
            [attributedText removeAttribute:(__bridge NSString *)kCTBackgroundColorAttributeName
                                      range:range];
            [attributedText addAttribute:(__bridge NSString *)kCTBackgroundColorAttributeName
                                   value:(id)[UIColor clearColor].CGColor
                                   range:range];
        }
    }
}
- (void)updateAttributeText:(NSMutableAttributedString *)attributedText
         forAttributedLabel:(QAAttributedLabel *)attributedLabel {
    /*
     [attributedLabel performSelector:@selector(updateText:) withObject:attributedText.string];
     [attributedLabel performSelector:@selector(updateAttributedText:) withObject:attributedText];
     */
    SEL updateTextSelector = NSSelectorFromString(@"updateText:");
    IMP updateTextSelectorImp = [attributedLabel methodForSelector:updateTextSelector];
    void (*updateText)(id, SEL, NSString *) = (void *)updateTextSelectorImp;
    updateText(attributedLabel, updateTextSelector, attributedText.string);
    
    SEL updateAttributedTextSelector = NSSelectorFromString(@"updateAttributedText:");
    IMP updateAttributedTextImp = [attributedLabel methodForSelector:updateAttributedTextSelector];
    void (*updateAttributedText)(id, SEL, NSMutableAttributedString *) = (void *)updateAttributedTextImp;
    updateAttributedText(attributedLabel, updateAttributedTextSelector, attributedText);
}
- (void)restoreAttributedInfo:(NSDictionary *)attributeInfo
                      inRange:(NSRange)range
            forAttributedText:(NSMutableAttributedString *)attributedText {
    id CTForegroundColor = [attributeInfo valueForKey:@"CTForegroundColor"];
    id CTBackgroundColor = [attributeInfo valueForKey:@"CTBackgroundColor"];
    if (CTForegroundColor) {
        [attributedText removeAttribute:(__bridge NSString *)kCTForegroundColorAttributeName
                                  range:range];
        [attributedText addAttribute:(__bridge NSString *)kCTForegroundColorAttributeName
                               value:CTForegroundColor
                               range:range];
    }
    if (CTBackgroundColor) {
        [attributedText removeAttribute:(__bridge NSString *)kCTBackgroundColorAttributeName
                                  range:range];
        [attributedText addAttribute:(__bridge NSString *)kCTBackgroundColorAttributeName
                               value:CTBackgroundColor
                               range:range];
    }
}
- (BOOL)checkWithContent:(NSString *)content {
    if (content == nil) {
        return YES;
    }
    
    if (self.attributedText_backup && ![self.attributedText_backup.string isEqualToString:content]) {
        return YES;
    }
    
    return NO;
}


#pragma mark - Property -
- (QATextDrawer *)textDrawer {
    if (!_textDrawer) {
        _textDrawer = [QATextDrawer new];
    }
    return _textDrawer;
}

@end
