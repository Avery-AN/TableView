//
//  ScratchablelatexCell+SelfManager.h
//  TestProject
//
//  Created by Avery An on 2019/9/8.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "ScratchablelatexCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^GetStytleCompletionBlock)(NSInteger start, NSInteger end);

@interface ScratchablelatexCell (SelfManager)

@property (nonatomic, copy) GetStytleCompletionBlock completionBlock;

+ (void)getStytle:(NSMutableArray *)datas maxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
       completion:(GetStytleCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
