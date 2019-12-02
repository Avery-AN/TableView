//
//  QAEmojiTextManager.h
//  CoreText
//
//  Created by 我去 on 2018/12/20.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^QAEmojiCompletionBlock)(BOOL success, NSArray * _Nullable emojiTexts, NSArray * _Nullable matches);

@interface QAEmojiTextManager : NSObject

+ (void)processDiyEmojiText:(NSMutableAttributedString * _Nonnull)attributedString
                       font:(UIFont * _Nonnull)font
                  wordSpace:(NSUInteger)wordSpace
             textAttributes:(NSDictionary * _Nonnull)textAttributes
                 completion:(QAEmojiCompletionBlock _Nullable)completion;

@end
