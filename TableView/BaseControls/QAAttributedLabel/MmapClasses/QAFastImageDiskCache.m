//
//  QAFastImageDiskCache.m
//  TestProject
//
//  Created by Avery An on 2019/11/11.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "QAFastImageDiskCache.h"

@interface QAFastImageDiskCache ()
@property (nonatomic) NSMutableDictionary *formatDic;
@property (nonatomic) NSMutableDictionary *requestBlocks;
@property (nonatomic, copy) QAImageCacheCompletionBlock cacheCompletionBlock;
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) dispatch_semaphore_t semaphore;
@end

@implementation QAFastImageDiskCache

#pragma mark - Life Cycle -
- (instancetype)init {
    if (self = [super init]) {
        self.formatDic = [NSMutableDictionary dictionary];
        self.requestBlocks = [NSMutableDictionary dictionary];
        self.queue = dispatch_queue_create("Avery.QAFastImageDiskCacheManager", DISPATCH_QUEUE_CONCURRENT);
        self.semaphore = dispatch_semaphore_create(0);
    }
    return self;
}
//+ (instancetype)sharedImageCache {
//    static dispatch_once_t onceToken;
//    static QAFastImageDiskCache *__imageCache = nil;
//    dispatch_once(&onceToken, ^{
//        __imageCache = [[[self class] alloc] init];
//        __imageCache.formatDic = [NSMutableDictionary dictionary];
//        __imageCache.requestBlocks = [NSMutableDictionary dictionary];
//        __imageCache.queue = dispatch_queue_create("Avery.QAFastImageDiskCacheManager", DISPATCH_QUEUE_CONCURRENT);
//        __imageCache.semaphore = dispatch_semaphore_create(0);
//    });
//
//    return __imageCache;
//}


#pragma mark - Public Methods -
- (void)clear {
    [self.formatDic removeAllObjects];
    [self.requestBlocks removeAllObjects];
}
- (void)cacheImage:(UIImage * _Nonnull)image
        identifier:(NSString * _Nonnull)identifier
       formatStyle:(QAImageFormatStyle)formatStyle {
    [self cacheImage:image identifier:identifier formatStyle:formatStyle completion:nil];
}
- (void)cacheFixedSizeImage:(UIImage * _Nonnull)image
                 identifier:(NSString * _Nonnull)identifier
                formatStyle:(QAImageFormatStyle)formatStyle {
    [self cacheFixedSizeImage:image identifier:identifier formatStyle:formatStyle completion:nil];
}
- (void)cacheImage:(UIImage * _Nonnull)image
        identifier:(NSString * _Nonnull)identifier
       formatStyle:(QAImageFormatStyle)formatStyle
        completion:(QAImageCacheCompletionBlock _Nullable)completion {
    @autoreleasepool {
        self.cacheCompletionBlock = completion;
        
        dispatch_async(self.queue, ^{
            NSString *fileSavedPath = nil;
            QAImageFormat *format = nil;
            BOOL success = [self baseinfoProcess:image identifier:identifier formatStyle:formatStyle fileSavedPath:&fileSavedPath format:&format];
            if (success == NO) {
                return;
            }
            
            QAImageFileManager *fileManager = [QAImageFileManager new];
            [fileManager processCache:fileSavedPath
                         imageFormart:format
                                image:image];
            if (self.cacheCompletionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.cacheCompletionBlock();
                });
            }
        });
    }
}
- (void)cacheFixedSizeImage:(UIImage * _Nonnull)image
                 identifier:(NSString * _Nonnull)identifier
                formatStyle:(QAImageFormatStyle)formatStyle
                 completion:(QAImageCacheCompletionBlock _Nullable)completion {
    @autoreleasepool {
        self.cacheCompletionBlock = completion;
        
        dispatch_async(self.queue, ^{
            NSString *fileSavedPath = nil;
            QAImageFormat *format = nil;
            BOOL success = [self baseinfoProcess:image identifier:identifier formatStyle:formatStyle fileSavedPath:&fileSavedPath format:&format];
            if (success == NO) {
                return;
            }
            
            QAImageFileManager *fileManager = [QAImageFileManager new];
            [fileManager processFixedSizeCache:fileSavedPath
                                  imageFormart:format
                                         image:image];
            if (self.cacheCompletionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.cacheCompletionBlock();
                });
            }
        });
    }
}
- (void)requestDiskCachedImage:(NSString * _Nonnull)identifier
                    completion:(QAImageRequestCompletionBlock _Nullable)completion
                    failed:(QAImageRequestFailedBlock _Nullable)failed {
    @autoreleasepool {
        [self.requestBlocks setObject:completion forKey:identifier];

        NSString *key = [identifier md5Hash];
        NSString *fileSavedPath = [QAImageCachePath getImageCachedFilePath:key];

        __weak typeof(self) weakSelf = self;
        [self getFormatWithKey:key
                    completion:^(QAImageFormat *format) {
            __strong typeof(weakSelf) strongSelf = weakSelf;

            if (!format) {
                if (failed) {
                    NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"获取缓存失败", @"info", nil];
                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:errorInfo];
                    failed(identifier, error);
                }
                return;
            }
            
            QAImageFileManager *fileManager = [QAImageFileManager new];
            UIImage *image = [fileManager processRequest:fileSavedPath
                                             imageFormart:format];
            QAImageRequestCompletionBlock completionBlock = [strongSelf.requestBlocks objectForKey:identifier];
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CATransaction setCompletionBlock:^{
                        NSLog(@" 清理垃圾......");
                        [fileManager clearTheBattlefield];
                    }];

                    completionBlock(image);
                    [self.requestBlocks removeObjectForKey:identifier];
                });
            }
            else {
                [fileManager clearTheBattlefield];
            }
        }];
    }
}


#pragma mark - Private Methods -
- (BOOL)baseinfoProcess:(UIImage *)image
             identifier:(NSString * _Nonnull)identifier
            formatStyle:(QAImageFormatStyle)formatStyle
          fileSavedPath:(NSString * __strong *)fileSavedPath
                 format:(QAImageFormat * __strong *)format {
    NSString *key = [identifier md5Hash];
    NSString *fileSavedPath_tmp = [QAImageCachePath getImageCachedFilePath:key];
    if (!fileSavedPath_tmp) {
        return NO;
    }
    *fileSavedPath = fileSavedPath_tmp;

    QAImageFormat *format_tmp = [self.formatDic valueForKey:key];
    if (!format_tmp) {
        format_tmp = [QAImageFormat new];
        [self setFormat:format_tmp key:key];
    }
    *format = format_tmp;
    (*format).formatStyle = formatStyle;
    (*format).imageSize = image.size;
    
    return YES;
}
- (void)getFormatWithKey:(NSString * _Nonnull)key completion:(void(^)(QAImageFormat *format))completion {
    dispatch_sync(self.queue, ^{
        QAImageFormat *format = [self.formatDic valueForKey:key];
        if (completion) {
            completion(format);
        }
    });
}
- (void)setFormat:(QAImageFormat * _Nonnull)format key:(NSString * _Nonnull)key {
    dispatch_barrier_async(self.queue, ^{
        [self.formatDic setObject:format forKey:key];
    });
}

@end
