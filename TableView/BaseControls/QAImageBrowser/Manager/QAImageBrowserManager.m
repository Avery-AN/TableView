//
//  QAImageBrowserManager.m
//  Avery
//
//  Created by Avery on 2018/8/31.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QAImageBrowserManager.h"
#import "TestView.h"

static int DefaultTag = 10;

@interface QAImageBrowserManager () <UIScrollViewDelegate>
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *blackBackgroundView;
@property (nonatomic, unsafe_unretained) NSArray *images;
@property (nonatomic, assign) NSInteger currentPosition;
@property (nonatomic) id tapedObject;
@property (nonatomic, assign) CGFloat rectOffsetX;
@property (nonatomic, assign) CGFloat rectOffsetY;
@end

@implementation QAImageBrowserManager

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@"  %s",__func__);
}


#pragma mark - Public Methods -
- (void)showImageWithTapedObject:(id _Nonnull)tapedObject
                          images:(NSArray * _Nonnull)images
                 currentPosition:(NSInteger)currentPosition {
    if (!tapedObject || !images || ![images isKindOfClass:[NSArray class]] || images.count == 0) {
        return;
    }
    
    self.tapedObject = tapedObject;
    CGRect newRect = [self getTapedImageFrame];
    self.images = images;
    self.currentPosition = currentPosition;
    [self createImageBrowserView];
    [self showImageBrowserViewWithNewFrame:newRect];
}


