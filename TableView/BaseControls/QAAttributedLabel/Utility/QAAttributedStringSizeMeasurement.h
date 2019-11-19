//
//  QAAttributedStringSizeMeasurement.h
//  CoreText
//
//  Created by Avery on 2018/12/12.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QAAttributedStringSizeMeasurement : NSObject

/**
 计算Size
 */
+ (CGSize)calculateSizeWithString:(NSAttributedString *)attributedString
                         maxWidth:(NSInteger)maxWidth;

+ (CGSize)textSizeWithAttributeString:(NSMutableAttributedString *)attributedString
                 maximumNumberOfLines:(NSInteger)maximumNumberOfLines
                             maxWidth:(NSInteger)maxWidth;

@end
