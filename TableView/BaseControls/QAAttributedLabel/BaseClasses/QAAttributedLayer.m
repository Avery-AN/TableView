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
#import "QATextDraw.h"
#import "QAAttributedLabelConfig.h"

typedef NS_ENUM(NSUInteger, QAAttributedLayer_State) {
    QAAttributedLayer_State_Normal = 0,     // 绘制的默认状态
    QAAttributedLayer_State_Drawing,        // 正在绘制
    QAAttributedLayer_State_Canled,         // 绘制已取消
    QAAttributedLayer_State_Finished,       // 绘制已完成
};

@interface QAAttributedLayer () {
    QAAttributedLayer_State _drawState;
    NSRange _currentTapedRange;  // 当点击高亮文案时保存点击处的range
    __block NSDictionary *_currentTapedAttributeInfo;  // 当点击高亮文案时保存点击处的attributeInfo
    __block NSMutableArray *_currentTapedAttributeInfo_other;  // 当点击高亮文案时保存点击处文案里包含的其它高亮文本的attributeInfo (PS: 高亮文案中包含有搜索到的高亮文案)
    
    CFAbsoluteTime startTime_beginDraw;
}
@end


@implementation QAAttributedLayer

#pragma mark - Life Cycle -
- (void)dealloc {
    // NSLog(@"%s",__func__);
}
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}


