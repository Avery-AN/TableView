//
//  QAImageBrowserManager.m
//  Avery
//
//  Created by Avery on 2018/8/31.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QAImageBrowserManager.h"
#import "QAImageBrowserLayout.h"
#import "QAImageBrowserCell.h"

@interface QAImageBrowserManager () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic) QAImageBrowserLayout *layout;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic, unsafe_unretained) UIWindow *window;
@property (nonatomic) UIView *blackBackgroundView;
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, assign) int currentPosition;
@property (nonatomic, unsafe_unretained) UIImageView *tapedImageView;
@property (nonatomic, unsafe_unretained) UIView *tapedSuperView;
@property (nonatomic, unsafe_unretained) YYAnimatedImageView *currentShowingImageView;
@property (nonatomic) CGRect tapedImageViewRect;
@property (nonatomic, unsafe_unretained) UIView *paningViewInCell;
@property (nonatomic, assign) CGFloat rectOffsetX;
@property (nonatomic, assign) CGFloat rectOffsetY;
@property (nonatomic, assign) CGRect windowBounds;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, unsafe_unretained) QAImageBrowserCell *previousImageBrowserCell;
@property (nonatomic, unsafe_unretained) QAImageBrowserCell *currentImageBrowserCell;
@property (nonatomic) CGRect imageViewRectInCell;
@property (nonatomic) CGAffineTransform imageViewTransformInCell;
@property (nonatomic, copy) QAImageBrowserFinishedBlock finishedBlock;
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
- (void)showImageWithTapedObject:(UIImageView * _Nonnull)tapedImageView
                          images:(NSArray * _Nonnull)images
                          finished:(QAImageBrowserFinishedBlock _Nullable)finishedBlock {
    if (!tapedImageView || !images || ![images isKindOfClass:[NSArray class]] || images.count == 0) {
        NSLog(@"  tapedImageView: %@ 【 WTF 】!!!!!!!!", tapedImageView);
        return;
    }
    else if (images.count < 1) {
        return;
    }
    
    self.finishedBlock = finishedBlock;
    self.tapedImageView = tapedImageView;
    self.images = images;
    self.currentPosition = [self getTapedPosition];
    [self createImageBrowserBasicView];
    CGRect newRect = [self getTapedImageFrame];
    [self showImageBrowserViewWithFrame:newRect];
}


