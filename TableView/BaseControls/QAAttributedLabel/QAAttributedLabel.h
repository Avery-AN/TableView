//
//  QAAttributedLabel.h
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QAAttributedLayer, QATextLayout;

typedef void (^GetTextContentSizeBlock)(CGSize size, NSMutableAttributedString * _Nullable attributedString);

typedef NS_ENUM(NSUInteger, QAAttributedLabel_TapedStyle) {
    QAAttributedLabel_Taped_Label = 1,      // 点击了label自身
    QAAttributedLabel_Taped_More,           // 点中了查看全文
    QAAttributedLabel_Taped_Link_at_topic   // 点中了link链接或者@user或者topic话题
};

@interface QAAttributedLabel : UIView

/**
 null_resettable: get方法不能返回为空; set方法可以为空
 null_unspecified: 不确定是否为空
 */

@property (nonatomic, assign) BOOL linkHighlight;               // 网页链接是否需要高亮显示
@property (nonatomic, assign) BOOL showShortLink;               // 是否展示短链接 ("www.baidu.com" -> "网页链接")
@property (nonatomic, assign) BOOL atHighlight;                 // @的文本是否需要高亮显示
@property (nonatomic, assign) BOOL topicHighlight;              // #...#文本(话题)是否需要高亮显示
@property (nonatomic, assign) BOOL showMoreText;                // 当文本过多时、是否显示seeMoreText的内容
@property (nonatomic, assign) BOOL display_async;               // 是否异步绘制 (默认为NO)
// @property (nonatomic, assign, readonly) BOOL cacheContentsImage;          // 是否使用缓存 (默认为NO(配合tableView使用)、打开后会提示性能、但会增加一定的内存的占有率)
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) UIFont *font;
@property (nonatomic, copy, null_resettable) UIColor *textColor;
@property (nonatomic, assign, readonly) NSInteger length;           // 显示的文本长度
@property (nonatomic, assign) NSTextAlignment textAlignment;        // 文本的对齐方式
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;        // 换行模式
@property (nonatomic, assign) NSUInteger numberOfLines;             // 需要显示文本的行数
@property (nonatomic, assign) CGFloat paragraphSpace;               // 段间距
@property (nonatomic, assign) CGFloat lineSpace;                    // 行间距
@property (nonatomic, assign) NSUInteger wordSpace;                 // 字间距
@property (nonatomic, copy, nullable) NSString *shortLink;          // 展示短链接时显示的文案 (PS:"网页链接"、"网址"等)
@property (nonatomic, copy, nullable) NSArray *highLightTexts;                  // text文本中需要高亮显示的部分
@property (nonatomic, copy, nullable) UIFont *highlightFont;                    // 高亮文案的字体
@property (nonatomic, copy, nullable) UIColor *highlightTextColor;              // 高亮显示时的颜色 (其它几种情况的默认颜色)
@property (nonatomic, copy, nullable) UIColor *highlightLinkTextColor;          // 高亮显示时的颜色 (link)
@property (nonatomic, copy, nullable) UIColor *highlightAtTextColor;            // 高亮显示时的颜色 (at)
@property (nonatomic, copy, nullable) UIColor *highlightTopicTextColor;         // 高亮显示时的颜色 (topic)
@property (nonatomic, copy, nullable) UIColor *highlightTapedTextColor;         // 点击高亮文案时的字体颜色 (其它几种情况的默认颜色)
@property (nonatomic, copy, nullable) UIColor *highlightLinkTapedTextColor;     // 点击高亮文案时的字体颜色 (link)
@property (nonatomic, copy, nullable) UIColor *highlightAtTapedTextColor;       // 点击高亮文案时的字体颜色 (at)
@property (nonatomic, copy, nullable) UIColor *highlightTopicTapedTextColor;    // 点击高亮文案时的字体颜色 (topic)
@property (nonatomic, copy, nullable) UIColor *highlightTextBackgroundColor;    // 高亮文案的背景颜色
@property (nonatomic, copy, nullable) UIColor *highlightTapedBackgroundColor;   // 点击高亮文案时的背景色

/**
 显示seeMoreText的前提条件:
 (1) showMoreText = YES;
 (2) 展示当前显示文案所需的lines大于所设置的numberOfLines;
 */
@property (nonatomic, copy, nullable) NSString *seeMoreText;                // PS:"...查看全文" 或者 "...全文"
@property (nonatomic, copy, nullable) UIFont *moreTextFont;                 // seeMoreText的字体
@property (nonatomic, copy, nullable) UIColor *moreTextColor;               // seeMoreText的字体颜色
@property (nonatomic, copy, nullable) UIColor *moreTextBackgroundColor;     // seeMoreText的背景颜色
@property (nonatomic, copy, nullable) UIColor *moreTapedBackgroundColor;    // 点击seeMoreText时的背景颜色
@property (nonatomic, copy, nullable) UIColor *moreTapedTextColor;          // 点击seeMoreText时的字体颜色

/**
 如果直接传入次参数、那么则会忽略上面的属性设置 (font、textColor、lineSpace、highlightTextColor等)。
 */
@property (nonatomic, copy, nullable) NSMutableAttributedString *attributedText;

@property (nonatomic, strong, nullable) QATextLayout *textLayout;
@property (nonatomic, copy) void (^ _Nullable QAAttributedLabelTapAction)(NSString * _Nullable content, QAAttributedLabel_TapedStyle style);
@property (nonatomic, copy, nullable) GetTextContentSizeBlock getTextContentSizeBlock;

/**
 获取文案所占用的size
 */
- (void)getTextContentSizeWithLayer:(QAAttributedLayer * _Nonnull)layer
                            content:(id _Nonnull)content
                           maxWidth:(CGFloat)width
                    completionBlock:(GetTextContentSizeBlock _Nullable)block;

/**
 设置layer的contents
 @param image layer的contents需要显示的图片
 @param attributedString 与image相对应的富文本字符串
 PS: attributedString的作用主要是为了计算highlightRanges & highlightFonts & highlightFrameDic等、以备点击高亮字体时使用
 */
- (void)setContentsImage:(UIImage * _Nonnull)image
        attributedString:(NSMutableAttributedString * _Nonnull)attributedString;

/**
 搜索文案
 */
- (void)searchTexts:(NSArray * _Nonnull)texts resetSearchResultInfo:(NSDictionary * _Nullable (^_Nullable)(void))searchResultInfo;

@end
