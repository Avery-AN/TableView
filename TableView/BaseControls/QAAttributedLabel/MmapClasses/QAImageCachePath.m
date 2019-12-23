//
//  QAImageCachePath.m
//  TestProject
//
//  Created by Avery An on 2019/11/12.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "QAImageCachePath.h"

static NSString *QAFilesPath = @"QAAllFilesPath";
static NSString *QAImageCache = @"QACachedImages";
static NSString *QAImageFormatCache = @"QACachedImageFormats";

@implementation QAImageCachePath

#pragma mark - Public Methods -
+ (NSString *)getImageCachedFilePath:(NSString * _Nonnull)fileName {
    NSString *imageCachedPath = [self createImageCachePath:QAImageCache];  // 创建图片保存路径
    NSString *fileSavedPath = [imageCachedPath stringByAppendingPathComponent:fileName];
    
    BOOL exists;
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileSavedPath isDirectory:&exists]) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setValue:NSFileProtectionNone forKeyPath:NSFileProtectionKey];
        [[NSFileManager defaultManager] createFileAtPath:fileSavedPath contents:nil attributes:attributes];
    }
    
    return fileSavedPath;
}
+ (NSString *)getImageFormatCachedFilePath:(NSString * _Nonnull)fileName {
    NSString *imageCachedPath = [self createImageCachePath:QAImageFormatCache];  // 创建图片保存路径
    NSString *fileSavedPath = [imageCachedPath stringByAppendingPathComponent:fileName];
    
    BOOL exists;
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileSavedPath isDirectory:&exists]) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setValue:NSFileProtectionNone forKeyPath:NSFileProtectionKey];
        [[NSFileManager defaultManager] createFileAtPath:fileSavedPath contents:nil attributes:attributes];
    }
    
    return fileSavedPath;
}


#pragma mark - Private Methods -
+ (NSString *)createImageCachePath:(NSString *)pathName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];

    NSString *plistPath = [NSString stringWithFormat:@"%@/%@/%@", [pathURL path], QAFilesPath, pathName];
    BOOL exists;
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:&exists]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return plistPath;
}

@end
