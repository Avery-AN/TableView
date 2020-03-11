//
//  QARichTextDraw.h
//  CoreText
//
//  Created by Avery An on 2020/3/6.
//  Copyright © 2020 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (QARichTextDraw)

- (NSRange)getCurrentRunRangeInRichTextLabelWithLineIndex:(NSInteger)lineIndex
                                                 runRange:(NSRange)runRange;

@end

NS_ASSUME_NONNULL_END
