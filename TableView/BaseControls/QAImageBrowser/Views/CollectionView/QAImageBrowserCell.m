//
//  QAImageBrowserCell.m
//  TableView
//
//  Created by Avery An on 2019/12/10.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "QAImageBrowserCell.h"

@interface QAImageBrowserCell () <UIScrollViewDelegate>
@property(nonatomic) UIActivityIndicatorView *activityIndicator;
@property(nonatomic) UITapGestureRecognizer *singleTap;
@property(nonatomic) UITapGestureRecognizer *doubleTap;
@property(nonatomic) UITapGestureRecognizer *twoFingerTap;
@property(nonatomic) UILongPressGestureRecognizer *longPressGesture;
@property(nonatomic, copy) NSDictionary *dic;
@property(nonatomic) UIImage *defaultImage;
@end

@implementation QAImageBrowserCell

#pragma mark - Life Cycle -
- (void)dealloc {
    //NSLog(@"   %s",__func__);
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    
    return self;
}


#pragma mark - Public Methods -
- (void)configImageView:(YYAnimatedImageView *)imageView
           defaultImage:(UIImage * _Nullable)defaultImage {
    if (self.imageView != imageView) {
        self.imageView.image = nil;
        self.imageView.hidden = YES;
        
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        self.scrollView.zoomScale = 1;
        [self.scrollView addSubview:imageView];
        [self addAllGesturesToView:imageView];
        self.currentShowImageView = imageView;
        if (defaultImage) {
            [self updateImageView:imageView withImage:defaultImage];
        }
    }
}
- (void)reprepareShowImageViewWithImageDownloadManager:(QAImageBroeserDownloadManager * _Nonnull)imageDownloadManager {
    self.imageView.hidden = NO;
    self.currentShowImageView = self.imageView;
    [self showContentWithContentMode:self.imageView.contentMode imageDownloadManager:imageDownloadManager];
    [self addAllGesturesToView:self.imageView];
}
- (void)configContent:(NSDictionary * _Nonnull)dic
         defaultImage:(UIImage * _Nullable)defaultImage
          contentMode:(UIViewContentMode)contentMode
withImageDownloadManager:(QAImageBroeserDownloadManager * _Nonnull)imageDownloadManager {
    self.dic = dic;
    self.defaultImage = defaultImage;
    self.imageView.contentMode = contentMode;
    self.imageView.hidden = NO;
    
    [self showContentWithContentMode:contentMode imageDownloadManager:imageDownloadManager];
}
- (void)clearALLGesturesInView:(UIView * _Nonnull)view {
    if (!view) {
        return;
    }
    [view removeGestureRecognizer:self.doubleTap];
    [view removeGestureRecognizer:self.twoFingerTap];
    [view removeGestureRecognizer:self.longPressGesture];
}


#pragma mark - ShowImages Method -
- (void)showContentWithContentMode:(UIViewContentMode)contentMode
              imageDownloadManager:(QAImageBroeserDownloadManager * _Nonnull)imageDownloadManager {
    NSString *imageUrl = [self.dic valueForKey:@"url"];
    UIImage *image = [self.dic valueForKey:@"image"];
    if (image) {
        [self showImage:image contentModel:contentMode];
    }
    else if (imageUrl) {
        [self showImageWithUrl:[NSURL URLWithString:imageUrl] defaultImage:self.defaultImage contentModel:contentMode imageDownloadManager:imageDownloadManager];
    }
    else {
        NSLog(@"QAImageBrowser入参有误!");
        return;
    }
}
- (void)showImageWithUrl:(NSURL * _Nonnull)imageUrl
            defaultImage:(UIImage * _Nullable)defaultImage
            contentModel:(UIViewContentMode)contentModel
    imageDownloadManager:(QAImageBroeserDownloadManager * _Nonnull)imageDownloadManager {
    if (!imageUrl || imageUrl.absoluteString.length == 0) {
        return;
    }
    
    self.currentShowImageView.contentMode = contentModel;
    if (defaultImage) {
        [self updateImageView:self.currentShowImageView withImage:defaultImage];
    }
    
    __weak typeof(self) weakSelf = self;
    [imageDownloadManager queryImageWithUrl:imageUrl
                                   finished:^(NSURL * _Nonnull image_url, UIImage * _Nullable image_completed) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (imageUrl == image_url) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if ([imageUrl.absoluteString hasSuffix:@".gif"]) {
                    NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:imageUrl.absoluteString];
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    YYImage *yyImage = [YYImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf updateImageView:self.currentShowImageView withImage:yyImage];
                    });
                }
                else {
                    UIImage *decodeImage = [QAImageProcesser decodeImage:image_completed];  // image的解码
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf updateImageView:self.currentShowImageView withImage:decodeImage];
                    });
                }
            });
        }
    } failed:^(NSURL * _Nonnull image_url, NSError * _Nullable error) {
        
    }];
}
- (void)showImage:(UIImage * _Nonnull)image contentModel:(UIViewContentMode)contentModel {
    self.imageView.contentMode = contentModel;
    [self updateImageView:self.currentShowImageView withImage:image];
}


