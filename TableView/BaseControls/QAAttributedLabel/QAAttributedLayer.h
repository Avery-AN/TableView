//
//  QAAttributedLayer.h
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
@class QAAttributedLabel, QATextDrawer;

@interface QAAttributedLayer : CALayer

@property (nonatomic, nullable) QATextDrawer *textDrawer;
@property (nonatomic, nullable) __block id currentCGImage;
@property (nonatomic, copy, nullable) NSDictionary *truncationInfo;

/**
 获取文案所占用的size
 */
- (NSMutableAttributedString * _Nullable)getAttributedStringWithString:(NSString * _Nonnull)content
                                                              maxWidth:(CGFloat)width;

/**
 针对range处的text进行高亮绘制
 */
- (void)drawHighlightColor:(NSRange)range;

/**
 针对ranges处的text批量进行高亮绘制 (SearchText使用)
 */
- (void)drawHighlightColorWithSearchRanges:(NSArray * _Nonnull)ranges
                             attributeInfo:(NSDictionary * _Nonnull)info;

/**
 清除range处的text的高亮状态
 */
- (void)clearHighlightColor:(NSRange)range;

/**
 label中调用"setContentsImage:attributedString:"的时候使用
 */
- (void)drawTextBackgroundWithAttributedString:(NSMutableAttributedString * _Nonnull)attributedString;

@end
