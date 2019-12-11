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
@end

@implementation QAImageBrowserCell

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@"   %s",__func__);
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    
    return self;
}

 
#pragma mark - Public Methods -
- (void)configContent:(NSDictionary * _Nonnull)dic
         defaultImage:(UIImage * _Nullable)defaultImage
          contentMode:(UIViewContentMode)contentMode {
    NSString *imageUrl = [dic valueForKey:@"url"];
    UIImage *image = [dic valueForKey:@"image"];
    if (image) {
        [self showImage:image contentModel:contentMode];
    }
    else if (imageUrl) {
        [self showImageWithUrl:[NSURL URLWithString:imageUrl] defaultImage:defaultImage contentModel:contentMode];
    }
    else {
        NSLog(@"QAImageBrowser入参有误!");
        return;
    }
}


#pragma mark - ShowImages Method -
- (void)showImageWithUrl:(NSURL * _Nonnull)imageUrl
            defaultImage:(UIImage * _Nullable)defaultImage
            contentModel:(UIViewContentMode)contentModel {
    if (!imageUrl || imageUrl.absoluteString.length == 0) {
        return;
    }
    
    self.imageView.contentMode = contentModel;
    if (defaultImage) {
        [self updateImageViewWithImage:defaultImage];
    }
    
    [[SDWebImageDownloader sharedDownloader]
    downloadImageWithURL:imageUrl
    options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([imageUrl.absoluteString hasSuffix:@".gif"]) {
                NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:imageUrl.absoluteString];
                NSData *data = [NSData dataWithContentsOfFile:path];
                YYImage *yyImage = [YYImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateImageViewWithImage:yyImage];
                });
            }
            else {
                UIImage *decodeImage = [ImageProcesser decodeImage:image];  // image的解码
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateImageViewWithImage:decodeImage];
                });
            }
        });
    }];
}
- (void)showImage:(UIImage * _Nonnull)image contentModel:(UIViewContentMode)contentModel {
    self.imageView.contentMode = contentModel;
    [self updateImageViewWithImage:image];
}


#pragma mark - Private Methods -
- (void)setUp {
    [self.contentView addSubview:self.scrollView];
    // [self.contentView addSubview:self.activityIndicator];
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
    
    [singleTap requireGestureRecognizerToFail:doubleTap];   // 处理双击时不响应单击
}
- (void)updateImageViewWithImage:(UIImage *)image {
    if (!image) {
        return;
    }
    self.imageView.frame = [ImageProcesser caculateOriginImageSize:image];
    self.imageView.image = image;
    [self.scrollView setZoomScale:1 animated:NO];
    
    CGFloat offsetX = (self.scrollView.bounds.size.width > self.scrollView.contentSize.width) ? (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.scrollView.bounds.size.height > self.scrollView.contentSize.height) ?
    (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX,self.scrollView.contentSize.height * 0.5 + offsetY);
}
- (CGRect)zoomRectWithScale:(CGFloat)scale centerPoint:(CGPoint)center {
    CGRect zoomRect;

    zoomRect.size.height = [self.scrollView frame].size.height / scale;
    zoomRect.size.width = [self.scrollView frame].size.width / scale;

    zoomRect.origin.x = center.x - zoomRect.size.width / 2;
    zoomRect.origin.y = center.y - zoomRect.size.height / 2;

    return zoomRect;
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
    return self.imageView;
}

// 让图片保持在屏幕中央、防止图片放大时位置跑偏
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
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, UIWidth, UIHeight)];
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
