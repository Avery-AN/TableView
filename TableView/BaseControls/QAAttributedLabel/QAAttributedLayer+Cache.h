//
//  QAAttributedLayer+Cache.h
//  TableView
//
//  Created by Avery An on 2019/12/22.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "QAAttributedLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface QAAttributedLayer (Cache)

- (void)cacheImage:(UIImage * _Nonnull)image
    withIdentifier:(NSMutableAttributedString * _Nonnull)identifier;

- (void)getCacheWithIdentifier:(NSMutableAttributedString * _Nonnull)identifier
                      finished:(void (^)(NSMutableAttributedString * _Nonnull identifier, UIImage * _Nullable image))finishedBlock;

@end

NS_ASSUME_NONNULL_END
