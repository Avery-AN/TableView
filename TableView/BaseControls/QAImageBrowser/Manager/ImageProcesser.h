//
//  ImageProcesser.h
//  TableView
//
//  Created by Avery An on 2019/12/2.
//  Copyright © 2019 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ScreenWidth     [UIScreen mainScreen].bounds.size.width
#define ScreenHeight    [UIScreen mainScreen].bounds.size.height

NS_ASSUME_NONNULL_BEGIN

@interface ImageProcesser : NSObject

+ (CGRect)caculateOriginImageSizeWith:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
