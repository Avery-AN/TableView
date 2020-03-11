//
//  QATextTransaction.h
//  CoreText
//
//  Created by Avery An on 2019/12/17.
//  Copyright © 2019 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QATextTransaction : NSObject

/**
 Creates and returns a transaction with a specified target and selector.
 
 @param target    A specified target,the target is retained until runloop end.
 @param selector  A selector for target.
 
 @return A new transaction, or nil if an error occurs.
 */
+ (QATextTransaction *)transactionWithTarget:(id)target selector:(SEL)selector;

/**
 Commit the trancaction to main runloop.
 
 @discussion It will perform the selector on the target once before main runloop's
 current loop sleep. If the same transaction (same target and same selector) has
 already commit to runloop in this loop, this method do nothing.
 */
- (void)commit;

@end

NS_ASSUME_NONNULL_END
