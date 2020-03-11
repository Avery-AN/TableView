//
//  QAHighlightTextManager.h
//  CoreText
//
//  Created by 我去 on 2018/12/21.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QAAttributedLabel;

@interface QAHighlightTextManager : NSObject

+ (void)getHighlightInfoWithContent:(NSString * __strong *)content
                    isLinkHighlight:(BOOL)isLinkHighlight
                    isShowShortLink:(BOOL)isShowShortLink
                          shortLink:(NSString *)shortLink
                      isAtHighlight:(BOOL)isAtHighlight
                   isTopicHighlight:(BOOL)isTopicHighlight
                  highlightContents:(NSMutableDictionary * __strong *)highlightContents
                    highlightRanges:(NSMutableDictionary * __strong *)highlightRanges;


+ (void)getHighlightRangeWithContent:(NSString *)content
                      highLightTexts:(NSArray *)highLightTexts
                     highlightRanges:(NSMutableDictionary * __strong *)highlightRanges;

@end
