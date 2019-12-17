//
//  QAImageProcesser.h
//  TableView
//
//  Created by Avery An on 2019/12/2.
//  Copyright © 2019 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QAImageBrowserManagerConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface QAImageProcesser : NSObject

+ (CGRect)caculateOriginImageSize:(UIImage *)image;

+ (UIImage *)decodeImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