#pragma mark - Private Methods -
- (int)getTapedPosition {
    int result = -1;
    self.tapedSuperView = self.tapedImageView.superview;
    CGRect tapedRect = self.tapedImageView.frame;
    self.tapedImageViewRect = tapedRect;
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
    UIImage *image = self.tapedImageView.image;  // 缩略图的image
    CGRect rect = CGRectZero;
    if (image) {
        rect = [ImageProcesser caculateOriginImageSize:image];
    }
    return rect;
}
- (void)createImageBrowserBasicView {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    self.window = window;
    self.windowBounds = self.window.bounds;
    
    if (!self.blackBackgroundView) {
        self.blackBackgroundView = [[UIView alloc] initWithFrame:self.windowBounds];
        self.blackBackgroundView.backgroundColor = [UIColor blackColor];
    }
    self.blackBackgroundView.alpha = 0.1;
    [window addSubview:self.blackBackgroundView];
    
    [self addPanGestureRecognizer];
    
    [self.window addSubview:self.collectionView];
    [self.collectionView setContentOffset:CGPointMake(self.currentPosition*self.collectionView.bounds.size.width, 0)];
    self.collectionView.hidden = YES;
}
- (void)removePanGestureRecognizer {
    if (self.window && self.panGestureRecognizer) {
        [self.window removeGestureRecognizer:self.panGestureRecognizer];
        self.panGestureRecognizer = nil;
    }
    else if (self.panGestureRecognizer) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [window removeGestureRecognizer:self.panGestureRecognizer];
        self.panGestureRecognizer = nil;
    }
}
- (void)addPanGestureRecognizer {
    if (!self.panGestureRecognizer) {
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    }
    [self.window addGestureRecognizer:self.panGestureRecognizer];
}
- (void)showImageBrowserViewWithFrame:(CGRect)newFrame {
    YYAnimatedImageView *tapedImageView = (YYAnimatedImageView *)self.tapedImageView;
    
    CGRect srcRect = tapedImageView.frame;
    CGRect rect = [tapedImageView convertRect:self.tapedSuperView.frame toView:self.blackBackgroundView];
    self.rectOffsetX = rect.origin.x - srcRect.origin.x;
    self.rectOffsetY = rect.origin.y - srcRect.origin.y;
    tapedImageView.frame = CGRectMake(rect.origin.x, rect.origin.y, srcRect.size.width, srcRect.size.height);
    [self.window addSubview:tapedImageView];
    
    [UIView animateWithDuration:.25
                     animations:^{
                         self.blackBackgroundView.alpha = 1;
                         tapedImageView.frame = newFrame;
    } completion:^(BOOL finished) {
        self.collectionView.hidden = NO;
        [self getCurrentShowingImageView:nil];
        [self.currentImageBrowserCell configImageView:tapedImageView defaultImage:tapedImageView.image];
    }];
}
- (void)panViewWithTransform:(CGAffineTransform)transform
                       alpha:(CGFloat)alpha
                      paning:(BOOL)paning {
    if (paning) {
        self.currentShowingImageView.transform = transform;
        self.blackBackgroundView.alpha = alpha;
    }
    else {
        [UIView animateWithDuration:0.2
                         animations:^{
            self.currentShowingImageView.transform = transform;
            self.blackBackgroundView.alpha = alpha;
        } completion:^(BOOL finished) {
            if (alpha == 1) {
                if (self.paningViewInCell) {
                    [self hideImageViewInCell:NO];
                }
                [self processQAImageBrowserCellAfterPanCanceled];
            }
        }];
    }
}
- (void)getCurrentShowingImageView:(QAImageBrowserCell *)imageBrowserCell {
    if (imageBrowserCell) {
        self.currentImageBrowserCell = imageBrowserCell;
    }
    else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentPosition inSection:0];
        imageBrowserCell = (QAImageBrowserCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        self.currentImageBrowserCell = imageBrowserCell;
    }
    
    YYAnimatedImageView *imageView = self.currentImageBrowserCell.currentShowImageView;
    self.currentShowingImageView = imageView;
}
- (void)processQAImageBrowserCellAfterPanCanceled {
    UIImageView *imageView = self.currentShowingImageView;
    imageView.transform = self.imageViewTransformInCell;
    imageView.frame = self.imageViewRectInCell;
    [self.currentImageBrowserCell.scrollView addSubview:imageView];
}
- (void)processQAImageBrowserCellWhenPanBegan {
    [self getCurrentShowingImageView:nil];
    
    self.imageViewRectInCell = self.currentShowingImageView.frame;
    self.imageViewTransformInCell = self.currentShowingImageView.transform;
    CGRect imageNewFrame = CGRectMake(-self.currentImageBrowserCell.scrollView.contentOffset.x+self.imageViewRectInCell.origin.x, self.currentImageBrowserCell.scrollView.contentOffset.y+self.imageViewRectInCell.origin.y, self.imageViewRectInCell.size.width, self.imageViewRectInCell.size.height);
    self.currentShowingImageView.transform = CGAffineTransformIdentity;
    self.currentShowingImageView.frame = imageNewFrame;
    [self.window addSubview:self.currentShowingImageView];
}
- (void)hideImageViewInCell:(BOOL)hidden {
    if (hidden == NO) {
        self.paningViewInCell.hidden = NO;
    }
    else {
        NSDictionary *info = [self.images objectAtIndex:self.currentPosition];
        CGRect rect = [[info valueForKey:@"frame"] CGRectValue];
        for (UIView *view in self.tapedSuperView.subviews) {
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
- (CGRect)getOriginalFrameInTableViewAtIndex:(int)index {
    CGRect rect = CGRectZero;
    if (index >= 0 && index < self.images.count) {
        NSDictionary *info = [self.images objectAtIndex:index];
        rect = [[info valueForKey:@"frame"] CGRectValue];
    }
    
    return rect;
}
- (void)quitImageBrowser {  // 退出图片浏览器
    CGRect srcRect = [self getOriginalFrameInTableViewAtIndex:self.currentPosition];  // 在tableView的cell中的坐标
    CGRect rectInWindow = CGRectZero;
    if (self.currentShowingImageView.superview == self.window) {
        rectInWindow = CGRectMake(srcRect.origin.x + self.rectOffsetX, srcRect.origin.y + self.rectOffsetY, srcRect.size.width, srcRect.size.height);
    }
    else {
        rectInWindow = CGRectMake(srcRect.origin.x + self.rectOffsetX + self.currentImageBrowserCell.scrollView.contentOffset.x, srcRect.origin.y + self.rectOffsetY + self.currentImageBrowserCell.scrollView.contentOffset.y, srcRect.size.width, srcRect.size.height);
    }
    [self moveView:self.currentImageBrowserCell toFrame:rectInWindow];
}
- (void)moveView:(QAImageBrowserCell *)imageBrowserCell toFrame:(CGRect)rectInWindow {
    [self removePanGestureRecognizer];
    imageBrowserCell.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:.2
    animations:^{
        self.blackBackgroundView.alpha = 0;
        self.currentShowingImageView.frame = rectInWindow;
    }
    completion:^(BOOL finished) {
        [self cleanupTheBattlefield];
    }];
}
- (void)quitImageBrowser_directly {
    [self getCurrentShowingImageView:nil];
    [self removePanGestureRecognizer];
    self.currentImageBrowserCell.userInteractionEnabled = NO;
    
    CGRect srcRect = [self getOriginalFrameInTableViewAtIndex:self.currentPosition];  // 在tableView的cell中的坐标
    CGRect rectInWindow = CGRectMake(srcRect.origin.x + self.rectOffsetX + self.currentImageBrowserCell.scrollView.contentOffset.x, srcRect.origin.y + self.rectOffsetY + self.currentImageBrowserCell.scrollView.contentOffset.y, srcRect.size.width, srcRect.size.height);
    
    [UIView animateWithDuration:.2
                     animations:^{
        self.blackBackgroundView.alpha = 0;
        self.currentShowingImageView.frame = rectInWindow;
    } completion:^(BOOL finished) {
        [self cleanupTheBattlefield];
    }];
}
- (void)cleanupTheBattlefield {
    CGRect srcRect = [self getOriginalFrameInTableViewAtIndex:self.currentPosition];
    self.currentShowingImageView.transform = CGAffineTransformIdentity;
    [self.tapedSuperView addSubview:self.currentShowingImageView];
    self.currentShowingImageView.frame = srcRect;
    [self.currentShowingImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(srcRect.origin.y);
        make.left.mas_equalTo(srcRect.origin.x);
        make.size.mas_equalTo(srcRect.size);
    }];
    if (self.paningViewInCell == self.tapedImageView) {
        [self hideImageViewInCell:NO];
    }
    else if (self.paningViewInCell) {
        self.currentShowingImageView.tag = self.paningViewInCell.tag;
        [self.paningViewInCell removeFromSuperview];
        self.paningViewInCell = self.currentShowingImageView;
    }
    if (self.finishedBlock) {
        self.finishedBlock(self.currentPosition, self.currentShowingImageView);
    }
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
    [self.blackBackgroundView removeFromSuperview];
    self.blackBackgroundView = nil;
}
- (void)makeTapedImageViewBacktoSrcTableView {
    CGRect srcRect = self.tapedImageViewRect;
    self.previousImageBrowserCell.currentShowImageView.transform = CGAffineTransformIdentity;
    self.previousImageBrowserCell.currentShowImageView.frame = srcRect;
    [self.tapedSuperView addSubview:self.previousImageBrowserCell.currentShowImageView];
    [self.previousImageBrowserCell.currentShowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(srcRect.origin.y);
        make.left.mas_equalTo(srcRect.origin.x);
        make.size.mas_equalTo(srcRect.size);
    }];
}


