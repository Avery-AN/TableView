//
//  QAAttributedLabelConfig.h
//  CoreText
//
//  Created by 我去 on 2018/12/18.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <objc/runtime.h>
#import "QAAttributedStringSizeMeasurement.h"
#import "NSMutableAttributedString+QAAttributedString.h"
#import "NSString+QAReplace.h"
#import "UIImage+QACutImage.h"
#import "QAEmojiTextManager.h"
#import "QAHighlightTextManager.h"
#import "UIImage+DecodeImage.h"
#import "NSString+Md5.h"
#import "QAAttributedLayer+Cache.h"
#import "QABackgroundDraw.h"


/**
 默认颜色
 */
#define HighlightTextColor_DEFAULT                  [UIColor lightGrayColor]
#define HighlightTextBackgroundColor_DEFAULT        [UIColor clearColor]
#define MoreTextColor_DEFAULT                       [UIColor orangeColor]
#define MoreTextBackgroundColor_DEFAULT             [UIColor clearColor]

/**
 默认文本
 */
static NSString *QASeeMoreText_DEFAULT = @"...查看全文";
static NSString *QAShortLink_Default = @"网页短链接";
static NSString *QAEmojiSpaceReplaceString = @"\uFFFC";   // 空的占位字符

/**
 正则表达式
 */
static NSString *QAEmojiRegularExpression = @"\\[[0-9a-zA-Z\\u4e00-\\u9fa5]+\\]";  // 匹配自定义Emoji表情的正则表达式 [XXX]
static NSString *QALinkRegularExpression = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";  // 网页链接的正则表达式
static NSString *QAAtRegularExpression = @"@[0-9a-zA-Z\\u4e00-\\u9fa5\\-]+";    // @user 艾特的正则表达式
static NSString *QATopicRegularExpression = @"#[0-9a-zA-Z\\u4e00-\\u9fa5]+#";   // "#...#" 话题的正则表达式
