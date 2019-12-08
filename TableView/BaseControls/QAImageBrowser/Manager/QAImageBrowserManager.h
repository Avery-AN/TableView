//
//  QAImageBrowserManager.h
//  Avery
//
//  Created by Avery on 2018/8/31.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QAImageBrowserView.h"

@interface QAImageBrowserManager : NSObject

/**
 本DEMO中使用了 SDWebImageManager & YYImage
 */


/**
 显示给定的image  (cell中显示的缩略图和此处要准备浏览的大图最好要保持宽高比一致)
 @param tapedObject 点中的cell里的视图控件
 @param images 保存的是NSDictionary类型的数据、dic中有3个key: url & frame & image、
               分别表示为需要显示的image的url和cell中显示该image的imageView的frame以及需要显示的image对象
               (若image和url同时存在则优先显示image)
 */
- (void)showImageWithTapedObject:(id _Nonnull)tapedObject
                          images:(NSArray * _Nonnull)images;

@end
