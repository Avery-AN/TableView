//
//  RichTextCell+SelfManager.h
//  TestProject
//
//  Created by Avery An on 2019/8/28.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "RichTextCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface RichTextCell (SelfManager) <QAAttributedLabelProperty>

- (void)getStyleWithQueue:(dispatch_queue_t)dispatchQueue
            dispatchGroup:(dispatch_group_t)dispatchGroup
                      dic:(NSMutableDictionary *)dic
                   bounds:(CGRect)bounds
                    layer:(QAAttributedLayer *)layer;

@end

NS_ASSUME_NONNULL_END
