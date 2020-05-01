//
//  QAImageBrowserViewController.h
//  TableView
//
//  Created by Avery An on 2020/4/30.
//  Copyright © 2020 Avery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QAImageBrowserCell.h"
#import "QAImageBrowserManagerConfig.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @param index 退出ImageBrowser时、正在展示的imageView的位置 (是九宫格图片中的第几个)
 @param imageView 退出ImageBrowser时、正在展示的imageView
 */
typedef void (^QAImageBrowserFinishedBlock)(NSInteger index, YYAnimatedImageView * _Nonnull imageView);

@interface QAImageBrowserViewController : UIViewController

- (void)showImageWithTapedObject:(UIImageView * _Nonnull)tapedImageView
                          images:(NSArray * _Nonnull)images
                        finished:(QAImageBrowserFinishedBlock _Nullable)finishedBlock;

@end

NS_ASSUME_NONNULL_END
