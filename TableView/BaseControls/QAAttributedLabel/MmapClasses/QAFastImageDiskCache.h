//
//  QAFastImageDiskCache.h
//  TestProject
//
//  Created by Avery An on 2019/11/11.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QAFastImageDiskCacheConfig.h"

typedef void (^QAImageCacheCompletionBlock)(void);
typedef void (^QAImageRequestCompletionBlock)(UIImage * _Nullable image);
typedef void (^QAImageRequestFailedBlock)(NSString * _Nonnull identifierString, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface QAFastImageDiskCache : NSObject

//+ (instancetype)sharedImageCache;

- (void)cacheImage:(UIImage * _Nonnull)image
        identifier:(NSString * _Nonnull)identifier
       formatStyle:(QAImageFormatStyle)formatStyle;

- (void)cacheImage:(UIImage * _Nonnull)image
        identifier:(NSString * _Nonnull)identifier
       formatStyle:(QAImageFormatStyle)formatStyle
        completion:(QAImageCacheCompletionBlock _Nullable)completion;

- (void)cacheFixedSizeImage:(UIImage * _Nonnull)image
                 identifier:(NSString * _Nonnull)identifier
                formatStyle:(QAImageFormatStyle)formatStyle;

- (void)cacheFixedSizeImage:(UIImage * _Nonnull)image
                 identifier:(NSString * _Nonnull)identifier
                formatStyle:(QAImageFormatStyle)formatStyle
                 completion:(QAImageCacheCompletionBlock _Nullable)completion;

- (void)requestDiskCachedImage:(NSString * _Nonnull)identifier
                    completion:(QAImageRequestCompletionBlock _Nullable)completion
                        failed:(QAImageRequestFailedBlock _Nullable)failed;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
