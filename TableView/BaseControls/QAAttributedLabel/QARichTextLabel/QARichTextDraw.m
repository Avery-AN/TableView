//
//  QARichTextDraw.m
//  CoreText
//
//  Created by Avery An on 2020/3/6.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QARichTextDraw.h"

@implementation NSMutableAttributedString (QARichTextDraw)

- (NSRange)getCurrentRunRangeInRichTextLabelWithLineIndex:(NSInteger)lineIndex
                                                 runRange:(NSRange)runRange {
    return runRange;
}

@end
