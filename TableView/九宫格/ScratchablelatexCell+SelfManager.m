//
//  ScratchablelatexCell+SelfManager.m
//  TestProject
//
//  Created by Avery An on 2019/9/8.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "ScratchablelatexCell+SelfManager.h"
#import "QAAttributedLabelConfig.h"
#import <objc/runtime.h>

@implementation ScratchablelatexCell (SelfManager)

#pragma mark - GetInstanceProperty -
- (NSDictionary *)getInstanceProperty:(id)instance {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *dic_base = [NSMutableDictionary dictionary];
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([QAAttributedLabel class], &count);
    for (NSUInteger i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [instance valueForKey:key];
        const char *attributes_c = property_getAttributes(property);
        NSString *attributes = [NSString stringWithUTF8String:attributes_c];
        if (value && [attributes rangeOfString:@",R,"].location == NSNotFound) {  // 排除没有被赋值的属性 & 只读属性
            [dic_base setObject:value forKey:key];
        }
    }
    [dic setValuesForKeysWithDictionary:dic_base];
    free(properties);
    
    if (![[instance class] isKindOfClass:[QAAttributedLabel class]]) {
        NSMutableDictionary *dic_current = [NSMutableDictionary dictionary];
        count = 0;
        properties = class_copyPropertyList([instance class], &count);
        for (NSUInteger i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            const char *name = property_getName(property);
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [instance valueForKey:key];
            const char *attributes_c = property_getAttributes(property);
            NSString *attributes = [NSString stringWithUTF8String:attributes_c];
            if (value && [attributes rangeOfString:@",R,"].location == NSNotFound) {  // 排除没有被赋值的属性 & 只读属性
                [dic_current setObject:value forKey:key];
            }
        }
        [dic setValuesForKeysWithDictionary:dic_current];
        free(properties);
    }
    
    return dic;
}


#pragma mark - Public Methods -
+ (void)getStytle:(NSMutableArray *)datas maxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
       completion:(GetStytleCompletionBlock)completion {
    
    GetStytleCompletionBlock completionBlock = nil;
    if (completion) {
        completionBlock = [completion copy];
    }
    
    if (maxConcurrentOperationCount <= 0) {
        maxConcurrentOperationCount = 1;
    }
    if (maxConcurrentOperationCount > 20) {
        maxConcurrentOperationCount = 20;
    }
    
    CGRect styleLabelBounds = CGRectZero;
    NSMutableArray *cells = [NSMutableArray arrayWithCapacity:maxConcurrentOperationCount];
    NSMutableArray *cellLayers = [NSMutableArray arrayWithCapacity:maxConcurrentOperationCount];
    for (NSUInteger i = 0; i < maxConcurrentOperationCount; i++) {
        ScratchablelatexCell *cell = [[ScratchablelatexCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"style-%ld",(i % maxConcurrentOperationCount)]];
        
        [cells addObject:cell];
        [cellLayers addObject:cell.styleLabel.layer];
        styleLabelBounds = cell.styleLabel.bounds;
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_queue_t dispatchQueue = dispatch_queue_create("com.avery.parseDataQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t dispatchGroup = dispatch_group_create();
        
        NSDictionary *styleProperties = nil;
        __block NSInteger start = 0;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        for (NSUInteger i = 0; i < datas.count; i++) {
            NSMutableDictionary *dic_item = [datas objectAtIndex:i];
            
            ScratchablelatexCell *cell = [cells objectAtIndex:(i % maxConcurrentOperationCount)];
            QAAttributedLayer *layer = [cellLayers objectAtIndex:(i % maxConcurrentOperationCount)];
            if (![dic_item isKindOfClass:[NSMutableDictionary class]]) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dic_item];
                [datas replaceObjectAtIndex:i withObject:dic];
                if (!styleProperties) {
                    styleProperties = [cell getInstanceProperty:cell.styleLabel];
                }
                [dic setValue:styleProperties forKey:@"content-functions"];
                [cell getStyleWithQueue:dispatchQueue dispatchGroup:dispatchGroup dic:dic bounds:styleLabelBounds layer:layer];
            }
            else {
                if (!styleProperties) {
                    styleProperties = [cell getInstanceProperty:cell.styleLabel];
                }
                [dic_item setValue:styleProperties forKey:@"content-functions"];
                [cell getStyleWithQueue:dispatchQueue dispatchGroup:dispatchGroup dic:dic_item bounds:styleLabelBounds layer:layer];
            }
            
            if ((i+1) % maxConcurrentOperationCount == 0 || i == (datas.count - 1)) {
                dispatch_group_notify(dispatchGroup, dispatchQueue, ^{
                    // NSLog(@"一组任务已完成");
                    if (completionBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(start, i);
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


#pragma mark - Private Methods -
- (void)getStyleWithQueue:(dispatch_queue_t)dispatchQueue
            dispatchGroup:(dispatch_group_t)dispatchGroup
                      dic:(NSMutableDictionary *)dic
                      bounds:(CGRect)bounds
                       layer:(QAAttributedLayer *)layer {
    NSString *content = [dic valueForKey:@"content"];
    CGFloat maxWidth = bounds.size.width;
    
    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatchQueue, ^{
        [self.styleLabel getTextContentSizeWithLayer:layer
                                             content:content
                                            maxWidth:maxWidth
                                     completionBlock:^(CGSize size, NSMutableAttributedString *attributedString) {
                                         [dic setValue:attributedString forKey:@"content-attributed"];
                                         if ([dic valueForKey:@"contentImageView-frame"]) {
                                             CGRect frame = [[dic valueForKey:@"contentImageView-frame"] CGRectValue];
                                             NSInteger contentTop = frame.origin.y + frame.size.height + ContentImageView_bottomControl_gap;
                                             [dic setValue:[NSValue valueWithCGRect:CGRectMake(Avatar_left_gap, contentTop, maxWidth, size.height)] forKey:@"content-frame"];
                                             
                                             CGFloat totalHeight = contentTop + size.height + Content_bottom_gap;
                                             [dic setValue:[NSValue valueWithCGRect:CGRectMake(0, 0, UIWidth, totalHeight)] forKey:@"cell-frame"];
                                         }
                                         else {
                                             NSArray *contentImageViews = [dic valueForKey:@"contentImageViews"];
                                             NSDictionary *contentImageViewDic = [contentImageViews lastObject];
                                             CGRect frame = [[contentImageViewDic valueForKey:@"frame"] CGRectValue];
                                             
                                             NSInteger contentTop = frame.origin.y + frame.size.height + ContentImageView_bottomControl_gap;
                                             CGRect contentFrame = CGRectMake(Avatar_left_gap, contentTop, maxWidth, size.height);
                                             [dic setValue:[NSValue valueWithCGRect:contentFrame] forKey:@"content-frame"];
                                             
                                             CGFloat totalHeight = contentFrame.origin.y + contentFrame.size.height + Content_bottom_gap;
                                             [dic setValue:[NSValue valueWithCGRect:CGRectMake(0, 0, UIWidth, totalHeight)] forKey:@"cell-frame"];
                                         }
                                         
                                         dispatch_group_leave(dispatchGroup);
                                     }];
    });
}


#pragma mark - Property -
- (void)setCompletionBlock:(GetStytleCompletionBlock)completionBlock {
    objc_setAssociatedObject(self, @selector(completionBlock), completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (GetStytleCompletionBlock)completionBlock {
    return objc_getAssociatedObject(self, _cmd);
}


@end
