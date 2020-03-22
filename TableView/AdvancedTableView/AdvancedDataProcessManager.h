//
//  AdvancedDataProcessManager.h
//  TableView
//
//  Created by Avery An on 2020/3/21.
//  Copyright © 2020 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DataProcessManagerCompletionBlock)(NSInteger start, NSInteger end);

NS_ASSUME_NONNULL_BEGIN

@interface AdvancedDataProcessManager : NSObject

+ (void)processData:(NSMutableArray *)srcArray
         maxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount completion:(DataProcessManagerCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
