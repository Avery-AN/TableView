//
//  TrapezoidalCell+SelfManager.m
//  TableView
//
//  Created by Avery An on 2020/3/21.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "TrapezoidalCell+SelfManager.h"
#import "QAAttributedLabelConfig.h"
#import <objc/runtime.h>

@implementation TrapezoidalCell (SelfManager)

#pragma mark - GetInstanceProperty -
- (NSDictionary *)getInstanceProperty:(UIView *)instance {
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

    if ([[instance class] isMemberOfClass:[QATrapezoidalLabel class]]) {
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
    NSArray *contents = [dic valueForKey:@"trapezoidalTexts"];
    CGFloat maxWidth = bounds.size.width;
    
    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatchQueue, ^{
        [self.trapezoidalLabel getTextContentSizeWithLayer:layer
                                                   content:contents
                                                  maxWidth:maxWidth
                                           completionBlock:^(CGSize size, NSMutableAttributedString *attributedString) {
            if (!attributedString) {
                NSLog(@"获取attributedString失败");
            }
            [dic setValue:attributedString forKey:@"content-attributed"];
            
            CGFloat contentY = 0;
            if ([dic valueForKey:@"contentImageView-frame"]) {
                CGRect frame = [[dic valueForKey:@"contentImageView-frame"] CGRectValue];
                contentY = frame.origin.y + frame.size.height + TrapezoidalCell_ContentImageView_bottomControl_gap;
            }
            else {
                contentY = TrapezoidalCell_Avatar_top_gap + TrapezoidalCell_AvatarSize + TrapezoidalCell_Avatar_content_gap;
            }
            CGFloat contentHeight = size.height;
            CGRect content_frame = CGRectMake(TrapezoidalCell_Content_left, contentY, UIWidth - (TrapezoidalCell_Content_left+TrapezoidalCell_Content_right), contentHeight);
            [dic setValue:[NSValue valueWithCGRect:content_frame] forKey:@"content-frame"];

            CGFloat cellHeight = contentY + contentHeight+TrapezoidalCell_Content_bottom;
            CGRect cell_frame = CGRectMake(0, 0, UIWidth, cellHeight);
            [dic setValue:[NSValue valueWithCGRect:cell_frame] forKey:@"cell-frame"];
                                         
            dispatch_group_leave(dispatchGroup);
        }];
    });
}

@end
