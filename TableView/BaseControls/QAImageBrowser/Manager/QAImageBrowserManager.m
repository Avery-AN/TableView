//
//  QAImageBrowserManager.m
//  Avery
//
//  Created by Avery on 2018/8/31.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QAImageBrowserManager.h"

static int DefaultTag = 10;
static CGFloat dx = 5;

@interface QAImageBrowserManager () <UIScrollViewDelegate>
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *blackBackgroundView;
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, assign) int currentPosition;
@property (nonatomic, unsafe_unretained) id tapedObject;
@property (nonatomic, unsafe_unretained) UIView *paningViewInCell;
@property (nonatomic, assign) CGFloat rectOffsetX;
@property (nonatomic, assign) CGFloat rectOffsetY;
@property (nonatomic, unsafe_unretained) UIWindow *window;
@property (nonatomic, assign) CGRect windowBounds;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) UIImageView *currentImageView;
@end

@implementation QAImageBrowserManager

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@"  %s",__func__);
}
- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}


#pragma mark - Public Methods -
- (void)showImageWithTapedObject:(id _Nonnull)tapedObject
                          images:(NSArray * _Nonnull)images {
    if (!tapedObject || !images || ![images isKindOfClass:[NSArray class]] || images.count == 0) {
        return;
    }
    else if (images.count < 1) {
        return;
    }
    
    self.tapedObject = tapedObject;
    self.images = images;
    self.currentPosition = [self getTapedPosition];
    [self createImageBrowserView];
    
    CGRect newRect = [self getTapedImageFrame];
    [self showImageBrowserViewWithNewFrame:newRect];
}


