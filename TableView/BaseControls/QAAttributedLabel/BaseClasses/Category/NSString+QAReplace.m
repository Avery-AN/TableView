//
//  NSString+QAReplace.m
//  CoreText
//
//  Created by 我去 on 2018/12/14.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "NSString+QAReplace.h"
#import "QAAttributedLabelConfig.h"

@implementation NSString (QAReplace)

/**
 获取链接以及链接的位置
 
 @param ranges 存放获取到的链接的位置数组
 @param links 存放获取到的链接数组
 */
- (void)getLinkUrlStringsSaveWithRangeArray:(NSMutableArray *_Nonnull __strong *_Nonnull)ranges
                                      links:(NSMutableArray *_Nonnull __strong *_Nonnull)links {
    NSString *content = self;
    
    // 根据匹配条件创建正则表达式:
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:QALinkRegularExpression options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regex) {
        NSLog(@"  正则创建失败: %@", [error localizedDescription]);
    }
    else {
        NSArray *allMatches = [regex matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
        if (allMatches.count > 0) {
            for (NSTextCheckingResult *match in allMatches) {
                NSRange range = match.range;
                NSString *substrinsgForMatch = [content substringWithRange:range];
                if ([substrinsgForMatch hasSuffix:@"#"]) {   // 处理连接中的#
                    substrinsgForMatch = [substrinsgForMatch substringToIndex:substrinsgForMatch.length-1];
                    range = NSMakeRange(range.location, range.length - 1);
                    [*ranges addObject:NSStringFromRange(range)];
                    [*links addObject:substrinsgForMatch];
                }
                else {
                    NSInteger counts = 0;
                    NSString *str = @"...";
                    while ([substrinsgForMatch hasSuffix:str]) {  // 特殊情况处理(链接被截断的情况)
                        substrinsgForMatch = [substrinsgForMatch substringToIndex:substrinsgForMatch.length-str.length];
                        counts = counts + str.length;
                    }
                    range = NSMakeRange(range.location, range.length - counts);
                    [*ranges addObject:NSStringFromRange(range)];
                    [*links addObject:substrinsgForMatch];
                }
            }
        }
    }
}

/**
 获取at以及at的位置
 
 @param ranges 存放获取到的"@user"的位置数组
 @param ats 存放获取到的"@user"数组
 */
- (void)getAtStringsSaveWithRangeArray:(NSMutableArray *_Nonnull __strong *_Nonnull)ranges
                                   ats:(NSMutableArray *_Nonnull __strong *_Nonnull)ats {
    NSString *content = self;
    
    // 根据匹配条件创建正则表达式:
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:QAAtRegularExpression options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regex) {
        NSLog(@"  正则创建失败: %@", [error localizedDescription]);
    }
    else {
        NSArray *allMatches = [regex matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
        if (allMatches.count > 0) {
            for (NSTextCheckingResult *match in allMatches) {
                NSRange range = match.range;
                [*ranges addObject:NSStringFromRange(range)];
                
                NSString *substrinsgForMatch = [content substringWithRange:range];
                [*ats addObject:substrinsgForMatch];
            }
        }
    }
}


/**
 获取topic以及topic的位置
 
 @param ranges 存放获取到的"#...#"的位置数组
 @param topics 存放获取到的"#...#"数组
 */
- (void)getTopicsSaveWithRangeArray:(NSMutableArray *_Nonnull __strong *_Nonnull)ranges
                             topics:(NSMutableArray *_Nonnull __strong *_Nonnull)topics {
    NSString *content = self;
    
    // 根据匹配条件创建正则表达式:
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:QATopicRegularExpression options:NSRegularExpressionCaseInsensitive error:&error];
    if (!regex) {
        NSLog(@"  正则创建失败: %@", [error localizedDescription]);
    }
    else {
        NSArray *allMatches = [regex matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
        if (allMatches.count > 0) {
            for (NSTextCheckingResult *match in allMatches) {
                NSRange range = match.range;
                [*ranges addObject:NSStringFromRange(range)];
                
                NSString *substrinsgForMatch = [content substringWithRange:range];
                [*topics addObject:substrinsgForMatch];
            }
        }
    }
}

/**
 获取某字符串的位置
 
 @param string 需要查找的字符串
 @param ranges 存放获取到的字符串的位置数组
 */
- (void)getString:(NSString * _Nonnull)string saveWithRangeArray:(NSMutableArray *_Nonnull __strong *_Nonnull)ranges {
    NSRange range = [self rangeOfString:string];
    if (range.location != NSNotFound) {
        [*ranges addObject:NSStringFromRange(range)];
        NSInteger startLocation = range.location + range.length;
        NSString *substring = [self substringFromIndex:startLocation];
        
        for (;;) {
            NSRange range_circle = [substring rangeOfString:string];
            if (range_circle.location == NSNotFound) {
                break;
            }
            else {
                NSInteger subPosition = range_circle.location + range_circle.length;
                substring = [substring substringFromIndex:subPosition];
                
                NSInteger rangeLocation = startLocation + range_circle.location;
                NSRange tmpRange = NSMakeRange(rangeLocation, range_circle.length);
                [*ranges addObject:NSStringFromRange(tmpRange)];
                
                startLocation = startLocation + (range_circle.location + range_circle.length);
            }
        }
    }
}

@end
