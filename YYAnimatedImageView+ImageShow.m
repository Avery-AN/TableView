//
//  YYAnimatedImageView.m
//  TableView
//
//  Created by Avery An on 2022/2/5.
//  Copyright © 2022 Avery. All rights reserved.
//

#import "YYAnimatedImageView+ImageShow.h"
#import <objc/message.h>

@implementation YYAnimatedImageView (ImageShow)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method displayLayerMethod = class_getInstanceMethod(self, @selector(displayLayer:));
        Method displayLayerNewMethod = class_getInstanceMethod(self, @selector(displayLayerNew:));
        method_exchangeImplementations(displayLayerMethod, displayLayerNewMethod);
    });
}
 
- (void)displayLayerNew:(CALayer *)layer {
    Ivar imageIvar = class_getInstanceVariable([self class], "_curFrame");
    UIImage *image = object_getIvar(self, imageIvar);
    if (image) {
        layer.contents = (__bridge  id)image.CGImage;
    }
    else {
        if (@available(iOS 14.0,*)) {
            [super displayLayer:layer];
        }
    }
}

@end