#pragma mark - Private Methods -
- (int)getTapedPosition {
    int result = -1;
    UIImageView *imageView = self.tapedObject;
    CGRect tapedRect = imageView.frame;
    for (int i = 0; i < self.images.count; i++) {
        NSDictionary *info = [self.images objectAtIndex:i];
        if ([info isKindOfClass:[NSDictionary class]]) {
            CGRect rect = [[info valueForKey:@"frame"] CGRectValue];
            if (CGRectEqualToRect(tapedRect, rect)) {   // NSDecimalNumber
                result = i;
                break;
            }
            else if (fabs(tapedRect.origin.x - rect.origin.x) <= 1 &&
                     fabs(tapedRect.origin.y - rect.origin.y) <= 1 &&
                     fabs(tapedRect.size.width - rect.size.width) <= 1 &&
                     fabs(tapedRect.size.height - rect.size.height) <= 1) {
                result = i;
                break;
            }
        }
        else {
            NSLog(@"QAImageBrowserManager - 传入参数有误!");
            break;
        }
    }
    return result;
}
- (CGRect)getTapedImageFrame {
    UIImageView *imageView = self.tapedObject;
    UIImage *image = imageView.image;  // 缩略图的image
    CGRect rect = CGRectZero;
    if (image) {
        rect = [ImageProcesser caculateOriginImageSize:image];
    }
    return rect;
}
- (void)createImageBrowserView {
//  UIWindow *window = [UIApplication sharedApplication].keyWindow;  // keyWindow会变
//  window.windowLevel = UIWindowLevelStatusBar + 1;
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    self.window = window;
    self.windowBounds = self.window.bounds;
    
    if (!self.blackBackgroundView) {
        self.blackBackgroundView = [[UIView alloc] initWithFrame:self.windowBounds];
        self.blackBackgroundView.backgroundColor = [UIColor blackColor];
    }
    self.blackBackgroundView.alpha = 0.1;
    [window addSubview:self.blackBackgroundView];
    [window addSubview:self.scrollView];
    
    if (!self.panGestureRecognizer) {
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [window addGestureRecognizer:self.panGestureRecognizer];
    }
}
- (void)showImageBrowserViewWithNewFrame:(CGRect)newFrame {
    UIImageView *tapedImageView = self.tapedObject;
    tapedImageView.hidden = YES;
    
    CGRect srcRect = tapedImageView.frame;
    UIView *tapedObjectSuperView = tapedImageView.superview;
    CGRect rect = [tapedImageView convertRect:tapedObjectSuperView.frame toView:self.blackBackgroundView];
    self.rectOffsetX = rect.origin.x - srcRect.origin.x;
    self.rectOffsetY = rect.origin.y - srcRect.origin.y;
    if (self.currentImageView == nil) {
        UIImageView *currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, srcRect.size.width, srcRect.size.height)];
        currentImageView.contentMode = tapedImageView.contentMode;
        currentImageView.image = tapedImageView.image;
        currentImageView.clipsToBounds = YES;
        self.currentImageView = currentImageView;
        [self.window addSubview:currentImageView];
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.blackBackgroundView.alpha = 1;
                         self.currentImageView.frame = newFrame;
    } completion:^(BOOL finished) {
        [self processImagesBrowser];
        tapedImageView.hidden = NO;
        [self.currentImageView removeFromSuperview];
        self.currentImageView = nil;
    }];
}
- (void)processImagesBrowser {
    CGRect blackBackgroundViewBounds = self.blackBackgroundView.bounds;
    CGFloat itemWidth = blackBackgroundViewBounds.size.width + dx;
    self.scrollView.frame = CGRectMake(0, 0, itemWidth, blackBackgroundViewBounds.size.height);
    [self.scrollView setContentSize:CGSizeMake(itemWidth * self.images.count, blackBackgroundViewBounds.size.height)];
    [self.scrollView setContentOffset:CGPointMake(itemWidth * self.currentPosition, 0) animated:NO];

    int previous = self.currentPosition - 1;
    int next = self.currentPosition + 1;
    for (int i = 0; i < self.images.count; i++) {
        NSDictionary *imageInfo = [self.images objectAtIndex:i];
        NSString *imageUrl = [imageInfo valueForKey:@"url"];
        UIImage *image = [imageInfo valueForKey:@"image"];
        if (!image && (!imageUrl || ![imageUrl isKindOfClass:[NSString class]] || imageUrl.length == 0)) {
            NSLog(@"QAImageBrowserView入参有误!");
            return;
        }
        
        // 最多只创建3个QAImageBrowserView对象:
        if (i != self.currentPosition) {
            if (previous >= 0) {
                if (i != previous && i != next) {
                    continue;
                }
            }
            else {
                if (i != next && i != next+1) {
                    continue;
                }
            }
        }
        
        QAImageBrowserView *imageBrowserView = [self createQAImageBrowserViewWithUrl:imageUrl image:image atIndex:i];
        blackBackgroundViewBounds.origin.x = blackBackgroundViewBounds.size.width * i;
        imageBrowserView.frame = CGRectOffset(blackBackgroundViewBounds, dx*i, 0);
        [self.scrollView addSubview:imageBrowserView];
    }
}
- (QAImageBrowserView *)createQAImageBrowserViewWithUrl:(NSString *)imageUrl
                                                  image:(UIImage *)image
                                                atIndex:(unsigned long)index {
    QAImageBrowserView *imageBrowserView = [[QAImageBrowserView alloc] init];
    imageBrowserView.tag = index + DefaultTag;
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
    
    UIImageView *tapedImageView = self.tapedObject;
    if (image) {
        [imageBrowserView showImage:image contentModel:tapedImageView.contentMode];
    }
    else {
        if (index == self.currentPosition) {
            [imageBrowserView showImage:tapedImageView.image contentModel:tapedImageView.contentMode];
        }
        [imageBrowserView showImageWithUrl:[NSURL URLWithString:imageUrl] contentModel:tapedImageView.contentMode];
    }
    
    return imageBrowserView;
}
- (void)panViewWithTransform:(CGAffineTransform)transform
                       alpha:(CGFloat)alpha
                      paning:(BOOL)paning {
    if (paning) {
        self.currentImageView.transform = transform;
        self.blackBackgroundView.alpha = alpha;
    }
    else {
        [UIView animateWithDuration:0.2
                         animations:^{
            self.currentImageView.transform = transform;
            self.blackBackgroundView.alpha = alpha;
        } completion:^(BOOL finished) {
            if (alpha == 1 && self.paningViewInCell) {
                QAImageBrowserView *imageBrowserView = [self.scrollView viewWithTag:(self.currentPosition + DefaultTag)];
                imageBrowserView.hidden = NO;
                [self hideImageViewInCell:NO];
                [self.currentImageView removeFromSuperview];
                self.currentImageView = nil;
            }
        }];
    }
}
- (void)hideImageViewInCell:(BOOL)hidden {
    if (hidden == NO) {
        self.paningViewInCell.hidden = NO;
    }
    else {
        UIView *tapedView = (UIView *)self.tapedObject;
        UIView *superView = tapedView.superview;
        NSDictionary *info = [self.images objectAtIndex:self.currentPosition];
        CGRect rect = [[info valueForKey:@"frame"] CGRectValue];
        for (UIView *view in superView.subviews) {
            if (view && [view isKindOfClass:[UIImageView class]]) {
                if (CGRectEqualToRect(view.frame, rect)) {   // NSDecimalNumber
                    self.paningViewInCell = view;
                    self.paningViewInCell.hidden = YES;
                    break;
                }
                else if (fabs(view.frame.origin.x - rect.origin.x) <= 1 &&
                         fabs(view.frame.origin.y - rect.origin.y) <= 1 &&
                         fabs(view.frame.size.width - rect.size.width) <= 1 &&
                         fabs(view.frame.size.height - rect.size.height) <= 1) {
                    self.paningViewInCell = view;
                    self.paningViewInCell.hidden = YES;
                    break;
                }
            }
        }
    }
}
- (void)createCurrentImageView {
    QAImageBrowserView *imageBrowserView = [self.scrollView viewWithTag:(self.currentPosition + DefaultTag)];
    CGRect imageViewFrame = imageBrowserView.imageView.frame;
    CGFloat width = imageViewFrame.size.width;
    CGFloat height = imageViewFrame.size.height;
    CGFloat offsetX = (imageBrowserView.scrollView.contentSize.width - ScreenWidth) / 2. - imageBrowserView.scrollView.contentOffset.x;
    CGFloat originX = (ScreenWidth - width) / 2. + offsetX;
    CGFloat originY = (ScreenHeight - height) / 2.;
    UIImageView *currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
    currentImageView.contentMode = imageBrowserView.imageView.contentMode;
    currentImageView.image = imageBrowserView.imageView.image;
    currentImageView.clipsToBounds = YES;
    self.currentImageView = currentImageView;
    [self.window addSubview:currentImageView];
    imageBrowserView.hidden = YES;
}
- (void)quitImageBrowser:(UIImageView *)imageView {
    [self hideImageViewInCell:YES];
    
    CGRect originalFrame = [self getOriginalFrame];
    CGRect rectInScrollView = CGRectMake(originalFrame.origin.x + self.rectOffsetX, originalFrame.origin.y + self.rectOffsetY, originalFrame.size.width, originalFrame.size.height);
    [self moveView:imageView toFrame:rectInScrollView];
}
- (CGRect)getOriginalFrame {
    CGRect rect = CGRectZero;
    NSDictionary *info = [self.images objectAtIndex:self.currentPosition];
    rect = [[info valueForKey:@"frame"] CGRectValue];
    
    return rect;
}
- (void)moveView:(UIImageView *)imageView toFrame:(CGRect)rectInScrollView {  // 退出图片浏览器
    [UIView animateWithDuration:0.2
    animations:^{
        self.blackBackgroundView.alpha = 0.;
        imageView.frame = rectInScrollView;
    }
    completion:^(BOOL finished) {
        if (finished) {
            [self cleanupTheBattlefield];
        }
    }];
}
- (void)quitImageBrowser_directly {
    [UIView animateWithDuration:0.2
                     animations:^{
        self.blackBackgroundView.alpha = 0;
        self.scrollView.alpha = 0;
    } completion:^(BOOL finished) {
        [self cleanupTheBattlefield];
    }];
}
- (void)cleanupTheBattlefield {
    if (self.paningViewInCell) {
        [self hideImageViewInCell:NO];
    }
    if (self.currentImageView) {
        [self.currentImageView removeFromSuperview];
        self.currentImageView = nil;
    }
    
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    [self.blackBackgroundView removeFromSuperview];
    self.blackBackgroundView = nil;
    
    if (self.window) {
        [self.window removeGestureRecognizer:self.panGestureRecognizer];
        self.panGestureRecognizer = nil;
    }
}
// 修改QAImageBrowserView在scrollView中的位置并修改其tag值:
- (void)processImageBrowserViewAfterPagingWithPosition:(int)previous_currentPosition {
    if (previous_currentPosition != self.currentPosition) {
        NSDictionary *imageInfo = [self.images objectAtIndex:self.currentPosition];
        NSString *imageUrl = [imageInfo valueForKey:@"url"];
        UIImage *image = [imageInfo valueForKey:@"image"];
        
        int currentView_tag = (previous_currentPosition + DefaultTag);
        QAImageBrowserView *currentPageView = [self.scrollView viewWithTag:currentView_tag];
        int rightView_tag = (previous_currentPosition + DefaultTag) + 1;
        QAImageBrowserView *rightPageView = nil;
        if (self.images.count - (rightView_tag - DefaultTag) > 0) {
            rightPageView = [self.scrollView viewWithTag:rightView_tag];
        }
        int leftView_tag = (previous_currentPosition + DefaultTag) - 1;
        QAImageBrowserView *leftPageView = nil;
        if (leftView_tag - DefaultTag >= 0) {
            leftPageView = [self.scrollView viewWithTag:leftView_tag];
        }
        
        if (self.currentPosition - previous_currentPosition > 0) {  // 手指往左滑
            currentPageView.tag = (self.currentPosition + DefaultTag) - 1;  // currentPageViiew -> leftPageView
            rightPageView.tag = (self.currentPosition + DefaultTag);  // rightPageView -> currentPageViiew
            
            if (leftPageView) {
                if (self.currentPosition == self.images.count - 1) {  // 最后一页
                    leftPageView.tag = (self.currentPosition + DefaultTag) - 1 - 1;  // leftPageView -> left-leftPageView
                }
                else {
                    leftPageView.tag = (self.currentPosition + DefaultTag) + 1;  // leftPageView -> rightPageView
                    
                    // 重新加载新的URL:
                    UIImageView *tapedImageView = self.tapedObject;
                    if (image) {
                        [leftPageView showImage:image contentModel:tapedImageView.contentMode];
                    }
                    else {
                        [leftPageView showImageWithUrl:[NSURL URLWithString:imageUrl] contentModel:tapedImageView.contentMode];
                    }
                    
                    // 修改leftPageView在scrollView中的位置:
                    CGRect frame = leftPageView.frame;
                    frame.origin.x = self.scrollView.bounds.size.width * (self.currentPosition + 1);
                    leftPageView.frame = frame;
                }
            }
            else {
                leftPageView = [self createQAImageBrowserViewWithUrl:imageUrl image:image atIndex:0];
                [self.scrollView addSubview:leftPageView];
            }
        }
        else {  // 手指往右滑
            currentPageView.tag = (self.currentPosition + DefaultTag) + 1;  // currentPageViiew -> rightPageView
            leftPageView.tag = (self.currentPosition + DefaultTag);  // leftPageView -> currentPageViiew
            
            if (rightPageView) {
                if (self.currentPosition == 0) {  // 第一页
                    rightPageView.tag = (self.currentPosition + DefaultTag) + 1 + 1;  // rightPageView -> rightt-rightPageView
                }
                else {
                    rightPageView.tag = (self.currentPosition + DefaultTag) - 1;  // rightPageView -> leftPageView
                    
                    // 重新加载新的URL:
                    UIImageView *tapedImageView = self.tapedObject;
                    if (image) {
                        [rightPageView showImage:image contentModel:tapedImageView.contentMode];
                    }
                    else {
                        [rightPageView showImageWithUrl:[NSURL URLWithString:imageUrl] contentModel:tapedImageView.contentMode];
                    }
                    
                    // 修改rightPageView在scrollView中的位置:
                    CGRect frame = rightPageView.frame;
                    frame.origin.x = self.scrollView.bounds.size.width * (self.currentPosition - 1);
                    rightPageView.frame = frame;
                    NSLog(@"");
                }
            }
            else {
                rightPageView = [self createQAImageBrowserViewWithUrl:imageUrl image:image atIndex:self.currentPosition-1];
                CGRect frame = rightPageView.frame;
                frame.origin.x = (self.scrollView.bounds.size.width) * (self.currentPosition-1);
                rightPageView.frame = frame;
                [self.scrollView addSubview:rightPageView];
            }
        }
    }
}