#pragma mark - Private Methods -
- (CGRect)getTapedImageFrame {
    UIImageView *imageView = self.tapedObject;
    UIImage *image = imageView.image;
    
    CGRect rect = [self caculateOriginImageSizeWith:image];
    return rect;
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
- (void)createImageBrowserView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelStatusBar + 10.;
    if (!self.blackBackgroundView) {
        self.blackBackgroundView = [[UIView alloc] init];
        self.blackBackgroundView.backgroundColor = [UIColor blackColor];
        self.blackBackgroundView.center = window.center;
        self.blackBackgroundView.bounds = window.bounds;
    }
    
    self.blackBackgroundView.alpha = 0.1;
    [window addSubview:self.blackBackgroundView];
    [window addSubview:self.scrollView];
}
- (void)showImageBrowserViewWithNewFrame:(CGRect)newFrame {
    UIImageView *tapedImageView = self.tapedObject;
    tapedImageView.hidden = YES;
    
    CGRect srcRect = tapedImageView.frame;
    UIView *tapedObjectSuperView = tapedImageView.superview;
    CGRect rect = [tapedImageView convertRect:tapedObjectSuperView.frame toView:self.blackBackgroundView];
    self.rectOffsetX = rect.origin.x - srcRect.origin.x;
    self.rectOffsetY = rect.origin.y - srcRect.origin.y;
    UIImageView *currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, srcRect.size.width, srcRect.size.height)];
    currentImageView.image = tapedImageView.image;
    [self.blackBackgroundView addSubview:currentImageView];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.blackBackgroundView.alpha = 1;
                         currentImageView.frame = newFrame;
    } completion:^(BOOL finished) {
        [self processImagesBrowser];
        [currentImageView removeFromSuperview];
        tapedImageView.hidden = NO;
    }];
}
- (void)processImagesBrowser {
    CGRect blackBackgroundViewBounds = self.blackBackgroundView.bounds;
    CGFloat dx = 5;
    CGFloat itemWidth = blackBackgroundViewBounds.size.width + dx;
    self.scrollView.frame = CGRectMake(0, 0, itemWidth, blackBackgroundViewBounds.size.height);

    for (int i = 0; i < self.images.count; i++) {
        NSDictionary *imageInfo = [self.images objectAtIndex:i];
        NSString *imageUrl = [imageInfo valueForKey:@"url"];
        if (!imageUrl || ![imageUrl isKindOfClass:[NSString class]] || imageUrl.length == 0) {
            return;
        }

        QAImageBrowserView *imageBrowserView = [[QAImageBrowserView alloc] init];
        imageBrowserView.tag = i + DefaultTag;
        __weak typeof(self) weakself = self;
        imageBrowserView.gestureActionBlock = ^(QAImageBrowserViewAction action, QAImageBrowserView * _Nullable imageBrowserView) {
            __strong typeof(self) strongSelf = weakself;
            switch (action) {
                case QAImageBrowserViewAction_SingleTap: {
                    [strongSelf singleTapAction:imageBrowserView];
                }
                    break;
                case QAImageBrowserViewAction_LongPress: {
                    [strongSelf longPressAction:imageBrowserView];
                }
                    break;

                default:
                    break;
            }
        };
        imageBrowserView.panGestureActionBlock = ^(CGAffineTransform translation, CGAffineTransform scale, float alpha, QAImageBrowserView * _Nullable imageBrowserView) {
            imageBrowserView.imageView.transform = CGAffineTransformConcat(translation, scale);
            self.blackBackgroundView.alpha = alpha;
        };
        imageBrowserView.panGestureDoneActionBlock = ^(BOOL finished, QAImageBrowserView * _Nullable imageBrowserView) {
            if (finished) {
                CGRect originalFrame = [self getOriginalFrame];
                CGRect rectInScrollView = CGRectMake(originalFrame.origin.x + self.rectOffsetX, originalFrame.origin.y + self.rectOffsetY, originalFrame.size.width, originalFrame.size.height);

                [self moveView:imageBrowserView toFrame:rectInScrollView];
            }
            else {
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     imageBrowserView.imageView.transform = CGAffineTransformIdentity;
                                     self.blackBackgroundView.alpha = 1;
                } completion:^(BOOL finished) {

                }];
            }
        };

        [imageBrowserView showImageWithImageUrl:[NSURL URLWithString:imageUrl]];
        blackBackgroundViewBounds.origin.x = blackBackgroundViewBounds.size.width * i;
        imageBrowserView.frame = CGRectOffset(blackBackgroundViewBounds, dx*i, 0);
        [self.scrollView addSubview:imageBrowserView];
    }
    [self.scrollView setContentSize:CGSizeMake(itemWidth * self.images.count, blackBackgroundViewBounds.size.height)];
    [self.scrollView setContentOffset:CGPointMake(itemWidth * self.currentPosition, 0) animated:NO];
}
- (void)singleTapAction:(QAImageBrowserView *)imageBrowserView {
    CGRect originalFrame = [self getOriginalFrame];
    CGRect rectInScrollView = CGRectMake(originalFrame.origin.x + self.rectOffsetX, originalFrame.origin.y + self.rectOffsetY, originalFrame.size.width, originalFrame.size.height);

    if (imageBrowserView.scrollView.zoomScale - 1. > 0) {
        [imageBrowserView.scrollView setZoomScale:1 animated:NO];
    }
    [self moveView:imageBrowserView toFrame:rectInScrollView];
}
- (CGRect)getOriginalFrame {
    CGRect rect = CGRectZero;
    NSDictionary *info = [self.images objectAtIndex:self.currentPosition];
    rect = [[info valueForKey:@"frame"] CGRectValue];
    
    return rect;
}
- (void)moveView:(QAImageBrowserView *)imageBrowserView toFrame:(CGRect)rectInScrollView {
    [UIView animateWithDuration:0.25
    animations:^{
        self.blackBackgroundView.alpha = 0.;
        imageBrowserView.imageView.frame = rectInScrollView;
    }
    completion:^(BOOL finished) {
        if (finished) {
            [self.scrollView removeFromSuperview];
            [self.blackBackgroundView removeFromSuperview];
            self.scrollView = nil;
            self.blackBackgroundView = nil;
        }
    }];
}
- (void)longPressAction:(QAImageBrowserView *)imageBrowserView {
    NSLog(@"%s",__func__);
}


#pragma mark - UIScrollView Delegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%s",__func__);
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (currentPage < 0 || currentPage >= self.images.count) {
        return;
    }
    
    QAImageBrowserView *previousPageView = [scrollView viewWithTag:(self.currentPosition+DefaultTag)];
    if (previousPageView) {
        [previousPageView.scrollView setZoomScale:1 animated:YES];
    }
    self.currentPosition = currentPage;
}


#pragma mark - Property -
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.pagingEnabled = YES;
        
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

@end
