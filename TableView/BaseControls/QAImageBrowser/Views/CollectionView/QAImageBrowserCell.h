//
//  QAImageBrowserCell.h
//  TableView
//
//  Created by Avery An on 2019/12/10.
//  Copyright © 2019 Avery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYImage/YYImage.h>
#import "ImageProcesser.h"

typedef NS_ENUM(NSUInteger, QAImageBrowserViewAction) {
    QAImageBrowserViewAction_SingleTap = 1,
    QAImageBrowserViewAction_DoubleTap,
    QAImageBrowserViewAction_TwoFingerPan,
    QAImageBrowserViewAction_LongPress
};

NS_ASSUME_NONNULL_BEGIN

@interface QAImageBrowserCell : UICollectionViewCell

@property (nonatomic) UIScrollView * _Nonnull scrollView;
@property (nonatomic) YYAnimatedImageView * _Nonnull imageView;
@property (nonatomic, copy) void(^ _Nullable gestureActionBlock) (QAImageBrowserViewAction action, QAImageBrowserCell * _Nullable imageBrowserCell);

- (void)configContent:(NSDictionary * _Nonnull)dic
         defaultImage:(UIImage * _Nullable)defaultImage
          contentMode:(UIViewContentMode)contentMode;

@end

NS_ASSUME_NONNULL_END
