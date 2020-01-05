//
//  QAImageBrowserDownloadManager.h
//  TableView
//
//  Created by Avery An on 2019/12/16.
//  Copyright © 2019 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QAImageBrowserManagerConfig.h"


typedef void (^QAImageBrowserDownloadManagerFinishedBlock)(NSURL * _Nonnull image_url, UIImage * _Nullable image_completed);
typedef void (^QAImageBrowserDownloadManagerFailedBlock)(NSURL * _Nonnull image_url, NSError * _Nullable error);


NS_ASSUME_NONNULL_BEGIN

@interface QAImageBrowserDownloadManager : NSObject

/**
 通过imageUrl获取image
 */
- (void)queryImageWithUrl:(NSURL *)imageUrl
                 finished:(QAImageBrowserDownloadManagerFinishedBlock)finishedBlock
                   failed:(QAImageBrowserDownloadManagerFailedBlock)failedBlock;

- (void)downloadImages:(NSArray *)imageUrls;

/**
 删除所有正在下载以及尚未开始下载的请求
 */
- (void)cleanAllDownloadings;

@end

NS_ASSUME_NONNULL_END
