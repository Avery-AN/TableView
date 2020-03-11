//
//  QATextLayout.h
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QATextLayout : NSObject

@property (nonatomic, unsafe_unretained, nullable) UIFont *font;
@property (nonatomic, assign) NSUInteger numberOfLines;         // 行数
@property (nonatomic, assign) CGFloat lineSpace;                // 行间距
@property (nonatomic, assign) int wordSpace;                    // 字间距
@property (nonatomic, assign) CGFloat paragraphSpace;           // 段间距
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;    // 换行模式
@property (nonatomic, assign) NSTextAlignment textAlignment;    // 对齐方式
@property (nonatomic, unsafe_unretained, nullable) UIColor *textColor;       // 字体颜色

@property (nonatomic, unsafe_unretained, nullable) UIFont *moreTextFont;                     // SeeMore文案的字体
@property (nonatomic, unsafe_unretained, null_resettable) UIColor *moreTextColor;            // SeeMore文案的颜色
@property (nonatomic, unsafe_unretained, null_resettable) UIColor *moreTextBackgroundColor;  // SeeMore文案的背景颜色

/**
 如果直接传入此参数、那么则会忽略上面的属性设置 (font、lineSpace、textColor等)。
 */
@property (nonatomic, unsafe_unretained, nullable) NSMutableAttributedString *attributedText;
@property (nonatomic, unsafe_unretained, nullable) NSMutableAttributedString *renderText;
@property (nonatomic, strong, readonly) NSMutableDictionary * _Nonnull textAttributes;
@property (nonatomic, strong, readonly) NSMutableDictionary * _Nonnull truncationTextAttributes;
@property (nonatomic, assign, readonly) CGSize textBoundSize;

- (NSDictionary * _Nullable)getTextAttributesWithCheckBlock:(BOOL(^_Nullable)(void))checkBlock;
- (NSDictionary * _Nullable)getTruncationTextAttributesWithCheckBlock:(BOOL(^_Nullable)(void))checkBlock;

+ (instancetype _Nonnull)layoutWithContainerSize:(CGSize)size
                                  attributedText:(NSMutableAttributedString * _Nonnull)attributedText;

- (void)setupContainerSize:(CGSize)size
            attributedText:(NSMutableAttributedString * _Nonnull)attributedText;

@end
