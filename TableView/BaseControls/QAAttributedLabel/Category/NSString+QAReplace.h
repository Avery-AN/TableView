//
//  NSString+QAReplace.h
//  CoreText
//
//  Created by 我去 on 2018/12/14.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QAReplace)

/**
 获取链接以及链接的位置
 
 @param ranges 存放获取到的链接的位置数组
 @param links 存放获取到的链接数组
 */
- (void)getLinkUrlStringsSaveWithRangeArray:(NSMutableArray *_Nonnull __strong *_Nonnull)ranges
                                      links:(NSMutableArray *_Nonnull __strong *_Nonnull)links;

/**
 获取at以及at的位置
 
 @param ranges 存放获取到的"@user"的位置数组
 @param ats 存放获取到的"@user"数组
 */
- (void)getAtStringsSaveWithRangeArray:(NSMutableArray *_Nonnull __strong *_Nonnull)ranges
                                   ats:(NSMutableArray *_Nonnull __strong *_Nonnull)ats;

/**
 获取topic以及topic的位置
 
 @param ranges 存放获取到的"#...#"的位置数组
 @param topics 存放获取到的"#...#"数组
 */
- (void)getTopicsSaveWithRangeArray:(NSMutableArray *_Nonnull __strong *_Nonnull)ranges
                             topics:(NSMutableArray *_Nonnull __strong *_Nonnull)topics;


/**
 获取某字符串的位置
 
 @param string 需要查找的字符串
 @param ranges 存放获取到的字符串的位置数组
 */
- (void)getString:(NSString * _Nonnull)string saveWithRangeArray:(NSMutableArray *_Nonnull __strong *_Nonnull)ranges;

@end
