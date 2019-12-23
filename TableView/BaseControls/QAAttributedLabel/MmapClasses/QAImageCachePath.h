//
//  QAImageCachePath.h
//  TestProject
//
//  Created by Avery An on 2019/11/12.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QAImageCachePath : NSObject

+ (NSString *)getImageCachedFilePath:(NSString * _Nonnull)fileName;

+ (NSString *)getImageFormatCachedFilePath:(NSString * _Nonnull)fileName;

@end

NS_ASSUME_NONNULL_END
