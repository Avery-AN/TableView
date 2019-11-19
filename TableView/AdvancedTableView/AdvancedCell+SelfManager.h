//
//  AdvancedCell+SelfManager.h
//  TestProject
//
//  Created by Avery An on 2019/8/28.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "AdvancedCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^GetStytleCompletionBlock)(NSInteger start, NSInteger end);

@interface AdvancedCell (SelfManager)

@property (nonatomic, copy) GetStytleCompletionBlock completionBlock;

+ (void)getStytle:(NSMutableArray *)datas maxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
       completion:(GetStytleCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
