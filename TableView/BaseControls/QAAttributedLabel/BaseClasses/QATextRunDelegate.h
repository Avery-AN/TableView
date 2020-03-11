//
//  QATextRunDelegate.h
//  CoreText
//
//  Created by Avery on 2018/12/12.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class QATextRunDelegate;

/**
 Text vertical alignment.
 */
typedef NS_ENUM(NSInteger, QATextVerticalAlignment) {
    QATextVerticalAlignmentTop = 0,     // Top alignment
    QATextVerticalAlignmentCenter = 1,  // Center alignment
    QATextVerticalAlignmentBottom = 2,  // Bottom alignment
};


@interface QATextRunDelegate : NSObject

@property (nonatomic) CGFloat ascent;
@property (nonatomic) CGFloat descent;
@property (nonatomic) CGFloat width;
@property (nonatomic) UIViewContentMode contentMode;
@property (nonatomic) QATextVerticalAlignment verticalAlignment;

@property (nonatomic, strong) id attachmentContent;

@end