#pragma mark - Public Apis -
- (NSMutableAttributedString * _Nullable)getAttributedStringWithString:(NSString * _Nonnull)content
                                                              maxWidth:(CGFloat)maxWidth {
    NSString *showContent = [content copy];
    QAAttributedLabel *attributedLabel = GetAttributedLabel(self);
    
    if (attributedLabel.noRichTexts == YES) {  // 不包含富文本
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:showContent attributes:attributedLabel.textLayout.textAttributes];
        return attributedText;
    }

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
    /* 转换UTF8
     [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  // iOS 9以前
     [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];  // iOS 9以后
     */
    NSDictionary *textAttributes = [attributedLabel.textLayout getTextAttributesWithCheckBlock:^BOOL{
        return [self isCancelByCheckingContent:showContent];
    }];
    if (!textAttributes || textAttributes.count == 0) {
        return nil;
    }
    __block NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:showContent attributes:attributedLabel.textLayout.textAttributes];

    // 处理自定义的Emoji:
    [QAEmojiTextManager processDiyEmojiText:attributedText
                                       font:attributedLabel.font
                                  wordSpace:attributedLabel.wordSpace
                             textAttributes:attributedLabel.textLayout.textAttributes
                                 completion:^(BOOL success, NSArray * _Nullable emojiTexts, NSArray * _Nullable matches) {
                                     if (success && emojiTexts.count > 0 && highlightRanges.count > 0) {
                                         for (NSUInteger i = 0; i < emojiTexts.count; i++) {
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
    
    // 处理SeeMoreText & 生成renderText (更新了attributedText中SeeMoreText的文本属性)
    // (此处需要放在处理完font、link、自定义emoji等操作之后处理):
    if (attributedLabel.numberOfLines == 0) {  // numberOfLines值为0时表示需要显示所有文本
        self.renderText = attributedText;
        self.truncationInfo = nil;
    }
    else {
        CGSize size = CGSizeMake(maxWidth, CGFLOAT_MAX);
        int result =
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
        if (result < 0) {
            return nil;
        }
    }

    /**
     保存高亮相关信息(link & at & topic & Seemore)到attributedText中 (从内存的角度上来说不太友好):
     */
    attributedText.highlightRanges = highlightRanges;
    attributedText.highlightContents = highlightContents;
    attributedText.truncationInfo = self.truncationInfo;
    if (attributedText.highlightTextTypeDic == nil) {
        attributedText.highlightTextTypeDic = [NSMutableDictionary dictionary];
    }
    if (attributedText.highlightTextChangedDic == nil) {
        attributedText.highlightTextChangedDic = [NSMutableDictionary dictionary];
    }
    
    if (attributedText.highlightTextDic == nil) {
        attributedText.highlightTextDic = [NSMutableDictionary dictionary];
    }
    if (attributedLabel.showShortLink) {  // 显示短连接的情况需要保存原始链接到highlightTextDic中
        NSArray *linkRanges = [highlightRanges valueForKey:@"link"];
        NSArray *links = [highlightContents valueForKey:@"srcLink"];
        for (NSUInteger i = 0; i < linkRanges.count; i++) {
            NSString *rangeString = [linkRanges objectAtIndex:i];
            [attributedText.highlightTextDic setValue:[links objectAtIndex:i] forKey:rangeString];
        }
    }

    // 在赋值text的情况下更新attributedLabel的 attributedString 的属性值:
    if (attributedLabel.srcAttributedString == nil) {
        [self updateAttributeText:attributedText forAttributedLabel:attributedLabel];
    }

    return attributedText;
}

- (void)clearAllBackup {
    self->_attributedText_backup = nil;
    self->_text_backup = nil;
}
- (void)clearBackupContent {
    self->_text_backup = nil;
}
- (void)clearAttributedBackupContent {
    self->_attributedText_backup = nil;
}
- (void)saveTextBackup:(NSString *)text {
    self->_text_backup = text;
}
- (void)saveAttributedTextBackup:(NSMutableAttributedString *)attributedString {
    self->_attributedText_backup = attributedString;
}
- (void)drawHighlightColor:(NSRange)range
            highlightRects:(NSArray *)highlightRects {
    self.currentCGImage = self.contents;   // 保存当前的self.contents以供clearHighlightColor方法中使用
    
    QAAttributedLabel *attributedLabel = GetAttributedLabel(self);
    NSMutableAttributedString *attributedText = attributedLabel.attributedString;
    CGRect bounds = attributedLabel.bounds;
    NSString *truncationText = attributedLabel.seeMoreText ? : QASeeMoreText_DEFAULT;
    
    if ((attributedLabel.text && [attributedLabel.text isKindOfClass:[NSString class]] && attributedLabel.text.length > 0) ||
        (attributedText && [attributedText isKindOfClass:[NSAttributedString class]] && attributedText.length > 0)) {
        if (attributedText.showMoreTextEffected &&
            attributedLabel.showMoreText && attributedLabel.numberOfLines != 0 && attributedText.showMoreTextEffected &&
            (range.location == attributedText.length - truncationText.length)) {  // 处理SeeMore的高亮
            [self drawTapedContents:attributedText
                             bounds:bounds
                            inRange:range
                          textColor:attributedLabel.moreTapedTextColor
                textBackgroundColor:attributedLabel.moreTapedBackgroundColor
                         truncation:YES
                     highlightRects:highlightRects];
        }
        else {  // 处理 Link & At & Topic 的高亮
            NSString *contentType = [attributedText.highlightTextTypeDic valueForKey:NSStringFromRange(range)];
            UIColor *tapedTextColor = nil;
            UIColor *tapedBackgroundColor = nil;
            [self getTapedTextColor:&tapedTextColor
               tapedBackgroundColor:&tapedBackgroundColor
                    withContentType:contentType
                            inLabel:attributedLabel];
            
            [self drawTapedContents:attributedText
                             bounds:bounds
                            inRange:range
                          textColor:tapedTextColor
                textBackgroundColor:tapedBackgroundColor
                         truncation:NO
                     highlightRects:highlightRects];
        }
    }
}

/**
 针对ranges处的text批量进行高亮绘制 (SearchText时使用)
 */
- (void)drawHighlightColorWithSearchRanges:(NSArray * _Nonnull)ranges
                             attributeInfo:(NSDictionary * _Nonnull)info
                        inAttributedString:(NSMutableAttributedString * _Nonnull)attributedText {
    QAAttributedLabel *attributedLabel = GetAttributedLabel(self);
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
    
    // 更新搜索数据到数据源中:
    SEL appendSearchResultSelector = NSSelectorFromString(@"appendSearchResult:");
    IMP appendSearchResultImp = [attributedLabel methodForSelector:appendSearchResultSelector];
    void (*appendSearchResult)(id, SEL, NSMutableAttributedString *) = (void *)appendSearchResultImp;
    appendSearchResult(attributedLabel, appendSearchResultSelector, attributedText);
    
    
    // 获取上下文:
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(bounds.size.width, bounds.size.height), self.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 文案的绘制:
    NSInteger numberOfLines = attributedLabel.numberOfLines;
    BOOL justified = NO;
    if (attributedText.showMoreTextEffected && attributedLabel.textAlignment == NSTextAlignmentJustified) {
        justified = YES;
    }
    
    [self drawAttributedText:attributedText
                     context:context
                 contentSize:bounds.size
                   wordSpace:attributedLabel.wordSpace
            maxNumberOfLines:numberOfLines
               textAlignment:attributedLabel.textAlignment
           saveHighlightText:NO
                   justified:justified];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    self.currentCGImage = (__bridge id _Nullable)(image.CGImage);
    UIGraphicsEndImageContext();
    
    if ([[NSThread currentThread] isMainThread]) {
        self.contents = self.currentCGImage;
    }
    else {
        self.contents = self.currentCGImage;
        [CATransaction commit];
    }
}

- (void)clearHighlightColor:(NSRange)range {
    if (self.currentCGImage) {
        self.contents = self.currentCGImage;  // contents恢复点击之前的状态
        
        // 在后台去恢复点击之前的数据:
        dispatch_async(QAAttributedLayerDrawQueue(), ^{
            // 清除当点击高亮文案时所做的文案高亮属性的修改 (将点击时添加的高亮颜色去掉、并恢复到点击之前的颜色状态):
            QAAttributedLabel *attributedLabel = GetAttributedLabel(self);
            NSMutableAttributedString *attributedText = attributedLabel.attributedString;
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
    QAAttributedLabel *attributedLabel = GetAttributedLabel(self);
    CGRect bounds = attributedLabel.bounds;
    
    dispatch_async(QAAttributedLayerDrawQueue(), ^{
        CGFloat boundsWidth = bounds.size.width;
        CGFloat boundsHeight = bounds.size.height;
        
        // 保存高亮相关信息(link & at & topic & Seemore)到layer的textDraw中:
        [self saveHighlightRanges:attributedString.highlightRanges
                highlightContents:attributedString.highlightContents
                   truncationInfo:attributedString.truncationInfo
                  attributedLabel:attributedLabel
                 attributedString:attributedString];
        
        // 获取上下文:
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(bounds.size.width, bounds.size.height), self.opaque, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // 文案的绘制:
        CGSize contentSize = CGSizeMake(ceil(boundsWidth), ceil(boundsHeight));
        NSInteger numberOfLines = attributedLabel.numberOfLines;
        BOOL justified = NO;
        if (attributedString.showMoreTextEffected && attributedLabel.textAlignment == NSTextAlignmentJustified) {
            justified = YES;
        }
        BOOL saveHighlightText = YES;
        if (attributedLabel.noRichTexts) {
            saveHighlightText = NO;
        }
        
        [self drawAttributedText:attributedString
                         context:context
                     contentSize:contentSize
                       wordSpace:attributedLabel.wordSpace
                maxNumberOfLines:numberOfLines
                   textAlignment:attributedLabel.textAlignment
               saveHighlightText:saveHighlightText
                       justified:justified];
    });
}


#pragma mark - Private Methods -
- (void)fillContents:(QAAttributedLabel *)attributedLabel {
    // NSLog(@"   %s",__func__);
    
    BOOL isDrawAvailable = [self isDrawAvailable:attributedLabel];
    if (isDrawAvailable == NO) {
        return;
    }
    
    [self updateContentsFilling_cancel];
    
    if (attributedLabel.display_async) {
        [self fillContents_async:attributedLabel];
    }
    else {
        [self fillContents_sync:attributedLabel];
    }
}
- (void)updateContentsFilling_cancel {
    if (_drawState == QAAttributedLayer_State_Drawing) {  // 如果正在绘制那么则修改其状态
        _drawState = QAAttributedLayer_State_Canled;
    }
}
- (void)fillContents_async:(QAAttributedLabel *)attributedLabel {
    // NSLog(@"   %s",__func__);

    startTime_beginDraw = CFAbsoluteTimeGetCurrent();
    
    _drawState = QAAttributedLayer_State_Drawing;
    
    CGColorRef backgroundCgcolor = [UIColor clearColor].CGColor;
    CGRect bounds = attributedLabel.bounds;
    
    dispatch_async(QAAttributedLayerDrawQueue(), ^{
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
                                    __strong typeof(weakSelf) strongSelf = weakSelf;
            
                                    // 检查绘制是否应该被取消:
                                    return [strongSelf isCancelByCheckingContent:content];
                                } cancel:^{
                                    // NSLog(@"绘制被取消!!!");
                                    UIGraphicsEndImageContext();
                                    
                                    self->_drawState = QAAttributedLayer_State_Normal;
                                } completion:^(id attributedTextObj) {
                                    // NSLog(@"绘制完毕");
                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                    
                                    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                                    image = [image decodeImage];  // image的解码
                                    strongSelf.currentCGImage = (__bridge id _Nullable)(image.CGImage);
                                    UIGraphicsEndImageContext();
                                    
                                    
                                    /**
                                     // 缓存
                                     if (attributedText && image) {
                                         dispatch_async(QAAttributedLayerDrawQueue(), ^{
                                             [strongSelf cacheImage:image withIdentifier:attributedText];
                                         });
                                     }
                                     */
                                    
                                    strongSelf.contents = strongSelf.currentCGImage;
                                    [CATransaction commit];
                                    strongSelf->_drawState = QAAttributedLayer_State_Finished;
                                    // CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
                                    // CFAbsoluteTime loadTime = endTime - self->startTime_beginDraw;
                                    // NSLog(@"DrawTime(coretext): %f",loadTime);
                                    // NSLog(@" ");
                                }];
    });
}

- (void)fillContents_sync:(QAAttributedLabel *)attributedLabel {
    // NSLog(@"   %s",__func__);
    
    _drawState = QAAttributedLayer_State_Drawing;
    
    // 获取上下文:
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.bounds.size.width, self.bounds.size.height), self.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 给上下文填充背景色:
    CGColorRef backgroundCgcolor = [UIColor clearColor].CGColor;
    CGContextSetFillColorWithColor(context, backgroundCgcolor);
    CGContextFillRect(context, attributedLabel.bounds);

    // 绘制文案:
    __weak typeof(self) weakSelf = self;
    [self fillContentsWithContext:context
                            label:attributedLabel
                       selfBounds:self.bounds
              checkAttributedText:^BOOL (NSString *content) {
                                    __strong typeof(weakSelf) strongSelf = weakSelf;
        
                                    // 检查绘制是否应该被取消:
                                    return [strongSelf isCancelByCheckingContent:content];
                                } cancel:^{
                                    // NSLog(@"绘制被取消!!!");
                                    UIGraphicsEndImageContext();
                                } completion:^(NSMutableAttributedString *attributedText) {
                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                    
                                    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                                    UIGraphicsEndImageContext();
                                    image = [image decodeImage];  // image的解码
                                    strongSelf.currentCGImage = (__bridge id _Nullable)(image.CGImage);
                                    strongSelf.contents = strongSelf.currentCGImage;
                                    strongSelf->_drawState = QAAttributedLayer_State_Finished;
                                }];
}
- (void)fillContentsWithContext:(CGContextRef)context
                          label:(QAAttributedLabel *)attributedLabel
                     selfBounds:(CGRect)bounds
            checkAttributedText:(BOOL(^)(NSString *content))checkBlock
                         cancel:(void(^)(void))cancel
                     completion:(void(^)(NSMutableAttributedString *))completion {
    __weak typeof(self) weakSelf = self;
    
    [self getDrawAttributedTextWithLabel:attributedLabel
                              selfBounds:bounds
                     checkAttributedText:checkBlock
                              completion:^(NSMutableAttributedString *attributedText) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        BOOL noRichTexts = attributedLabel.noRichTexts;
        
        if (!attributedText) {
            if (cancel) {
                cancel();
            }
            return;
        }
        else {
            // NSLog(@" 开始绘制 - attributedText");
            CGFloat boundsWidth = bounds.size.width;
            CGFloat boundsHeight = bounds.size.height;
            
            // 处理搜索结果:
            if (noRichTexts == NO && attributedText.searchRanges && attributedText.searchRanges.count > 0) {
                UIColor *textColor = [attributedText.searchAttributeInfo valueForKey:@"textColor"];
                UIColor *textBackgroundColor = [attributedText.searchAttributeInfo valueForKey:@"textBackgroundColor"];
                for (NSString *rangeString in attributedText.searchRanges) {
                    NSRange range = NSRangeFromString(rangeString);
                    int result = [strongSelf updateAttributeText:attributedText
                                                   withTextColor:textColor
                                             textBackgroundColor:textBackgroundColor
                                                           range:range];
                    if (result < 0) {
                        if (cancel) {
                            cancel();
                        }
                        return;
                    }
                }
            }
            
            // 保存高亮相关信息(link & at & Topic & Seemore)到attributedText对应的属性中:
            if (noRichTexts == NO) {
                int saveResult = [strongSelf saveHighlightRanges:attributedText.highlightRanges
                                               highlightContents:attributedText.highlightContents
                                                  truncationInfo:attributedText.truncationInfo
                                                 attributedLabel:attributedLabel
                                                attributedString:attributedText];
                if (saveResult < 0) {
                    if (cancel) {
                        cancel();
                    }
                    return;
                }
            }
            
            // 文案的绘制:
            CGSize contentSize = CGSizeMake(ceil(boundsWidth), ceil(boundsHeight));
            NSInteger numberOfLines = attributedLabel.numberOfLines;
            BOOL justified = NO;
            if (attributedText.showMoreTextEffected && attributedLabel.textAlignment == NSTextAlignmentJustified) {
                justified = YES;
            }
            BOOL saveHighlightText = YES;
            if (noRichTexts == YES) {
                saveHighlightText = NO;
            }
            
            int drawResult = [strongSelf drawAttributedText:attributedText
                                                    context:context
                                                contentSize:contentSize
                                                  wordSpace:attributedLabel.wordSpace
                                           maxNumberOfLines:numberOfLines
                                              textAlignment:attributedLabel.textAlignment
                                          saveHighlightText:saveHighlightText
                                                  justified:justified];
            if (drawResult < 0) {
                if (cancel) {
                    cancel();
                }
                return;
            }

            // 更新搜索数据到数据源中:
            SEL appendDrawResultSelector = NSSelectorFromString(@"appendDrawResult:");
            IMP appendDrawResultImp = [attributedLabel methodForSelector:appendDrawResultSelector];
            void (*appendDrawResult)(id, SEL, NSMutableAttributedString *) = (void *)appendDrawResultImp;
            appendDrawResult(attributedLabel, appendDrawResultSelector, attributedText);
            
            if (completion) {
                completion(attributedText);
            }
        }
    }];
}
- (void)getTapedTextColor:(UIColor * __strong *)tapedTextColor
     tapedBackgroundColor:(UIColor * __strong *)tapedBackgroundColor
          withContentType:(NSString *)contentType
                  inLabel:(QAAttributedLabel * _Nonnull)attributedLabel {
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
    QAAttributedLabel *attributedLabel = GetAttributedLabel(self);
    
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
            for (NSUInteger i = 0; i < highLightTextRanges.count; i++) {
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
            for (NSUInteger i = 0; i < linkRanges.count; i++) {
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
            for (NSUInteger i = 0; i < atRanges.count; i++) {
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
            for (NSUInteger i = 0; i < topicRanges.count; i++) {
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
          attributedString:(NSMutableAttributedString *)attributedText {
//    UIColor *highlightTextColor = attributedLabel.highlightTextColor;
//    if (!highlightTextColor) {
//        highlightTextColor = HighlightTextColor_DEFAULT;
//    }
//    UIColor *highlightTextBackgroundColor = attributedLabel.highlightTextBackgroundColor;
//    if (!highlightTextBackgroundColor) {
//        highlightTextBackgroundColor = HighlightTextBackgroundColor_DEFAULT;
//    }
//    UIFont *highlightFont = attributedLabel.highlightFont;
//    if (!highlightFont) {
//        highlightFont = attributedLabel.font;
//    }
    
    // 异常处理:
    if ([self isCancelByCheckingContent:attributedText.string]) {
        return - 1;
    }
    
    @autoreleasepool {
        NSMutableArray *ranges = nil;
        NSMutableArray *contents = nil;
        
        NSMutableArray *linkRanges = [highlightRanges valueForKey:@"link"];
        NSMutableArray *linkContents = [highlightContents valueForKey:@"link"];
        if (linkRanges && [linkRanges isKindOfClass:[NSArray class]] && linkRanges.count > 0) {
//            UIColor *color = attributedLabel.highlightLinkTextColor;
//            if (color) {
//                highlightTextColor = color;
//            }
            ranges = linkRanges;
            contents = linkContents;
            int result = [self saveHighlightTextWithType:@"link"
                                                  ranges:ranges
                                                contents:contents
                                        attributedString:attributedText];
            if (result < 0) {
                return -1;
            }
        }
        
        NSMutableArray *atRanges = [highlightRanges valueForKey:@"at"];
        NSMutableArray *atContents = [highlightContents valueForKey:@"at"];
        if (atRanges && [atRanges isKindOfClass:[NSArray class]] && atRanges.count > 0) {
//            UIColor *color = attributedLabel.highlightAtTextColor;
//            if (color) {
//                highlightTextColor = color;
//            }
            ranges = atRanges;
            contents = atContents;
            int result = [self saveHighlightTextWithType:@"at"
                                                  ranges:ranges
                                                contents:contents
                                        attributedString:attributedText];
            if (result < 0) {
                return -2;
            }
        }
        
        NSMutableArray *topicRanges = [highlightRanges valueForKey:@"topic"];
        NSMutableArray *topicContents = [highlightContents valueForKey:@"topic"];
        if (topicRanges && [topicRanges isKindOfClass:[NSArray class]] && topicRanges.count > 0) {
//            UIColor *color = attributedLabel.highlightAtTextColor;
//            if (color) {
//                highlightTextColor = color;
//            }
            ranges = topicRanges;
            contents = topicContents;
            int result = [self saveHighlightTextWithType:@"topic"
                                                  ranges:ranges
                                                contents:contents
                                        attributedString:attributedText];
            if (result < 0) {
                return -3;
            }
        }
        
        if (attributedText.showMoreTextEffected && truncationInfo && truncationInfo.count > 0) {
            // UIFont *truncationFont = attributedLabel.font;
            // UIColor *highlightTextColor = attributedLabel.moreTapedTextColor;
            // UIColor *highlightTextBackgroundColor = attributedLabel.moreTapedBackgroundColor;
            // UIFont *truncationFont = [truncationInfo valueForKey:@"truncationFont"];
            NSString *truncationRangeString = [truncationInfo valueForKey:@"truncationRange"];
            NSString *truncationText = [truncationInfo valueForKey:@"truncationText"];
            
            if (truncationRangeString && truncationText) {
                ranges = [NSMutableArray arrayWithObject:truncationRangeString];
                contents = [NSMutableArray arrayWithObject:truncationText];
                int result = [self saveHighlightTextWithType:@"seeMore"
                                                      ranges:ranges
                                                    contents:contents
                                            attributedString:attributedText];
                if (result < 0) {
                    return -4;
                }
            }
        }
    }
    
    return 0;
}
- (int)saveHighlightTextWithType:(NSString *)type
                          ranges:(NSMutableArray *)ranges
                        contents:(NSMutableArray *)contents
                attributedString:(NSMutableAttributedString *)attributedText {
    for (NSUInteger i = 0; i < ranges.count; i++) {
        NSString *rangeString = [ranges objectAtIndex:i];
        NSRange highlightRange = NSRangeFromString(rangeString);
        NSString *highlightContent = [contents objectAtIndex:i];
        
        // 异常处理:
        if ([self isCancelByCheckingContent:attributedText.string]) {
            return - 100;
        }
        
        [attributedText.highlightTextTypeDic setValue:type forKey:NSStringFromRange(highlightRange)];
        if ([type isEqualToString:@"link"]) {
            if (![attributedText.highlightTextDic valueForKey:NSStringFromRange(highlightRange)]) {
                [attributedText.highlightTextDic setValue:highlightContent forKey:NSStringFromRange(highlightRange)];
            }
            else {
                [attributedText.highlightTextChangedDic setValue:highlightContent forKey:NSStringFromRange(highlightRange)];
            }
        }
        else {
            [attributedText.highlightTextDic setValue:highlightContent forKey:NSStringFromRange(highlightRange)];
        }
    }
    
    return 0;
}

/**
 处理"...查看全文"
 */
- (int)processSeemoreText:(NSMutableAttributedString * _Nonnull)attributedText
                     size:(CGSize)size
               completion:(void(^)(BOOL showMoreTextEffected, NSMutableAttributedString * _Nonnull attributedString))completion {
    QAAttributedLabel *attributedLabel = GetAttributedLabel(self);
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
            NSString *truncationText = attributedLabel.seeMoreText ? : QASeeMoreText_DEFAULT;
            if (!self.renderText) {
                 // SeemoreText的相关属性
                NSDictionary *attributes = [attributedLabel.textLayout getTruncationTextAttributesWithCheckBlock:^BOOL{
                    return [self isCancelByCheckingContent:attributedText.string];
                }];
                if (!attributes || attributes.count == 0) {
                    CFRelease(path);
                    CFRelease(ctFrame);
                    CFRelease(framesetter);
                    return -30;
                }
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
                    NSInteger location = self.renderText.string.length - truncationText.length;
                    [truncationInfo setValue:NSStringFromRange(NSMakeRange(location, truncationText.length)) forKey:@"truncationRange"];
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
    
    return 0;
}
- (void)processEmojiRangeWithRanges:(NSMutableArray *)ranges
                        emojiText:(NSString *)emojiText
                           result:(NSTextCheckingResult *)result {
    for (NSUInteger i = 0; i < ranges.count; i++) {
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
        for (NSUInteger i = 0; i < tmp_ranges.count; i++) {
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
 修改attributedText文案指定range处的背景色、并进行绘制
 
 @param attributedText 需要修改的attributedText
 @param range 需要修改的位置
 @param textColor 字体需要修改成的颜色
 @param textBackgroundColor 字体背景需要修改成的颜色
 @param truncation 修改的是否是"...全文"的相关颜色
 */
- (void)drawTapedContents:(NSMutableAttributedString * _Nonnull)attributedText
                   bounds:(CGRect)bounds
                  inRange:(NSRange)range
                textColor:(UIColor * _Nullable)textColor
      textBackgroundColor:(UIColor * _Nullable)textBackgroundColor
               truncation:(BOOL)truncation
           highlightRects:(NSArray * _Nullable)highlightRects {
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
    
    /*
    // 更新attributedText的相关属性设置:
    [self updateAttributeText:attributedText
                withTextColor:textColor
          textBackgroundColor:textBackgroundColor
                        range:range];
     */
    
    // 更新attributedText的相关属性设置:
    [self updateAttributeText:attributedText
                withTextColor:textColor
          textBackgroundColor:nil
                        range:range];
    
    // 绘制富文本 & 高亮文案的点击背景色:
    QAAttributedLabel *attributedLabel = GetAttributedLabel(self);
    NSInteger numberOfLines = attributedLabel.numberOfLines;
    BOOL justified = NO;
    if (attributedText.showMoreTextEffected && attributedLabel.textAlignment == NSTextAlignmentJustified) {
        justified = YES;
    }
    [self drawAttributedTextAndTapedBackgroungcolor:attributedText
                                            context:context
                                        contentSize:bounds.size
                                          wordSpace:attributedLabel.wordSpace
                                   maxNumberOfLines:numberOfLines
                                      textAlignment:attributedLabel.textAlignment
                                  saveHighlightText:NO
                                          justified:justified
                                     highlightRects:highlightRects
                                textBackgroundColor:textBackgroundColor
                                              range:range];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.contents = (__bridge id)(image.CGImage);
}
- (int)updateAttributeText:(NSMutableAttributedString *)attributedText
             withTextColor:(UIColor *)textColor
       textBackgroundColor:(UIColor *)textBackgroundColor
                     range:(NSRange)range {
    if (!textColor && !textBackgroundColor && !NSEqualRanges(range, NSMakeRange(0, 0))) {  // 清除点击时的高亮颜色时调用
        /**
         由于点击高亮文本时只是修改了字体的颜色或者字体的背景色、所以这里只需获取_currentTapedAttributeInfo中的这两个属性值即可
         */
        int result = [self restoreAttributedInfo:_currentTapedAttributeInfo
                                         inRange:range
                               forAttributedText:attributedText];
        if (result < 0) {
            return result;
        }
        
        if (_currentTapedAttributeInfo_other && _currentTapedAttributeInfo_other.count > 0) {
            for (NSDictionary *dic in _currentTapedAttributeInfo_other) {
                NSDictionary *attributeInfo = [dic valueForKey:@"attributeInfo"];
                NSRange range = NSRangeFromString([dic valueForKey:@"range"]);
                
                result = [self restoreAttributedInfo:attributeInfo
                                             inRange:range
                                   forAttributedText:attributedText];
                if (result < 0) {
                    return result;
                }
            }
        }
    }
    else {
        if (self.currentCGImage) {
            // 保存当前点击处的attributeInfo:
            NSRange effectiveRange = NSMakeRange(0, 0);
            self->_currentTapedAttributeInfo = [attributedText attributesAtIndex:range.location effectiveRange:&effectiveRange];  // effectiveRange参数是引用参数，该参数反映了在所检索的位置上字符串中具有当前属性的范围
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

        // 异常处理:
        if ([self isCancelByCheckingContent:attributedText.string]) {
            return -50;
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
    
    return 0;
}
- (void)updateAttributeText:(NSMutableAttributedString *)attributedText
         forAttributedLabel:(QAAttributedLabel *)attributedLabel {
    /*
     [attributedLabel performSelector:@selector(updateText:) withObject:attributedText.string];

     SEL updateTextSelector = NSSelectorFromString(@"updateText:");
     IMP updateTextSelectorImp = [attributedLabel methodForSelector:updateTextSelector];
     void (*updateText)(id, SEL, NSString *) = (void *)updateTextSelectorImp;
     updateText(attributedLabel, updateTextSelector, attributedText.string);
     */

    SEL updateAttributedTextSelector = NSSelectorFromString(@"updateAttributedText:");
    IMP updateAttributedTextImp = [attributedLabel methodForSelector:updateAttributedTextSelector];
    void (*updateAttributedText)(id, SEL, NSMutableAttributedString *) = (void *)updateAttributedTextImp;
    updateAttributedText(attributedLabel, updateAttributedTextSelector, attributedText);
}
- (int)restoreAttributedInfo:(NSDictionary *)attributeInfo
                     inRange:(NSRange)range
           forAttributedText:(NSMutableAttributedString *)attributedText {
    id CTForegroundColor = [attributeInfo valueForKey:@"CTForegroundColor"];
    id CTBackgroundColor = [attributeInfo valueForKey:@"CTBackgroundColor"];

    // 异常处理:
    if ([self isCancelByCheckingContent:attributedText.string]) {
        return -40;
    }
    
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
    
    return 0;
}
- (BOOL)isCancelByCheckingContent:(NSString *)content {  // 返回YES表示需要取消本次绘制
    QAAttributedLabel *attributedLabel = GetAttributedLabel(self);
    if (_drawState == QAAttributedLayer_State_Canled) {
        return YES;
    }
    else if (!content) {
        return YES;
    }
    else if (self.text_backup && [content isEqualToString:self.text_backup]) {
        return NO;
    }
    else if (attributedLabel.srcAttributedString && self.attributedText_backup && ![self.attributedText_backup.string isEqualToString:content]) {
        return YES;
    }
    
    return NO;
}

/**
 处理attributedString中的自定义emoji & 文本末尾的"...全文"
 */
- (NSMutableAttributedString * _Nullable)getAttributedStringWithAttributedString:(NSMutableAttributedString * _Nonnull)attributedString maxWidth:(CGFloat)maxWidth {
    __block NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    QAAttributedLabel *attributedLabel = GetAttributedLabel(self);
    
    // 处理自定义的Emoji:
    [QAEmojiTextManager processDiyEmojiText:attributedText
                                       font:attributedLabel.font
                                  wordSpace:attributedLabel.wordSpace
                             textAttributes:attributedLabel.textLayout.textAttributes
                                 completion:^(BOOL success, NSArray * _Nullable emojiTexts, NSArray * _Nullable matches) {
                                 }];
    
    // 处理SeeMoreText & 生成renderText (更新了attributedText中SeeMoreText的文本属性):
    if (attributedLabel.numberOfLines == 0) {  // numberOfLines值为0时表示需要显示所有文本
        self.renderText = attributedText;
        self.truncationInfo = nil;
    }
    else {
        CGSize size = CGSizeMake(maxWidth, CGFLOAT_MAX);
        [self processSeemoreText:attributedText
                            size:size
                      completion:^(BOOL showMoreTextEffected, NSMutableAttributedString * _Nonnull attributedString) {
                                  if (showMoreTextEffected == YES) {
                                      attributedText = attributedString;
                                  }
                                }];
    }
    attributedText.truncationInfo = self.truncationInfo;
    if (attributedText.highlightTextTypeDic == nil) {
        attributedText.highlightTextTypeDic = [NSMutableDictionary dictionary];
    }
    if (attributedText.highlightTextDic == nil) {
        attributedText.highlightTextDic = [NSMutableDictionary dictionary];
    }
    
    return attributedText;
}

@end
