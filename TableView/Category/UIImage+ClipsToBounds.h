//
//  UIImage+ClipsToBounds.h
//  TestProject
//
//  Created by Avery An on 2019/9/9.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ClipsToBounds)

- (UIImage *)clipsToBoundsWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