#pragma mark - Gesture Actions -
- (void)singleTapAction:(QAImageBrowserCell *)imageBrowserCell {
    [self getCurrentShowingImageView:imageBrowserCell];
    [self quitImageBrowser];
}
- (void)longPressAction:(QAImageBrowserCell *)imageBrowserCell {
    NSLog(@"%s",__func__);
}
- (void)handlePan:(UIPanGestureRecognizer *)panGesture {
    CGPoint transPoint = [panGesture translationInView:self.window];
    CGPoint velocity = [panGesture velocityInView:self.window];
    CGPoint locationInView = [panGesture locationInView:self.window];

    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            // 将cell中与其对应的imageView进行隐藏:
            [self hideImageViewInCell:YES];
            
            [self processQAImageBrowserCellWhenPanBegan];
        }
        break;

        case UIGestureRecognizerStateChanged: {
            [self.collectionView setScrollEnabled:NO];
            
            float alpha = 1 - fabs(transPoint.y) / self.windowBounds.size.height;
            alpha = MAX(alpha, 0.2);
            float scale = MAX(alpha, 0.6);
            CGFloat reduceValue = self.currentShowingImageView.bounds.size.width * (1-scale);
            reduceValue = ( (locationInView.x - self.currentShowingImageView.center.x ) / (self.currentShowingImageView.bounds.size.width/2) * reduceValue ) / 2;
            CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(transPoint.x / scale + reduceValue, transPoint.y / scale);
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
            CGAffineTransform totalTransform = CGAffineTransformConcat(translationTransform, scaleTransform);
            [self panViewWithTransform:totalTransform alpha:alpha paning:YES];
        }
        break;

        case UIGestureRecognizerStateEnded: {
            if (fabs(transPoint.y) > 160 || fabs(velocity.y) > 400) {
                [self quitImageBrowser];
            }
            else {
                [self panViewWithTransform:CGAffineTransformIdentity alpha:1 paning:NO];  // 返回到初始状态
            }

            [self.collectionView setScrollEnabled:YES];
        }
        break;

        case UIGestureRecognizerStateCancelled: {
            [self panViewWithTransform:CGAffineTransformIdentity alpha:1 paning:NO];  // 返回到初始状态
            [self.collectionView setScrollEnabled:YES];
        }
        break;

        default:{
            [self panViewWithTransform:CGAffineTransformIdentity alpha:1 paning:NO];  // 返回到初始状态
            [self.collectionView setScrollEnabled:YES];
        }
        break;
    }
}


