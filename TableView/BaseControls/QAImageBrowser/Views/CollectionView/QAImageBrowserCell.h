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
#import "QAImageBrowserManagerConfig.h"

typedef NS_ENUM(NSUInteger, QAImageBrowserViewAction) {
    QAImageBrowserViewAction_SingleTap = 1,
    QAImageBrowserViewAction_DoubleTap,
    QAImageBrowserViewAction_TwoFingerPan,
    QAImageBrowserViewAction_LongPress
};

NS_ASSUME_NONNULL_BEGIN

@interface QAImageBrowserCell : UICollectionViewCell

@property (nonatomic) UIScrollView * _Nullable scrollView;
@property (nonatomic) YYAnimatedImageView * _Nullable imageView;
@property (nonatomic, unsafe_unretained) YYAnimatedImageView * _Nullable currentShowImageView;
@property (nonatomic, copy) void(^ _Nullable gestureActionBlock) (QAImageBrowserViewAction action, QAImageBrowserCell * _Nullable imageBrowserCell);

- (void)configImageView:(YYAnimatedImageView *)imageView
           defaultImage:(UIImage * _Nullable)defaultImage;

- (void)reprepareShowImageView;

- (void)configContent:(NSDictionary * _Nonnull)dic
         defaultImage:(UIImage * _Nullable)defaultImage
          contentMode:(UIViewContentMode)contentMode;

- (void)clearALLGesturesInView:(UIView * _Nonnull)view;

@end

NS_ASSUME_NONNULL_END
