//
//  QAImageBrowserView.m
//  Avery
//
//  Created by Avery on 2018/8/31.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QAImageBrowserView.h"
#import <SDWebImageManager.h>

@interface QAImageBrowserView () <UIScrollViewDelegate>
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation QAImageBrowserView

#pragma mark - Life Cycle -
- (void)dealloc {
    // NSLog(@"%s",__func__);
}
- (instancetype)init {
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}


#pragma mark - Private Methods -
- (void)setUp {
    self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    
    [self addSubview:self.scrollView];
    [self addSubview:self.activityIndicator];
    [self.scrollView addSubview:self.imageView];

    // 添加手势:
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerPan:)];
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    twoFingerTap.numberOfTouchesRequired = 2;
    
    [self addGestureRecognizer:singleTap];
    [self.imageView addGestureRecognizer:doubleTap];
    [self.imageView addGestureRecognizer:twoFingerTap];
    [self.imageView addGestureRecognizer:longGesture];

    UITapGestureRecognizer *singleTap_2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleTap_2];

    [singleTap requireGestureRecognizerToFail:doubleTap];   // 处理双击时不响应单击
    [singleTap_2 requireGestureRecognizerToFail:doubleTap]; // 处理双击时不响应单击
}
- (void)updateImageViewWithImage:(UIImage *)image {
    self.imageView.frame = [ImageProcesser caculateOriginImageSizeWith:image];
    self.imageView.image = image;
    [self.scrollView setZoomScale:1 animated:NO];
    
    CGFloat offsetX = (self.scrollView.bounds.size.width > self.scrollView.contentSize.width)?(self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.scrollView.bounds.size.height > self.scrollView.contentSize.height)?
    (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX,self.scrollView.contentSize.height * 0.5 + offsetY);
}
- (CGRect)zoomRectWithScale:(CGFloat)scale centerPoint:(CGPoint)center {
    CGRect zoomRect;

    zoomRect.size.height = [self.scrollView frame].size.height/scale;
    zoomRect.size.width = [self.scrollView frame].size.width/scale;

    zoomRect.origin.x = center.x - zoomRect.size.width/2;
    zoomRect.origin.y = center.y - zoomRect.size.height/2;

    return zoomRect;
}


#pragma mark - Actions -
- (void)handleSingleTap:(UITapGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateEnded: {
            if (self.gestureActionBlock) {
                self.gestureActionBlock(QAImageBrowserViewAction_SingleTap, self);
            }

            // 清除内存中的图片
            [[SDWebImageManager sharedManager].imageCache clearMemory];
        }
            break;
            
        default:{
            
        }
            break;
    }
}
- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    if (gesture.numberOfTapsRequired == 2) {
        if (self.scrollView.zoomScale == 1) {
            float newScale = [self.scrollView zoomScale]*2;
            CGRect zoomRect = [self zoomRectWithScale:newScale centerPoint:[gesture locationInView:gesture.view]];
            [self.scrollView zoomToRect:zoomRect animated:YES];
        }
        else {
            float newScale = [self.scrollView zoomScale]/2;
            CGRect zoomRect = [self zoomRectWithScale:newScale centerPoint:[gesture locationInView:gesture.view]];
            [self.scrollView zoomToRect:zoomRect animated:YES];
        }
    }
}
- (void)handleTwoFingerPan:(UITapGestureRecognizer *)gesture {
    CGFloat panScale = [self.scrollView zoomScale]/2;
    CGRect zoomRect = [self zoomRectWithScale:panScale centerPoint:[gesture locationInView:gesture.view]];
    [self.scrollView zoomToRect:zoomRect animated:YES];
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture {
    switch (longPressGesture.state) {
            case UIGestureRecognizerStateEnded: {
                if (self.gestureActionBlock) {
                    self.gestureActionBlock(QAImageBrowserViewAction_LongPress, self);
                }
            }
            break;
            
            default:{
                
            }
            break;
    }
}


#pragma mark - Public Method -
- (void)showImageWithUrl:(NSURL * _Nonnull)imageUrl contentModel:(UIViewContentMode)contentModel {
    if (!imageUrl || imageUrl.absoluteString.length == 0) {
        return;
    }
    
    self.imageView.contentMode = contentModel;
    
    [self.activityIndicator startAnimating];
    SDWebImageOptions opt = SDWebImageRetryFailed | SDWebImageAvoidAutoSetImage;
    [self.imageView sd_setImageWithURL:imageUrl
                      placeholderImage:nil
                               options:opt
                             completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self.activityIndicator stopAnimating];

        if (!error) {
            [self updateImageViewWithImage:image];
        }
        else {
            NSLog(@"%s-error: %@", __func__, error);
            UIImage *defaultImage = [UIImage imageNamed:@"默认图"];
            [self updateImageViewWithImage:defaultImage];
        }
    }];
}
- (void)showImage:(UIImage * _Nonnull)image contentModel:(UIViewContentMode)contentModel {
    self.imageView.contentMode = contentModel;
    [self updateImageViewWithImage:image];
}


#pragma mark - UIScrollView Delegate -
// 返回要缩放的图片
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

// 让图片保持在屏幕中央，防止图片放大时，位置出现跑偏
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (self.scrollView.bounds.size.width > self.scrollView.contentSize.width)?(self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.scrollView.bounds.size.height > self.scrollView.contentSize.height)?
    (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX,self.scrollView.contentSize.height * 0.5 + offsetY);
}

// 重新确定缩放完后的缩放倍数
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}


#pragma mark - Property -
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 3;
        
        if (@available(iOS 11.0, *)) {
            if ([_scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
                _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        } else {
            // Fallback on earlier versions
        }
    }
    return _scrollView;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}
- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicator.center = self.center;
    }
    return _activityIndicator;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
