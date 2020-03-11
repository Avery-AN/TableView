//
//  BaseCell.h
//  TestProject
//
//  Created by Avery An on 2019/8/25.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QARichTextLabel.h"
#import "YYImage.h"
//#import <FLAnimatedImage/FLAnimatedImage.h>

typedef NS_ENUM(NSUInteger, BaseCell_TapedStyle) {
    BaseCell_Taped_Name = 1,            // 点中了名称
    BaseCell_Taped_Desc,                // 点中了简介
    BaseCell_Taped_Avatar,              // 点中了头像
    BaseCell_Taped_ContentImageView,    // 点中了contentImageView
    BaseCell_Taped_Content              // 点中了content
};

NS_ASSUME_NONNULL_BEGIN

@interface BaseCell : UITableViewCell
@property (nonatomic) UIImageView *avatar;
@property (nonatomic) UIImageView *contentImageView;
@property (nonatomic) YYAnimatedImageView *yyImageView;
//@property (nonatomic) FLAnimatedImageView *flImageView;
/**
 如果不显示gif用这个contentImageLayer即可、无需使用contentImageView、yyImageView、flImageView等UI控件
 */
@property (nonatomic) CALayer *contentImageLayer;
@property (nonatomic) QARichTextLabel *content;
@property (nonatomic, unsafe_unretained) NSDictionary *styleInfo;
@property (nonatomic, copy) void (^ _Nullable baseCellTapAction)(BaseCell *cell, BaseCell_TapedStyle style, NSString *content);


/**
 存放需要显示的控件以及控件的样式
 dic: key(property) - value(CGRectValue)
 */
- (void)showStytle:(NSDictionary *)dic;

/**
 设置AttributedLabel的相关属性
 */
- (void)setProperties:(NSDictionary *)dic;

/**
 Cell的布局
 */
- (void)masonryLayout:(NSDictionary *)dic;

/**
 Cell的绘制
 */
- (void)draw:(NSDictionary *)dic;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
