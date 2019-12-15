//
//  QAImageBrowserManager.h
//  Avery
//
//  Created by Avery on 2018/8/31.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QAImageBrowserCell.h"
#import "QAImageBrowserManagerConfig.h"

/**
 本DEMO中使用了 SDWebImageManager & YYImage
 */



/**
 @param index 退出ImageBrowser时、正在展示的imageView的位置 (是九宫格图片中的第几个)
 @param imageView 退出ImageBrowser时、正在展示的imageView
 */
typedef void (^QAImageBrowserFinishedBlock)(NSInteger index, YYAnimatedImageView * _Nonnull imageView);

@interface QAImageBrowserManager : NSObject

/**
 浏览给定的image或者imageUrl的大图  (cell中显示的缩略图和此处要准备浏览的大图最好要保持宽高比一致)
 @param tapedImageView 点中的cell里的视图控件
 @param images 保存的是NSDictionary类型的数据(保存的cell顺序为:左至右、上至下)、dic中有3个key: url & frame & image、
               分别表示为需要显示的image的url和cell中显示该image的imageView的frame以及需要显示的image对象
               (若image和url同时存在则优先显示image)
 */
- (void)showImageWithTapedObject:(UIImageView * _Nonnull)tapedImageView
                          images:(NSArray * _Nonnull)images
                          finished:(QAImageBrowserFinishedBlock _Nullable)finishedBlock;

@end
