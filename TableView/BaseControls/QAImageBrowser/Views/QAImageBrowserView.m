//
//  QAImageBrowserView.m
//  Avery
//
//  Created by Avery on 2018/8/31.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QAImageBrowserView.h"

@interface QAImageBrowserView () <UIScrollViewDelegate>
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation QAImageBrowserView

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@"%s",__func__);
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
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    twoFingerTap.numberOfTouchesRequired = 2;
    [self.imageView addGestureRecognizer:singleTap];
    [self.imageView addGestureRecognizer:doubleTap];
    [self.imageView addGestureRecognizer:twoFingerTap];
    [self.imageView addGestureRecognizer:longGesture];
    [self.imageView addGestureRecognizer:panGestureRecognizer];
//    [self addGestureRecognizer:singleTap];
//    [self addGestureRecognizer:doubleTap];
//    [self addGestureRecognizer:twoFingerTap];
//    [self addGestureRecognizer:longGesture];
//    [self addGestureRecognizer:panGestureRecognizer];

    UITapGestureRecognizer *singleTap_2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleTap_2];

    [singleTap requireGestureRecognizerToFail:doubleTap]; // 处理双击时不响应单击
    [singleTap_2 requireGestureRecognizerToFail:doubleTap]; // 处理双击时不响应单击
}
- (CGRect)caculateOriginImageSizeWith:(UIImage *)image {
    CGFloat originImageHeight = [self processImage:image withTargetWidth:ScreenWidth].size.height;
    CGRect frame = CGRectMake(0, (ScreenHeight-originImageHeight)*0.5, ScreenWidth, originImageHeight);
    
    return frame;
}
- (UIImage *)processImage:(UIImage *)sourceImage
          withTargetWidth:(CGFloat)targetWidth {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    CGFloat targetHeight = imageHeight / (imageWidth / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO) {
        CGFloat widthFactor = targetWidth / imageWidth;
        CGFloat heightFactor = targetHeight / imageHeight;
        if(widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        }
        else {
            scaleFactor = heightFactor;
        }
        scaledWidth = imageWidth * scaleFactor;
        scaledHeight = imageHeight * scaleFactor;
        
        if(widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if(widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (void)processWithImage:(UIImage *)image {
    self.imageView.frame = [self caculateOriginImageSizeWith:image];
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
    if (self.gestureActionBlock) {
        self.gestureActionBlock(QAImageBrowserViewAction_SingleTap, self);
    }
    
    // 清除内存中的图片
    [[SDWebImageManager sharedManager].imageCache clearMemory];
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
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (self.gestureActionBlock) {
        self.gestureActionBlock(QAImageBrowserViewAction_LongPress, self);
    }
}
- (void)handlePan:(UIPanGestureRecognizer *)panGesture {
    if (self.scrollView.isDragging) {
        return;
    }
    
    CGPoint transPoint = [panGesture translationInView:self];
    CGPoint velocity = [panGesture velocityInView:self];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            
        }
        break;
            
        case UIGestureRecognizerStateChanged: {
            [self.scrollView setScrollEnabled:NO];
            
            double alpha = 1 - fabs(transPoint.y) / self.frame.size.height;
            alpha = MAX(alpha, 0);
            double scale = MAX(alpha, 0.5);
            CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(transPoint.x/scale, transPoint.y/scale);
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
            if (self.panGestureActionBlock) {
                self.panGestureActionBlock(translationTransform, scaleTransform, alpha, self);
            }
        }
        break;
            
        case UIGestureRecognizerStateEnded: {
            [self.scrollView setScrollEnabled:YES];
            
            if (fabs(transPoint.y) > 220 || fabs(velocity.y) > 500) {
                if (self.panGestureDoneActionBlock) {
                    self.panGestureDoneActionBlock(YES, self);
                }
            }
            else {
                if (self.panGestureDoneActionBlock) {  // 返回到初始状态
                    self.panGestureDoneActionBlock(NO, self);
                }
            }
        }
        break;
            
        case UIGestureRecognizerStateCancelled: {
            [self.scrollView setScrollEnabled:YES];
            if (self.panGestureDoneActionBlock) {  // 返回到初始状态
                self.panGestureDoneActionBlock(NO, self);
            }
        }
        break;
        
        default:{
            
        }
        break;
    }
}


#pragma mark - Public Method -
- (void)showImageWithImageUrl:(NSURL *)imageUrl {
    [self.activityIndicator startAnimating];
    [self.imageView sd_setImageWithURL:imageUrl
                      placeholderImage:[UIImage imageNamed:@"默认图"]
                               options:SDWebImageHighPriority
                             completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                 [self.activityIndicator stopAnimating];
                                 if (!error) {
                                     [self processWithImage:image];
                                 }
                                 else {
                                     NSLog(@" error : %@",error);
                                     UIImage *defaultImage = [UIImage imageNamed:@"默认图"];
                                     [self processWithImage:defaultImage];
                                 }
                             }];
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
        _scrollView.alwaysBounceHorizontal = YES;
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
        _imageView.backgroundColor = [UIColor greenColor];
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
