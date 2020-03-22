//
//  TrapezoidalCell+SelfManager.h
//  TableView
//
//  Created by Avery An on 2020/3/21.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "TrapezoidalCell.h"

//typedef void (^GetStytleCompletionBlock)(NSInteger start, NSInteger end);

NS_ASSUME_NONNULL_BEGIN

@interface TrapezoidalCell (SelfManager) <QAAttributedLabelProperty>

//@property (nonatomic, copy) GetStytleCompletionBlock completionBlock;

//- (void)getStytle:(NSMutableArray *)datas maxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
//       completion:(GetStytleCompletionBlock)completion;
- (void)getStyleWithQueue:(dispatch_queue_t)dispatchQueue
            dispatchGroup:(dispatch_group_t)dispatchGroup
                      dic:(NSMutableDictionary *)dic
                   bounds:(CGRect)bounds
                    layer:(QAAttributedLayer *)layer;

@end

NS_ASSUME_NONNULL_END
