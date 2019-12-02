//
//  QAImageBrowserView.h
//  Avery
//
//  Created by Avery on 2018/8/31.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ScreenWidth     [UIScreen mainScreen].bounds.size.width
#define ScreenHeight    [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSUInteger, QAImageBrowserViewAction) {
    QAImageBrowserViewAction_SingleTap = 1,
    QAImageBrowserViewAction_DoubleTap,
    QAImageBrowserViewAction_TwoFingerPan,
    QAImageBrowserViewAction_LongPress
};

@interface QAImageBrowserView : UIView

@property (nonatomic) UIScrollView * _Nonnull scrollView;
@property (nonatomic) UIImageView * _Nonnull imageView;
@property (nonatomic, copy) void(^ _Nullable gestureActionBlock) (QAImageBrowserViewAction action, QAImageBrowserView * _Nullable imageBrowserView);

- (void)showImageWithUrl:(NSURL * _Nonnull)imageUrl contentModel:(UIViewContentMode)contentModel;

@end
