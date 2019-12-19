//
//  QATextTransaction.m
//  CoreText
//
//  Created by Avery An on 2019/12/17.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "QATextTransaction.h"

@interface QATextTransaction()
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@end


static NSMutableSet *transactionSet = nil;
static void QARunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    if (transactionSet.count == 0) {
        return;
    }
    
    NSSet *currentSet = transactionSet;
    transactionSet = [[NSMutableSet alloc] init];
    [currentSet enumerateObjectsUsingBlock:^(QATextTransaction *transaction, BOOL *stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [transaction.target performSelector:transaction.selector];
#pragma clang diagnostic pop
    }];
}

static void QATextTransactionSetup() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [[NSMutableSet alloc] init];
        
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer;
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true,        // repeat
                                           0xFFFFFF,    // after CATransaction (2000000)
                                           QARunLoopObserverCallBack,
                                           NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}


@implementation QATextTransaction

#pragma mark - Life Cycle -
- (void)dealloc {
    // NSLog(@"%s",__func__);
}


#pragma mark - Public Methods -
+ (QATextTransaction *)transactionWithTarget:(id)target
                                    selector:(SEL)selector {
    if (!target || !selector) {
        return nil;
    }
    
    QATextTransaction *transaction = [[QATextTransaction alloc] init];
    transaction.target = target;
    transaction.selector = selector;
    return transaction;
}

- (void)commit {
    if (!_target || !_selector) {
        return;
    }
    
    QATextTransactionSetup();
    [transactionSet addObject:self];
}

@end
