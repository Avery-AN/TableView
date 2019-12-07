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


#define HighlightTextColor_DEFAULT                      [UIColor whiteColor]
#define HighlightTextBackgroundColor_DEFAULT            [UIColor clearColor]
#define MoreTextColor_DEFAULT                           [UIColor greenColor]
#define MoreTextBackgroundColor_DEFAULT                 [UIColor clearColor]
static NSString *SeeMoreText_DEFAULT = @"...查看全文";
static NSString *ShortLink_Default = @"网页短链接";
