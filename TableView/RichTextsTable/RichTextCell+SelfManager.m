//
//  RichTextCell+SelfManager.m
//  TestProject
//
//  Created by Avery An on 2019/8/28.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "RichTextCell+SelfManager.h"
#import "QAAttributedLabelConfig.h"
#import <objc/runtime.h>

@implementation RichTextCell (SelfManager)

#pragma mark - GetInstanceProperty -
- (NSDictionary *)getInstanceProperty:(QARichTextLabel *)instance {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *dic_base = [NSMutableDictionary dictionary];
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([QAAttributedLabel class], &count);
    for (int i = 0; i < count; i++) {
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
    
    if ([[instance class] isMemberOfClass:[QARichTextLabel class]]) {
        NSMutableDictionary *dic_current = [NSMutableDictionary dictionary];
        count = 0;
        properties = class_copyPropertyList([instance class], &count);
        for (int i = 0; i < count; i++) {
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
                                             NSInteger contentTop = Avatar_top_gap + AvatarSize + Avatar_bottomControl_gap;
                                             [dic setValue:[NSValue valueWithCGRect:CGRectMake(Avatar_left_gap, contentTop, maxWidth, size.height)] forKey:@"content-frame"];
                                             
                                             CGFloat totalHeight = contentTop + size.height + Content_bottom_gap;
                                             [dic setValue:[NSValue valueWithCGRect:CGRectMake(0, 0, UIWidth, totalHeight)] forKey:@"cell-frame"];
                                         }
                                         
                                         dispatch_group_leave(dispatchGroup);
                                     }];
    });
}

@end
