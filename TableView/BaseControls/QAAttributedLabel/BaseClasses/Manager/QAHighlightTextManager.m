//
//  QAHighlightTextManager.m
//  CoreText
//
//  Created by 我去 on 2018/12/21.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QAHighlightTextManager.h"
#import "QAAttributedLabelConfig.h"

@implementation QAHighlightTextManager

+ (void)getHighlightInfoWithContent:(NSString * __strong *)content
                    isLinkHighlight:(BOOL)isLinkHighlight
                    isShowShortLink:(BOOL)isShowShortLink
                          shortLink:(NSString *)shortLink
                      isAtHighlight:(BOOL)isAtHighlight
                   isTopicHighlight:(BOOL)isTopicHighlight
                  highlightContents:(NSMutableDictionary * __strong *)highlightContents
                    highlightRanges:(NSMutableDictionary * __strong *)highlightRanges {
    // 处理高亮显示的link链接 (首先处理link、因为有可能涉及到短连接的替换、会影响到range):
    if (isLinkHighlight) {
        NSMutableArray *ranges = [NSMutableArray array];
        NSMutableArray *links = [NSMutableArray array];
        [*content getLinkUrlStringsSaveWithRangeArray:&ranges links:&links];
        
        NSMutableArray *srcLinks = [[NSMutableArray alloc] initWithArray:links copyItems:YES];
        [*highlightContents setValue:srcLinks forKey:@"srcLink"];   // 保存短连接替换前的链接地址
        
        // 处理link短链接:
        if (links.count > 0 && isShowShortLink) {
            if (!shortLink || shortLink.length == 0) {
                shortLink = QAShortLink_Default;
            }
            
            NSInteger diff_pre = 0;
            for (NSUInteger i = 0; i < ranges.count; i++) {
                NSString *rangeString = [ranges objectAtIndex:i];
                NSRange range = NSRangeFromString(rangeString);
                
                NSString *linkString = [links objectAtIndex:i];
                NSInteger diff = shortLink.length - linkString.length;   // 长度差
                range.location = range.location + diff_pre;
                range.length = shortLink.length;
                [ranges replaceObjectAtIndex:i withObject:NSStringFromRange(range)];
                diff_pre = diff;
                
                [links replaceObjectAtIndex:i withObject:shortLink];
                *content = [*content stringByReplacingOccurrencesOfString:linkString withString:shortLink];
            }
            
            /**【 下面的代码有重大bug 】
             for (NSUInteger i = 0; i < links.count ; i++) {
                 NSString *linkurlstring = [links objectAtIndex:i];
                 *content = [*content stringByReplacingOccurrencesOfString:linkurlstring withString:shortLink];
             }
             
             // 替换完link短链接后、重新获取高亮显示的短链接的位置 【 此处有重大bug 】:
             [ranges removeAllObjects];
             [*content getString:shortLink saveWithRangeArray:&ranges];
            */
        }
        [*highlightRanges setValue:ranges forKey:@"link"];
        [*highlightContents setValue:links forKey:@"link"];
    }
    
    // 处理高亮显示的"@user":
    if (isAtHighlight) {
        NSMutableArray *ranges = [NSMutableArray array];
        NSMutableArray *ats = [NSMutableArray array];
        [*content getAtStringsSaveWithRangeArray:&ranges ats:&ats];
        [*highlightRanges setValue:ranges forKey:@"at"];
        [*highlightContents setValue:ats forKey:@"at"];
    }
    
    // 处理topic话题
    if (isTopicHighlight) {
        NSMutableArray *ranges = [NSMutableArray array];
        NSMutableArray *topics = [NSMutableArray array];
        [*content getTopicsSaveWithRangeArray:&ranges topics:&topics];
        [*highlightRanges setValue:ranges forKey:@"topic"];
        [*highlightContents setValue:topics forKey:@"topic"];
    }
}

+ (void)getHighlightRangeWithContent:(NSString *)content
                      highLightTexts:(NSArray *)highLightTexts
                     highlightRanges:(NSMutableDictionary * __strong *)highlightRanges {
    NSMutableArray *ranges = [NSMutableArray array];
    UIColor *highLightTextColor = nil;
    for (id obj in highLightTexts) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *highLightText = (NSString *)obj;
            [content getString:highLightText saveWithRangeArray:&ranges];
        }
        else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)obj;
            NSString *highLightText = [dic valueForKey:@"highLightText"];
            highLightTextColor = [dic valueForKey:@"highLightColor"];
            [content getString:highLightText saveWithRangeArray:&ranges];
        }
    }
    if (highLightTextColor) {
        [*highlightRanges setValue:ranges forKey:@"highLightText"];
        [*highlightRanges setValue:highLightTextColor forKey:@"highLightTextColor"];
    }
    else {
        [*highlightRanges setValue:ranges forKey:@"highLightText"];
    }
}

@end
