//
//  QATextDraw.h
//  TableView
//
//  Created by Avery An on 2019/12/23.
//  Copyright © 2019 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QAAttributedLabelConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (QATextDraw)

/**
 存储高亮文本(换行) (key:range - value:数组、存储换行的highlightText信息、数组中元素的个数代表highlightText在绘制过程中所占用的行数)
 */
@property (nonatomic, strong) NSMutableDictionary *textNewlineDic;

/**
 保存高亮文案所处位置对应的frame (key:range - value:CGRect)
 */
@property (nonatomic, strong) NSMutableDictionary *highlightFrameDic;

/**
保存高亮文案的frame对应的line (key:CGRect - value:array(lineIndex))
*/
@property (nonatomic, strong) NSMutableDictionary *highlightLineDic;


/**
 根据size的大小在context里绘制文本attributedString
 */
- (void)drawAttributedTextWithContext:(CGContextRef)context
                          contentSize:(CGSize)size;

/**
 根据size的大小在context里绘制文本attributedString
 
 @param wordSpace 字间距、处理自定义的Emoji时使用
 @param maxNumberOfLines 展示文案时最多展示的行数 (用户设定的numberoflines)
 @param saveHighlightText 是否需要保存attributedString中highllight文案的相关信息、值为YES时表示需要保存 (目前只是保存了需要交互的高亮文本)
 */
- (int)drawAttributedTextWithContext:(CGContextRef)context
                         contentSize:(CGSize)size
                           wordSpace:(CGFloat)wordSpace
                    maxNumberOfLines:(NSInteger)maxNumberOfLines
                       textAlignment:(NSTextAlignment)textAlignment
                   saveHighlightText:(BOOL)saveHighlightText
                           justified:(BOOL)justified;


// 绘制富文本中的附件
- (void)drawAttachmentContentInContext:(CGContextRef)context
                               ctframe:(CTFrameRef)ctFrame
                                  line:(CTLineRef)line
                            lineOrigin:(CGPoint)lineOrigin
                                   run:(CTRunRef)run
                              delegate:(CTRunDelegateRef)delegate
                             wordSpace:(CGFloat)wordSpace;

// 保存attributedString中的富文本信息(富文本的frame、富文本所处的line等信息)
- (int)saveHighlightRangeAndFrameWithLineIndex:(CFIndex)lineIndex
                                    lineOrigin:(CGPoint)lineOrigin
                                  contentWidth:(CGFloat)contentWidth
                                 contentHeight:(CGFloat)contentHeight
                              attributedString:(NSMutableAttributedString *)attributedString
                                       context:(CGContextRef)context
                                          line:(CTLineRef)line
                                           run:(CTRunRef)run;

// 获取attributedString中包含的富文本信息(从头至尾顺序排列)
- (void)getSortedHighlightRanges:(NSMutableAttributedString *)attributedString;

//// 获取当前run的range在整个attributedString中的位置(QARichText中直接返回此值、QATrapezoidal中需要进行转换)
//- (NSRange)getCurrentRunRangeWithLineIndex:(NSInteger)lineIndex runRange:(NSRange)runRange;

@end

NS_ASSUME_NONNULL_END
