//
//  RichTextDataProcessManager.m
//  TableView
//
//  Created by Avery An on 2020/3/21.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "RichTextDataProcessManager.h"
#import "RichTextCell+SelfManager.h"
#import "TrapezoidalCell+SelfManager.h"
#import "QATrapezoidalLayer.h"
#import "QARichTextLayer.h"

@implementation RichTextDataProcessManager

+ (void)processData:(NSMutableArray *)srcArray
maxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount completion:(DataProcessManagerCompletionBlock)completionBlock {
    if (!srcArray || srcArray.count == 0) {
        if (completionBlock) {
            completionBlock(0, 0);
        }
    }
    else {
        if (maxConcurrentOperationCount <= 0) {
            maxConcurrentOperationCount = 1;
        }
        if (maxConcurrentOperationCount > 20) {
            maxConcurrentOperationCount = 20;
        }
        
        CGRect trapezoidalLabelBounds = CGRectZero;
        NSMutableArray *TrapezoidalCells = [NSMutableArray arrayWithCapacity:maxConcurrentOperationCount];
        NSMutableArray *TrapezoidalCellLayers = [NSMutableArray arrayWithCapacity:maxConcurrentOperationCount];
        for (int i = 0; i < maxConcurrentOperationCount; i++) {
            TrapezoidalCell *cell = [[TrapezoidalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"style-%ld",(i % maxConcurrentOperationCount)]];
            
            [TrapezoidalCells addObject:cell];
            [TrapezoidalCellLayers addObject:cell.trapezoidalLabel.layer];
            
            if (CGRectEqualToRect(trapezoidalLabelBounds, CGRectZero)) {
                trapezoidalLabelBounds = cell.trapezoidalLabel.bounds;
            }
        }

        
        CGRect richTextBounds = CGRectZero;
        NSMutableArray *RichTextcells = [NSMutableArray arrayWithCapacity:maxConcurrentOperationCount];
        NSMutableArray *RichTextcellLayers = [NSMutableArray arrayWithCapacity:maxConcurrentOperationCount];
        for (int i = 0; i < maxConcurrentOperationCount; i++) {
            RichTextCell *cell = [[RichTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"style-%ld",(i % maxConcurrentOperationCount)]];
            
            [RichTextcells addObject:cell];
            [RichTextcellLayers addObject:cell.styleLabel.layer];
            
            if (CGRectEqualToRect(richTextBounds, CGRectZero)) {
                richTextBounds = cell.styleLabel.bounds;
            }
        }
        
        
        
        __block NSDictionary *richText_styleProperties = nil;
        __block NSDictionary *trapezoidal_styleProperties = nil;
        __block NSInteger start = 0;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_group_t processGroup = dispatch_group_create();
        dispatch_queue_t processQueue = dispatch_queue_create("com.avery.processQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(processQueue, ^{
            for (int i = 0; i < srcArray.count; i++) {
                NSMutableDictionary *dic_item = [srcArray objectAtIndex:i];
                if ([dic_item valueForKey:@"trapezoidalTexts"]) {
                    TrapezoidalCell *cell = [TrapezoidalCells objectAtIndex:(i % maxConcurrentOperationCount)];
                    QATrapezoidalLayer *layer = [TrapezoidalCellLayers objectAtIndex:(i % maxConcurrentOperationCount)];
                    if (!trapezoidal_styleProperties) {
                        trapezoidal_styleProperties = [cell getInstanceProperty:cell.trapezoidalLabel];
                    }
                    if (![dic_item isKindOfClass:[NSMutableDictionary class]]) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dic_item];
                        [srcArray replaceObjectAtIndex:i withObject:dic];
                        [dic setValue:trapezoidal_styleProperties forKey:@"content-functions"];
                        [cell getStyleWithQueue:processQueue dispatchGroup:processGroup dic:dic bounds:trapezoidalLabelBounds layer:layer];
                    }
                    else {
                        [dic_item setValue:trapezoidal_styleProperties forKey:@"content-functions"];
                        [cell getStyleWithQueue:processQueue dispatchGroup:processGroup dic:dic_item bounds:trapezoidalLabelBounds layer:layer];
                    }
                }
                else {
                    RichTextCell *cell = [RichTextcells objectAtIndex:(i % maxConcurrentOperationCount)];
                    QARichTextLayer *layer = [RichTextcellLayers objectAtIndex:(i % maxConcurrentOperationCount)];
                    if (!richText_styleProperties) {
                        richText_styleProperties = [cell getInstanceProperty:cell.styleLabel];
                    }
                    if (![dic_item isKindOfClass:[NSMutableDictionary class]]) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dic_item];
                        [srcArray replaceObjectAtIndex:i withObject:dic];
                        [dic setValue:richText_styleProperties forKey:@"content-functions"];
                        [cell getStyleWithQueue:processQueue dispatchGroup:processGroup dic:dic bounds:richTextBounds layer:layer];
                    }
                    else {
                        [dic_item setValue:richText_styleProperties forKey:@"content-functions"];
                        [cell getStyleWithQueue:processQueue dispatchGroup:processGroup dic:dic_item bounds:richTextBounds layer:layer];
                    }
                }
                
                
                if ((i+1) % maxConcurrentOperationCount == 0 || i == (srcArray.count - 1)) {
                    dispatch_group_notify(processGroup, processQueue, ^{
                        // NSLog(@"一组任务已完成");
                        if (completionBlock) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completionBlock(start, i);
                                // NSLog(@"start: %ld; i: %d", start, i);
                                start = start + maxConcurrentOperationCount;
                            });
                        }
                        dispatch_semaphore_signal(semaphore);
                    });
                    
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                }
            }
        });
    }
}

@end