#pragma mark - Private Methods -
- (void)setUp {
    [self.contentView addSubview:self.scrollView];
    // [self.contentView addSubview:self.activityIndicator];
    [self.scrollView addSubview:self.imageView];
    
    [self addAllGesturesToView:self.imageView];
    self.currentShowImageView = self.imageView;
}
- (void)updateImageView:(UIImageView *)imageView withImage:(UIImage *)image {
    if (!image) {
        return;
    }
    else if (imageView.superview != self.scrollView) {
        return;
    }
    imageView.frame = [QAImageProcesser caculateOriginImageSize:image];
    imageView.image = image;
    [self.scrollView setZoomScale:1 animated:NO];
    
    CGFloat offsetX = (self.scrollView.bounds.size.width > self.scrollView.contentSize.width) ? (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.scrollView.bounds.size.height > self.scrollView.contentSize.height) ?
    (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5 : 0.0;
    imageView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX,self.scrollView.contentSize.height * 0.5 + offsetY);
}
- (CGRect)zoomRectWithScale:(CGFloat)scale centerPoint:(CGPoint)center {
    CGRect zoomRect;

    zoomRect.size.height = [self.scrollView frame].size.height / scale;
    zoomRect.size.width = [self.scrollView frame].size.width / scale;

    zoomRect.origin.x = center.x - zoomRect.size.width / 2;
    zoomRect.origin.y = center.y - zoomRect.size.height / 2;

    return zoomRect;
}
- (void)addAllGesturesToView:(UIImageView *)imageView {
    // 添加手势:
    if (!self.singleTap) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        self.singleTap = singleTap;
    }
    else {
        [self removeGestureRecognizer:self.singleTap];
    }
    
    if (!self.doubleTap) {
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        self.doubleTap = doubleTap;
    }
    else {
        [imageView removeGestureRecognizer:self.doubleTap];
    }
    
    if (!self.twoFingerTap) {
            UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerPan:)];
        self.twoFingerTap = twoFingerTap;
    }
    else {
        [imageView removeGestureRecognizer:self.twoFingerTap];
    }
    
    if (!self.longPressGesture) {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        self.longPressGesture = longPressGesture;
    }
    else {
        [imageView removeGestureRecognizer:self.longPressGesture];
    }
    
    self.singleTap.numberOfTapsRequired = 1;
    self.singleTap.numberOfTouchesRequired = 1;
    self.doubleTap.numberOfTapsRequired = 2;
    self.doubleTap.numberOfTouchesRequired = 1;
    self.twoFingerTap.numberOfTouchesRequired = 2;
    
    [self addGestureRecognizer:self.singleTap];
    [imageView addGestureRecognizer:self.doubleTap];
    [imageView addGestureRecognizer:self.twoFingerTap];
    [imageView addGestureRecognizer:self.longPressGesture];
    
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];   // 处理双击时不响应单击
}


#pragma mark - Actions -
- (void)handleSingleTap:(UITapGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateEnded: {
            if (self.gestureActionBlock) {
                self.gestureActionBlock(QAImageBrowserViewAction_SingleTap, self);
            }
        }
            break;
            
        default: {
            
        }
            break;
    }
}
- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    if (gesture.numberOfTapsRequired == 2) {
        if (self.scrollView.zoomScale == 1) {
            float newScale = [self.scrollView zoomScale] * 2;
            CGRect zoomRect = [self zoomRectWithScale:newScale centerPoint:[gesture locationInView:gesture.view]];
            [self.scrollView zoomToRect:zoomRect animated:YES];
        }
        else {
            float newScale = [self.scrollView zoomScale] / 2;
            CGRect zoomRect = [self zoomRectWithScale:newScale centerPoint:[gesture locationInView:gesture.view]];
            [self.scrollView zoomToRect:zoomRect animated:YES];
        }
    }
}
- (void)handleTwoFingerPan:(UITapGestureRecognizer *)gesture {
    CGFloat panScale = [self.scrollView zoomScale] / 2;
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

            default: {

            }
            break;
    }
}


#pragma mark - UIScrollView Delegate -
// 返回要缩放的UI控件
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.currentShowImageView;
}

// 让图片保持在屏幕中央、防止图片放大时位置跑偏
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (self.scrollView.bounds.size.width > self.scrollView.contentSize.width)?(self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.scrollView.bounds.size.height > self.scrollView.contentSize.height)?
    (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5 : 0.0;
    self.currentShowImageView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX,self.scrollView.contentSize.height * 0.5 + offsetY);
}

// 重新确定缩放完后的缩放倍数
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}


#pragma mark - Property -
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, QAImageBrowserScreenWidth, QAImageBrowserScreenHeight)];
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
- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
        _imageView.tag = 999;
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

@end
