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

/**
 RunloopObserver的回调方法，从transactionSet取出transaction对象执行SEL的方法，分发到每一次Runloop执行，避免一次Runloop执行时间太长。
 */
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

/**
 QATransaction有target & selector的属性，selector其实就是_updateIfNeeded方法。
 当调用"transactionWithTarget:selector:"方法时、会保存target&selector;
 当调用"comit"方法时并不会立即在后台线程去更新显示(即不会立即执行[target selector]方法)，而是首先将QATransaction对象本身保存在
 一个全局的transactionSet的集合中，然后再注册一个RunloopObserver，并监听MainRunloop在kCFRunLoopCommonModes中的
 KCFRunLoopBeforeWaiting和KCFRunLoopExit两个状态，等runloop处于这2个状态时再执行"[target selector]", 也就是说在一次Runloop空闲时去执行更新显示的操作。
 */
static void QATextTransactionSetup() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [[NSMutableSet alloc] init];
        
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer;
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit, // 监听2个状态
                                           true,        // repeat
                                           (2000000-1), // 设定观察者的优先级 after CATransaction(2000000) 这是为了确保系统的动画优先执行，之后再执行异步渲染。
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
