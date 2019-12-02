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

- (void)showImageWithTapedObject:(id _Nonnull)tapedObject
                          images:(NSArray * _Nonnull)images
                 currentPosition:(NSInteger)currentPosition;

@end
