//
//  QAImageFileManager.h
//  TestProject
//
//  Created by Avery An on 2019/11/12.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/mman.h>
#import "QAImageFormat.h"

NS_ASSUME_NONNULL_BEGIN

@interface QAImageFileManager : NSObject

/**
 缓存原始大小的image
 */
- (void)processCache:(NSString * _Nonnull)fileSavedPath
        imageFormart:(QAImageFormat * _Nonnull)imageFormart
               image:(UIImage * _Nonnull)image;

/**
 缓存固定宽高比的image
 */
- (void)processFixedSizeCache:(NSString * _Nonnull)fileSavedPath
                 imageFormart:(QAImageFormat * _Nonnull)imageFormart
                        image:(UIImage * _Nonnull)image;

/**
 获取已缓存到disk的image
 */
- (UIImage *)processRequest:(NSString * _Nonnull)fileSavedPath
               imageFormart:(QAImageFormat * _Nullable)imageFormart;

- (void)clearTheBattlefield;

@end

NS_ASSUME_NONNULL_END
