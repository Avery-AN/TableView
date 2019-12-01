//
//  CurrentViewController.h
//  ImageEncryption
//
//  Created by Avery An on 2019/5/8.
//  Copyright © 2019 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CurrentViewController : NSObject

+ (UIViewController *)getCurrentViewController;

+ (UIViewController *)getCurrentViewControllerWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
