//
//  QAAttributedLayer.h
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <stdatomic.h>
@class QAAttributedLabel, QATextDrawer;


static dispatch_queue_t _Nonnull QAAttributedLayerDrawQueue() {
#define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static atomic_int counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t queue_attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queues[i] = dispatch_queue_create("com.avery.QAAttributedLayer.render", queue_attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.avery.QAAttributedLayer.render", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });
    
    // 线程安全的自增计数,每调用一次+1
    atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
    return queues[(counter) % queueCount];
#undef MAX_QUEUE_COUNT
}


@interface QAAttributedLayer : CALayer

@property (nonatomic, nullable) __block id currentCGImage;
@property (nonatomic, copy, nullable) NSDictionary *truncationInfo;
@property (nonatomic, strong, nullable) NSMutableAttributedString *renderText;
@property (nonatomic, copy, nullable, readonly) NSMutableAttributedString *attributedText_backup;
@property (nonatomic, copy, nullable, readonly) NSString *text_backup;

// 获取u与content锁对应的AttributedString
- (NSMutableAttributedString * _Nullable)getAttributedStringWithString:(NSString * _Nonnull)content
                                                              maxWidth:(CGFloat)maxWidth;

// 绘制attributedLabel
- (void)fillContents:(QAAttributedLabel * _Nonnull)attributedLabel;

// 获取绘制attributedLabel时需要绘制的AttributedString
- (void)getDrawAttributedTextWithLabel:(id _Nonnull)label
                            selfBounds:(CGRect)bounds
                   checkAttributedText:(BOOL(^_Nullable)(NSString * _Nullable content))checkBlock
                            completion:(void(^_Nullable)(NSMutableAttributedString *_Nullable))completion;

// 判断是否要取消绘制
- (BOOL)isCancelByCheckingContent:(NSString * _Nonnull)content;

// 更新attributedLabel的 attributedString 的属性值
- (void)updateAttributeText:(NSMutableAttributedString * _Nullable)attributedText
         forAttributedLabel:(QAAttributedLabel * _Nonnull)attributedLabel;

/**
 绘制attributedText
 */
- (int)drawAttributedText:(NSMutableAttributedString * _Nonnull)attributedText
                  context:(CGContextRef _Nonnull)context
              contentSize:(CGSize)contentSize
                wordSpace:(CGFloat)wordSpace
         maxNumberOfLines:(NSInteger)numberOfLines
            textAlignment:(NSTextAlignment)textAlignment
        saveHighlightText:(BOOL)saveHighlightText
                justified:(BOOL)justified;

/**
 绘制attributedText & 高亮文案的点击背景色 (点击高亮文案时使用)
 */
- (void)drawAttributedTextAndTapedBackgroungcolor:(NSMutableAttributedString * _Nonnull)attributedText
                                          context:(CGContextRef _Nonnull)context
                                      contentSize:(CGSize)contentSize
                                        wordSpace:(CGFloat)wordSpace
                                 maxNumberOfLines:(NSInteger)numberOfLines
                                    textAlignment:(NSTextAlignment)textAlignment
                                saveHighlightText:(BOOL)saveHighlightText
                                        justified:(BOOL)justified
                                   highlightRects:(NSArray * _Nonnull)highlightRects
                              textBackgroundColor:(UIColor * _Nullable)textBackgroundColor
                                            range:(NSRange)range;

- (void)clearAllBackup;
- (void)clearBackupContent;
- (void)clearAttributedBackupContent;
- (void)saveTextBackup:(NSString * _Nullable)text;
- (void)saveAttributedTextBackup:(NSMutableAttributedString * _Nullable)attributedString;
- (BOOL)isDrawAvailable:(id _Nonnull)label;   // 绘制是否可用


/**
 针对range处的text进行高亮绘制
 */
- (void)drawHighlightColor:(NSRange)range
            highlightRects:(NSArray * _Nonnull)highlightRects;

/**
 针对ranges处的text批量进行高亮绘制 (SearchText使用)
 */
- (void)drawHighlightColorWithSearchRanges:(NSArray * _Nonnull)ranges
                             attributeInfo:(NSDictionary * _Nonnull)info
                        inAttributedString:(NSMutableAttributedString * _Nonnull)attributedText;

/**
 清除range处的text的高亮状态
 */
- (void)clearHighlightColor:(NSRange)range;

/**
 label中调用"setContentsImage:attributedString:"的时候使用
 */
- (void)drawTextBackgroundWithAttributedString:(NSMutableAttributedString * _Nonnull)attributedString;

@end