#pragma mark - Gesture Actions -
- (void)singleTapAction:(QAImageBrowserView *)imageBrowserView {
    if (imageBrowserView.scrollView.zoomScale - 1 >= 0.01) {
        if (self.currentImageView == nil) {
            [self createCurrentImageView];
            [self quitImageBrowser:self.currentImageView];
        }
    }
    else {
        UIImageView *imageView = imageBrowserView.imageView;
        [self quitImageBrowser:imageView];
    }
}
- (void)longPressAction:(QAImageBrowserView *)imageBrowserView {
    NSLog(@"%s",__func__);
}
- (void)handlePan:(UIPanGestureRecognizer *)panGesture {
    CGPoint transPoint = [panGesture translationInView:self.window];
    CGPoint velocity = [panGesture velocityInView:self.window];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            // 将cell中与其对应的imageView进行隐藏:
            [self hideImageViewInCell:YES];
            
            // 创建一个临时imageView:
            if (self.currentImageView == nil) {
                [self createCurrentImageView];
            }
        }
        break;

        case UIGestureRecognizerStateChanged: {
            [self.scrollView setScrollEnabled:NO];

            float alpha = 1 - fabs(transPoint.y) / self.windowBounds.size.height;
            alpha = MAX(alpha, 0.1);  // 保证"alpha >= 0.1"
            float scale = MAX(alpha, 0.6);  // 保证scale的最小值为原图的0.6倍
            CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(transPoint.x / scale, transPoint.y / scale);
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
            [self panViewWithTransform:CGAffineTransformConcat(translationTransform, scaleTransform) alpha:alpha paning:YES];
        }
        break;

        case UIGestureRecognizerStateEnded: {
            if (fabs(transPoint.y) > 220 || fabs(velocity.y) > 500) {
                [self quitImageBrowser:self.currentImageView];
            }
            else {
                [self panViewWithTransform:CGAffineTransformIdentity alpha:1 paning:NO];  // 返回到初始状态
            }
            
            [self.scrollView setScrollEnabled:YES];
        }
        break;

        case UIGestureRecognizerStateCancelled: {
            [self panViewWithTransform:CGAffineTransformIdentity alpha:1 paning:NO];  // 返回到初始状态
            [self.scrollView setScrollEnabled:YES];
        }
        break;

        default:{
            [self panViewWithTransform:CGAffineTransformIdentity alpha:1 paning:NO];  // 返回到初始状态
            [self.scrollView setScrollEnabled:YES];
        }
        break;
    }
}


#pragma mark - UIScrollView Delegate -
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.x <= -88) {
        [self quitImageBrowser_directly];
    }
    else if (ScreenWidth - (scrollView.contentSize.width - scrollView.contentOffset.x) >= 88) {
        [self quitImageBrowser_directly];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    int currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (currentPage < 0 || currentPage >= self.images.count) {
        return;
    }
    
    int previous_currentPosition = self.currentPosition;
    QAImageBrowserView *previousPageView = [scrollView viewWithTag:(previous_currentPosition+DefaultTag)];
    if (previousPageView) {
        [previousPageView.scrollView setZoomScale:1 animated:YES];
    }
    self.currentPosition = currentPage;
    
    [self processImageBrowserViewAfterPagingWithPosition:previous_currentPosition];
}


#pragma mark - MemoryWarning -
- (void)handleMemoryWarning {
    // 清除SDWebImageManager在内存中缓存的图片:
    [[SDWebImageManager sharedManager].imageCache clearMemory];
    
    /*
     // 清除SDWebImageManager在磁盘中缓存的图片:
     [[SDWebImageManager sharedManager].imageCache clearDiskOnCompletion:^{
         
     }];
     */
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
