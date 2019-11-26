//
//  QATextDrawer.h
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QATextDrawer : NSObject

/**
 CTFrameRef属性
 */
//@property (nonatomic) CTFrameRef ctFrame;

/**
 存储高亮文本所属的类型 (key:range - value:link/at/topic)
 */
@property (nonatomic, strong) NSMutableDictionary *textTypeDic;

/**
 存储高亮文本 (key:range - value:highlightText)
 */
@property (nonatomic, strong) NSMutableDictionary *textDic;

/**
 存储高亮文本(换行) (key:highlightText.md5 - value:存储换行的highlightText数组)
 */
@property (nonatomic, strong) NSMutableDictionary *textNewlineDic;

/**
 存储高亮字体 (key:range - value:font)
 */
@property (nonatomic, strong) NSMutableDictionary *textFontDic;

/**
 存储高亮字体的颜色 (key:range - value:color)
 */
@property (nonatomic, strong) NSMutableDictionary *textForwardColorDic;

/**
 存储高亮字体的背景色 (key:range - value:color)
 */
@property (nonatomic, strong) NSMutableDictionary *textBackgroundColorDic;

/**
 存储高亮字体点击时的背景色 (key:range - value:color)
 */
@property (nonatomic, strong) NSMutableDictionary *textTapedBackgroundColorDic;

/**
 保存高亮文案所处位置对应的frame (key:range - value:CGRect)
 */
@property (nonatomic, strong) NSMutableDictionary *highlightFrameDic;

/**
 根据size的大小在context里绘制文本attributedString
 */
- (void)drawText:(NSMutableAttributedString *)attributedString
         context:(CGContextRef)context
     contentSize:(CGSize)size;

/**
 根据size的大小在context里绘制文本attributedString
 
 @param wordSpace 字间距、处理自定义的Emoji时使用
 @param maxNumberOfLines 展示文案时最多展示的行数 (用户设定的numberoflines)
 @param isSave 是否需要保存attributedString中highllight文案的相关信息、值为YES时表示需要保存
 */
- (int)drawText:(NSMutableAttributedString *)attributedString
        context:(CGContextRef)context
    contentSize:(CGSize)size
      wordSpace:(CGFloat)wordSpace
maxNumberOfLines:(NSInteger)maxNumberOfLines
  textAlignment:(NSTextAlignment)textAlignment
 truncationText:(NSDictionary *)truncationTextInfo
 isSaveTextInfo:(BOOL)isSave
          check:(BOOL(^)(NSString *content))check
         cancel:(void(^)(void))cancel;

@end
