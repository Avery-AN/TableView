//
//  NSMutableAttributedString+QAAttributedString.h
//  CoreText
//
//  Created by 我去 on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface NSMutableAttributedString (QAAttributedString)

@property (nonatomic, copy, nullable) NSMutableDictionary *highlightRanges;
@property (nonatomic, copy, nullable) NSMutableDictionary *highlightContents;
@property (nonatomic, copy, nullable) NSDictionary *truncationInfo;
@property (nonatomic, copy, nullable) NSArray *searchRanges;
@property (nonatomic, copy, nullable) NSDictionary *searchAttributeInfo;
@property (nonatomic, copy, nullable) NSAttributedString *truncationText;

/**
 存储高亮文本 (key:range - value:highlightText)
 */
@property (nonatomic, strong) NSMutableDictionary * _Nullable textDic;

/**
 存储高亮文本 (key:range - value:highlightText_Changed)
 highlightText_Changed 是指经过变化的高亮文案、 PS: "https://www.avery.com.cn -> 网页短连接"  (key:range - value:"网页短连接")
 */
@property (nonatomic, strong) NSMutableDictionary * _Nullable textChangedDic;

/**
 存储高亮文本所属的类型 (key:range - value:link/at/topic)
 */
@property (nonatomic, strong) NSMutableDictionary * _Nullable textTypeDic;

/**
是否绘制了"seeMoreText"文本、YES表示已绘制
*/
@property (nonatomic, assign) BOOL showMoreTextEffected;

/**
 联合 "...查看全文" 或者 "...全文" 【用truncationText来截断当前的字符串】
 
 @param truncationText 需要追加的文案
 @param maximumNumberOfRows 最多显示的行数
 */
- (NSMutableAttributedString * _Nonnull)joinWithTruncationText:(NSMutableAttributedString * _Nullable)truncationText
                                                      textRect:(CGRect)textRect
                                           maximumNumberOfRows:(NSInteger)maximumNumberOfRows
                                                       ctFrame:(CTFrameRef _Nonnull)ctFrame;


/**
 获取链接以及链接的位置
 
 @param ranges 存放获取到的链接的位置数组
 @param links 存放获取到的链接数组
 */
- (void)getLinkUrlStringsSaveWithRangeArray:(NSMutableArray * _Nullable __strong *_Nullable)ranges
                                      links:(NSMutableArray * _Nullable __strong *_Nullable)links;

/**
 获取链接以及链接的位置
 
 @param texts 需要搜索的文案
 @param ranges 存放搜索到的text的位置数组
 */
- (void)searchTexts:(NSArray * _Nonnull)texts
 saveWithRangeArray:(NSMutableArray * _Nullable __strong *_Nullable)ranges;

/**
 获取at以及at的位置
 
 @param ranges 存放获取到的"@user"的位置数组
 @param ats 存放获取到的"@user"数组
 */
- (void)getAtStringsSaveWithRangeArray:(NSMutableArray * _Nullable __strong *_Nullable)ranges
                                   ats:(NSMutableArray * _Nullable __strong *_Nullable)ats;

/**
 获取topic以及topic的位置
 
 @param ranges 存放获取到的"#...#"的位置数组
 @param topics 存放获取到的"#...#"数组
 */
- (void)getTopicsSaveWithRangeArray:(NSMutableArray * _Nullable __strong *_Nullable)ranges
                             topics:(NSMutableArray * _Nullable __strong *_Nullable)topics;

/**
 处理高亮文案的字体属性、将相关属性更新到当前的attributeString中
 
 @param highlightColor 高亮文案的字体颜色
 @param backgroundColor 高亮文案的背景颜色
 @param highlightFont 高亮文案的字体
 @param highlightRange 高亮文案的位置
 */
- (void)updateAttributeStringWithHighlightColor:(UIColor * _Nonnull)highlightColor
                                backgroundColor:(UIColor * _Nullable)backgroundColor
                                  highlightFont:(UIFont * _Nonnull)highlightFont
                                 highlightRange:(NSRange)highlightRange;


- (NSDictionary * _Nullable)getInstanceProperty;
- (void)setProperties:(NSDictionary * _Nonnull)dic;

@end