#pragma mark - UICollectionView DataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == QAImageBrowser_headerIdentifier) {
    }
    else if (kind == QAImageBrowser_footerIdentifier) {
    }

    return nil;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QAImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:QAImageBrowser_cellID forIndexPath:indexPath];
    
    __weak typeof(self) weakself = self;
    cell.gestureActionBlock = ^(QAImageBrowserViewAction action, QAImageBrowserCell * _Nullable imageBrowserCell) {
        __strong typeof(self) strongSelf = weakself;
        switch (action) {
            case QAImageBrowserViewAction_SingleTap: {
                [strongSelf singleTapAction:imageBrowserCell];
            }
                break;
            case QAImageBrowserViewAction_LongPress: {
                [strongSelf longPressAction:imageBrowserCell];
            }
                break;

            default:
                break;
        }
    };
    NSDictionary *dic =  [self.images objectAtIndex:indexPath.row];
    
    [cell configContent:dic
           defaultImage:self.tapedImageView.image
            contentMode:self.tapedImageView.contentMode];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate -

/*
 // (when the touch begins)
 // 1. -collectionView:shouldHighlightItemAtIndexPath:
 // 2. -collectionView:didHighlightItemAtIndexPath:
 //
 // (when the touch lifts)
 // 3. -collectionView:shouldSelectItemAtIndexPath: or -collectionView:shouldDeselectItemAtIndexPath:
 // 4. -collectionView:didSelectItemAtIndexPath: or -collectionView:didDeselectItemAtIndexPath:
 // 5. -collectionView:didUnhighlightItemAtIndexPath:
 */

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"   didSelectItem (section - row) :  %ld - %ld", indexPath.section, indexPath.row);
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"   didDeselectItem (section - row) :  %ld - %ld", indexPath.section, indexPath.row);
}


#pragma mark - UIScrollView Delegate -
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentPosition inSection:0];
    QAImageBrowserCell *imageBrowserCell = (QAImageBrowserCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    self.previousImageBrowserCell = imageBrowserCell;
}
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
    else if (self.currentPosition == currentPage) {
        self.previousImageBrowserCell = nil;
        return;
    }
    
    self.currentPosition = currentPage;
    [self.previousImageBrowserCell.scrollView setZoomScale:1 animated:YES];
    
    [self makeTapedImageViewBacktoOriginalState];  // 将初次点击的imageView进行复位 (CollectionView.cell -> SRCTableView.cell)
}
- (void)makeTapedImageViewBacktoOriginalState {
    if (self.previousImageBrowserCell.imageView.hidden == YES) {
        NSLog(@" ----------------");
        self.previousImageBrowserCell.preparing = YES;
        [self makeTapedImageViewBacktoSrcTableView];
        [self.previousImageBrowserCell reprepareShowImageView];
        self.previousImageBrowserCell.preparing = NO;
    }
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
- (QAImageBrowserLayout *)layout {
    if (!_layout) {
        NSInteger itemCount = 1;
        CGFloat gap_left = 0;
        CGFloat gap_right = 0;
        NSInteger gap_lineSpace = 0;
        
        _layout = [[QAImageBrowserLayout alloc] init];
        _layout.itemWidth = UIWidth;
        _layout.itemHeight = UIHeight;
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemCountsPerLine = itemCount;
        _layout.leftSpace = gap_left;
        _layout.rightSpace = gap_right;
        _layout.lineSpace = gap_lineSpace;
        _layout.topSpace = 0;
        _layout.bottomSpace = 0;
    }
    
    return _layout;
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, UIWidth+PagesGap, UIHeight) collectionViewLayout:self.layout];
        
        if (@available(iOS 11.0, *)) {
            if ([_collectionView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
                _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        } else {
            // Fallback on earlier versions
        }
        
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        // 注册cell:
        [_collectionView registerClass:[QAImageBrowserCell class] forCellWithReuseIdentifier:QAImageBrowser_cellID];
        
        /*
         // 注册header:
         [_collectionView registerClass:[HeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:QAImageBrowser_headerIdentifier];

         // 注册footer:
         [_collectionView registerClass:[FooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:QAImageBrowser_footerIdentifier];
         */
    }
    
    return _collectionView;
}

@end
