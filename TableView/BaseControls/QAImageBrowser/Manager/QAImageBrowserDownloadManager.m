//
//  QAImageBrowserDownloadManager.m
//  TableView
//
//  Created by Avery An on 2019/12/16.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "QAImageBrowserDownloadManager.h"

static int MaxDownloadingCounts = 3;

@interface QAImageBrowserDownloadManager ()
@property (nonatomic) NSMutableDictionary *allTokens;
@property (nonatomic) NSMutableDictionary *allFinishedBlocks;
@property (nonatomic) NSMutableDictionary *allFailedBlocks;
@property (nonatomic) NSMutableArray *allUrls;
@end

@implementation QAImageBrowserDownloadManager

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@"  %s",__func__);
    [self cleanAllDownloadings];
}
- (instancetype)init {
    if (self = [super init]) {
        self.allTokens = [NSMutableDictionary dictionaryWithCapacity:MaxDownloadingCounts];
        self.allFinishedBlocks = [NSMutableDictionary dictionaryWithCapacity:MaxDownloadingCounts];
        self.allFailedBlocks = [NSMutableDictionary dictionaryWithCapacity:MaxDownloadingCounts];
        self.allUrls = [NSMutableArray arrayWithCapacity:MaxDownloadingCounts];
    }
    return self;
}


#pragma mark - Public Methods -
/**
 通过imageUrl获取image
 */
- (void)queryImageWithUrl:(NSURL *)imageUrl
                 finished:(QAImageBrowserDownloadManagerFinishedBlock)finishedBlock
                   failed:(QAImageBrowserDownloadManagerFailedBlock)failedBlock {
    if (!imageUrl || imageUrl.absoluteString.length == 0) {
        if (failedBlock) {
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"imageUrl入参有误", @"info", nil];
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:errorInfo];
            failedBlock(imageUrl, error);
        }
    }
    else {
        if (![self.allTokens valueForKey:imageUrl.absoluteString]) {  // 开启新的请求(网络 or cache)
            [self getImageWithUrl:imageUrl finished:finishedBlock failed:failedBlock];
        }
        else {
            NSLog(@"正在加载。。。");
            
            /**
             此处会替换掉之前保存的block (也可以这么做:[allFinishedBlocks setObject:[array] forKey:key]])
             */
            if (finishedBlock) {
                [self.allFinishedBlocks setObject:finishedBlock forKey:imageUrl.absoluteString];
            }
            if (failedBlock) {
                [self.allFailedBlocks setObject:failedBlock forKey:imageUrl.absoluteString];
            }
        }
    }
}

- (void)downloadImages:(NSArray *)imageUrls {
    if (!imageUrls || imageUrls.count == 0) {
        return;
    }
    for (NSURL *imageUrl in imageUrls) {
        [self getImageWithUrl:imageUrl finished:nil failed:nil];
    }
}

/**
 删除所有正在下载的请求
 */
- (void)cleanAllDownloadings {
    for (NSString *imageUrlString in self.allTokens.allKeys) {
        [self cleanForUrlString:imageUrlString];
    }
}


#pragma mark - Private Methods -
- (void)getImageWithUrl:(NSURL *)imageUrl
               finished:(QAImageBrowserDownloadManagerFinishedBlock)finishedBlock
                 failed:(QAImageBrowserDownloadManagerFailedBlock)failedBlock {
    UIImage *image_memory = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imageUrl.absoluteString];
    if (!image_memory) {
        NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:imageUrl.absoluteString];
        if (!path) {
            // NSLog(@"不存在缓存、需要开启新的网络请求...");
            
            if (finishedBlock) {
                [self.allFinishedBlocks setObject:finishedBlock forKey:imageUrl.absoluteString];
            }
            if (failedBlock) {
                [self.allFailedBlocks setObject:failedBlock forKey:imageUrl.absoluteString];
            }
            
            if (self.allUrls.count >= MaxDownloadingCounts) {
                NSURL *firstKey = [self.allUrls firstObject];
                if ([firstKey.absoluteString isEqualToString:imageUrl.absoluteString]) {
                    firstKey = [self.allUrls objectAtIndex:1];
                }
                [self cleanForUrlString:firstKey.absoluteString];
            }
            SDWebImageDownloadToken *downLoadToken = [self downLoadImageWithUrl:imageUrl];
            [self.allUrls addObject:imageUrl.absoluteString];
            [self.allTokens setValue:downLoadToken forKey:imageUrl.absoluteString];
        }
        else {
            // NSLog(@"cache in disk");
            
            if (finishedBlock) {
                NSData *data = [NSData dataWithContentsOfFile:path];
                YYImage *yyImage = [YYImage imageWithData:data];
                finishedBlock(imageUrl, yyImage);
            }
        }
    }
    else {
        // NSLog(@"cache in memory");
        
        if (finishedBlock) {
            finishedBlock(imageUrl, image_memory);
        }
    }
}

- (SDWebImageDownloadToken *)downLoadImageWithUrl:(NSURL *)imageUrl {
    SDWebImageDownloaderOptions options = SDWebImageDownloaderLowPriority | SDWebImageDownloaderContinueInBackground;
    SDWebImageDownloadToken *downLoadToken = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:imageUrl options:options progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (error) {
            QAImageBrowserDownloadManagerFailedBlock failedBlock = [self.allFailedBlocks objectForKey:imageUrl.absoluteString];
            if (failedBlock) {
                failedBlock(imageUrl, error);
                [self cleanForUrlString:imageUrl.absoluteString];
            }
        }
        else {
            QAImageBrowserDownloadManagerFinishedBlock finishedBlock = [self.allFinishedBlocks objectForKey:imageUrl.absoluteString];
            if (finishedBlock) {
                finishedBlock(imageUrl, image);
                [self cleanForUrlString:imageUrl.absoluteString];
            }
        }
    }];
    
    return downLoadToken;
}
- (void)cleanForUrlString:(NSString *)imageUrlString {
    SDWebImageDownloadToken *downLoadToken = [self.allTokens objectForKey:imageUrlString];
    [downLoadToken cancel];
    QAImageBrowserDownloadManagerFailedBlock failedBlock = (QAImageBrowserDownloadManagerFailedBlock)[self.allFailedBlocks objectForKey:imageUrlString];
    if (failedBlock) {
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"下载被取消", @"info", nil];
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:errorInfo];
        failedBlock([NSURL URLWithString:imageUrlString], error);
    }
    [self.allFinishedBlocks removeObjectForKey:imageUrlString];
    [self.allFailedBlocks removeObjectForKey:imageUrlString];
    [self.allUrls removeObject:imageUrlString];
    [self.allTokens removeObjectForKey:imageUrlString];
}

@end
