//
//  QAAttributedLabel.h
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QAAttributedLabelConfig.h"
#import "QATextLayout.h"
@class QAAttributedLayer;


@protocol QAAttributedLabelProperty <NSObject>
- (NSDictionary * _Nullable)getInstanceProperty:(QAAttributedLabel *_Nonnull)instance;
@end


typedef void (^GetTextContentSizeBlock)(CGSize size, NSMutableAttributedString * _Nullable attributedString);

typedef NS_ENUM(NSUInteger, QAAttributedLabel_TapedStyle) {
    QAAttributedLabel_Taped_Label = 0,      // 点击了label自身
    QAAttributedLabel_Taped_More,           // 点中了"...查看全文"
    QAAttributedLabel_Taped_Link,           // 点中了link链接
    QAAttributedLabel_Taped_At,             // 点中了@user
    QAAttributedLabel_Taped_Topic           // 点中了"#topic#"话题
};

@interface QAAttributedLabel : UIView

/**
 null_resettable: get方法不能返回为空; set方法可以为空
 null_unspecified: 不确定是否为空
 */

@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSMutableAttributedString *attributedString;  // 若text也同时存在则优先显示attributedString
/**
 关于attributedString使用strong的解释: @property (nonatomic, strong, nullable) NSMutableAttributedString *attributedString;
 当在tableView中使用时、给cell中的attributedLabel赋的值attributedString是赋值之前已经处理过的、包含有highlightRanges、highlightContents等信息; 所以如果使用copy、在赋值时这些数据就会丢失。
 
 当然也可以这样使用:
 @property (nonatomic, copy, nullable) NSMutableAttributedString *attributedString;
 - (void)setAttributedString:(NSMutableAttributedString *)attributedString {
    _attributedString = [attributedString mutableCopy];
    _attributedString.xxx = attributedString.xxx;  // 手动赋值一下属性、缺点是后续追加属性时难以维护。 (也可以借助runtime)
 }
 */

/**
 保存label被赋的attributedString的初始值 (此处用的strong)
 */
@property (nonatomic, strong, nullable, readonly) NSMutableAttributedString *srcAttributedString;

@property (nonatomic, copy, nullable) UIFont *font;
@property (nonatomic, copy, null_resettable) UIColor *textColor;
@property (nonatomic, copy, nullable) UIColor *qaBackgroundColor;   // 控件的背景色
@property (nonatomic, assign) BOOL noRichTexts;                     // 不处理富文本(默认为NO)
@property (nonatomic, assign, readonly) NSInteger length;           // 显示文案的长度
@property (nonatomic, assign) NSTextAlignment textAlignment;        // 文本的对齐方式
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;        // 换行模式
@property (nonatomic, assign) NSUInteger numberOfLines;             // 需要显示文本的行数
@property (nonatomic, assign) CGFloat paragraphSpace;               // 段间距
@property (nonatomic, assign) CGFloat lineSpace;                    // 行间距
@property (nonatomic, assign) int wordSpace;                        // 字间距
@property (nonatomic, assign) BOOL display_async;           // 是否异步绘制 (默认为NO)
@property (nonatomic, assign) BOOL linkHighlight;           // 网页链接是否需要高亮显示 (默认为NO)
@property (nonatomic, assign) BOOL showShortLink;           // 是否展示短链接 ("https://www.avery.com" -> "网页短链接"; 默认为NO)
@property (nonatomic, assign) BOOL atHighlight;             // "@xxx"是否需要高亮显示 (默认为NO)
@property (nonatomic, assign) BOOL topicHighlight;          // "#话题#"是否需要高亮显示 (默认为NO)
@property (nonatomic, assign) BOOL showMoreText;            // 当文本过多时、是否显示seeMoreText的内容 (默认为NO)
@property (nonatomic, assign, readonly) BOOL isTouching;    // 是否正在被点击 (touchesBegan时为YES、touches事件结束后为NO)
@property (nonatomic, copy, nullable) NSString *shortLink;                      // 展示短链接时显示的文案 (PS:"网页链接"、"网址"等)
@property (nonatomic, copy, nullable) NSArray *highLightTexts;                  // text文本中需要高亮显示的部分
@property (nonatomic, copy, nullable) UIFont *highlightFont;                    // 高亮文案的字体
@property (nonatomic, copy, nullable) UIColor *highlightTextColor;              // 高亮显示时的颜色 (其它几种高亮情况的默认颜色)
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

@property (nonatomic, strong, nullable) QATextLayout *textLayout;
@property (nonatomic, copy) void (^ _Nullable QAAttributedLabelTapAction)(NSString * _Nullable content, QAAttributedLabel_TapedStyle style);
@property (nonatomic, copy, nullable) GetTextContentSizeBlock getTextContentSizeBlock;

/**
 label已渲染完毕后、若再次更改其属性此值为被设为YES、并且后续还会调用layer的updateContent方法
 */
@property (nonatomic, assign) BOOL needUpdate;

//
//- (instancetype _Nonnull)init __attribute__((unavailable("请使用QARichTextLabel OR QATrapezoidalLabel")));
//- (instancetype _Nonnull)initWithFrame:(CGRect)frame __attribute__((unavailable("请使用QARichTextLabel OR QATrapezoidalLabel")));


/**
 获取文案所占用的size  【 【 .m中不要实现此方法 】 】
 */
- (void)getTextContentSizeWithLayer:(id _Nonnull)layer
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

// 点击事件是否击中了高亮文本
- (BOOL)isHitHighlightTextWithPoint:(CGPoint)point
                      highlightRect:(CGRect)highlightRect
                     highlightRange:(NSString * _Nonnull)rangeString;

- (CGSize)getContentSize;
- (CGImageRef _Nullable )getLayerContents;

@end
