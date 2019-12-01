////
////  QAImageBrowserViewController.m
////  Avery
////
////  Created by Avery on 2018/8/31.
////  Copyright © 2018年 Avery. All rights reserved.
////
//
//#import "QAImageBrowserViewController.h"
////#import "PhotoManager.h"
//
//static NSInteger DefaultTag = 10;
//
//@interface QAImageBrowserViewController () <UIScrollViewDelegate>
//@property (nonatomic) UIScrollView *scrollView;
//@property (nonatomic) NSArray *objects;
//@property (nonatomic, assign) NSInteger startPosition; //起始位置(初次进入预览页面时的位置)
//@property (nonatomic, assign) NSInteger currentPosition;
//@property (nonatomic) CGRect startRect;
//@property (nonatomic, assign) NSInteger itemCountsPerline;
//@property (nonatomic, assign) CGFloat imageGap_h;
//@property (nonatomic, assign) CGFloat imageGap_v;
//@end
//
//@implementation QAImageBrowserViewController
//
//#pragma mark - Life Cycle -
//- (void)dealloc {
//    NSLog(@"   %s",__func__);
//}
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    
//    [self.view addSubview:self.scrollView];
//}
//
//
//#pragma mark - Public Api -
///**
// 浏览一组图片 (本地 OR 网络图片)
// 
// @param objects 存放需要预览的一组图片
// @param currentPosition 当前点击的图片在这一组图片中的位置
// @param currentImage 当前点击的图片
// @param currentImageFrame 当前点击的图片的frame大小
// */
//- (void)showImageWithObjects:(NSArray *)objects
//             currentPosition:(NSInteger)currentPosition
//                currentImage:(UIImage *)currentImage
//           currentImageFrame:(CGRect)currentImageFrame {
//    
//    self.objects = objects;
//    self.startPosition = currentPosition;
//    self.currentPosition = currentPosition;
//    self.startRect = currentImageFrame;
//    
//    // 设置scrollView的展示区域以及当前图片展示的位置:
//    self.scrollView.contentSize = CGSizeMake(VIEWWIDTH*objects.count, VIEWHEIGHT);
//    self.scrollView.contentOffset = CGPointMake(VIEWWIDTH*currentPosition, 0);
//    
//    // 展示当前所点击的图片:
//    [self showCurrentImage:currentImage
//         currentImageFrame:currentImageFrame
//                  inImages:objects
//           currentPosition:currentPosition];
//    
//    // 处理其他图片:
//    [self processOtherImages:objects
//             currentPosition:currentPosition];
//}
//
///**
// 浏览一组图片 (本地 OR 网络图片)
// 
// @param objects 存放需要预览的一组图片
// @param currentPosition 当前点击的图片在这一组图片中的位置
// @param currentImage 当前点击的图片
// @param currentImageFrame 当前点击的图片的frame大小
// @param imageGap_h 九宫格中图片之间的左右间隔
// @param imageGap_v 九宫格中图片之间的上下间隔
// @param itemCounts 每行item的个数
// */
//- (void)showImageWithObjects:(NSArray *)objects
//             currentPosition:(NSInteger)currentPosition
//                currentImage:(UIImage *)currentImage
//           currentImageFrame:(CGRect)currentImageFrame
//                  imageGap_h:(CGFloat)imageGap_h
//                  imageGap_v:(CGFloat)imageGap_v
//                  itemCounts:(NSInteger)itemCounts {
//    self.imageGap_h = imageGap_h;
//    self.imageGap_v = imageGap_v;
//    self.itemCountsPerline = itemCounts;
//    self.startRect = currentImageFrame;
//    
//    [self showImageWithObjects:objects
//               currentPosition:currentPosition
//                  currentImage:currentImage
//             currentImageFrame:currentImageFrame];
//}
//
//
//#pragma mark - Private Methods -
//- (void)showCurrentImage:(UIImage *)currentImage
//       currentImageFrame:(CGRect)currentImageFrame
//                inImages:(NSArray *)objects
//         currentPosition:(NSInteger)currentPosition {
//    
//    // 处理当前点击的图片:
//    [self processCurrentImage:currentImage
//            currentImageFrame:(CGRect)currentImageFrame
//                     inImages:objects
//              currentPosition:currentPosition];
//}
//- (void)processCurrentImage:(UIImage *)currentImage
//          currentImageFrame:(CGRect)currentImageFrame
//                   inImages:(NSArray *)objects
//            currentPosition:(NSInteger)currentPosition {
//    [self.scrollView setContentOffset:CGPointMake(currentPosition*VIEWWIDTH, 0)];
//    
//    QAImageBrowserView *imageBrowserView = [[QAImageBrowserView alloc] init];
//    imageBrowserView.tag = currentPosition + DefaultTag;
//    
//    __weak typeof(self) weakself = self;
//    imageBrowserView.actionBlock = ^(QAImageBrowserViewAction action, id _Nullable object) {
//        switch (action) {
//            case QAImageBrowserViewAction_SingleTap: {
//                [weakself dismiss:object];
//            }
//                break;
//            case QAImageBrowserViewAction_LongPress: {
//                [weakself longPress:object];
//            }
//                break;
//                
//            default:
//                break;
//        }
//    };
//    
//    if (currentImage) {
//        [imageBrowserView showImage:currentImage];
//    }
//    else {
//        NSString *imageAddress = [objects objectAtIndex:currentPosition];
//        if (!imageAddress || ![imageAddress isKindOfClass:[NSString class]] || imageAddress.length == 0) {
//            return;
//        }
//        NSURL *imageUrl = [NSURL URLWithString:imageAddress];
//        [imageBrowserView showImageWithImageAddress:imageUrl];
//    }
//    CGRect frame_normal = imageBrowserView.imageView.frame;
//    
//    CGRect frame = imageBrowserView.frame;
//    frame.origin.x = VIEWWIDTH * currentPosition + frame.origin.x;
//    imageBrowserView.frame = frame;
//    [self.scrollView addSubview:imageBrowserView];
//    
//    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
//    imageBrowserView.imageView.frame = currentImageFrame;
//    [UIView animateWithDuration:0.25
//                     animations:^{
//                         self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
//                         imageBrowserView.imageView.frame = frame_normal;
//                     } completion:^(BOOL finished) {
//                         if (finished) {
//                         }
//                     }];
//}
//- (void)processOtherImages:(NSArray *)objects
//           currentPosition:(NSInteger)currentPosition {
//    for (int i = 0; i < objects.count; i++) {
//        id object = [objects objectAtIndex:i];
//        if (i == currentPosition) {
//            continue;
//        }
//        UIImage *currentImage = nil;
//        NSString *imageAddress = nil;
//        if ([object isKindOfClass:[UIImage class]]) {
//            currentImage = (UIImage *)object;
//        }
//        else if ([object isKindOfClass:[NSString class]]) {
//            imageAddress = (NSString *)object;
//        }
//        
//        QAImageBrowserView *imageBrowserView = [[QAImageBrowserView alloc] init];
//        imageBrowserView.tag = i + DefaultTag;
//        __weak typeof(self) weakself = self;
//        imageBrowserView.actionBlock = ^(QAImageBrowserViewAction action, id _Nullable object) {
//            switch (action) {
//                case QAImageBrowserViewAction_SingleTap: {
//                    [weakself dismiss:object];
//                }
//                    break;
//                case QAImageBrowserViewAction_LongPress: {
//                    [weakself longPress:object];
//                }
//                    break;
//                    
//                default:
//                    break;
//            }
//        };
//        
//        if (currentImage) {
//            [imageBrowserView showImage:currentImage];
//        }
//        else {
//            if (!imageAddress || ![imageAddress isKindOfClass:[NSString class]] || imageAddress.length == 0) {
//                return;
//            }
//            NSURL *imageUrl = [NSURL URLWithString:imageAddress];
//            [imageBrowserView showImageWithImageAddress:imageUrl];
//        }
//        
//        CGRect frame = imageBrowserView.frame;
//        frame.origin.x = VIEWWIDTH * i;
//        imageBrowserView.frame = frame;
//        [self.scrollView addSubview:imageBrowserView];
//    }
//}
//- (CGRect)getOriginalFrameWithCurrentPosition {
//    CGRect originalFrame = CGRectZero;
//    
//    // 只有一张图片时需要特殊处理 (因为只有一张图片时、不涉及到图片之间的间隔以及单张图片的大小会比较大等问题)
//    if (self.objects.count == 1) {
//        originalFrame = self.startRect;
//    }
//    else {
//        NSInteger line = self.currentPosition / self.itemCountsPerline; //当前position位置的图片位于九宫格中的第几行
//        NSInteger row = self.currentPosition % self.itemCountsPerline; //当前position位置的图片位于某行的第几列
//        NSInteger line_start = self.startPosition / self.itemCountsPerline; //初次点击的图片位于九宫格中的第几行
//        NSInteger row_start = self.startPosition % self.itemCountsPerline; //初次点击的图片位于某行的第几列
//        if (line == line_start && row == row_start) {
//            originalFrame = self.startRect;
//        }
//        else {
//            CGFloat itemWidth = self.startRect.size.width;
//            CGFloat itemHeight = self.startRect.size.height;
//            
//            CGFloat gap_side = (VIEWWIDTH - itemWidth*self.itemCountsPerline - self.imageGap_h*(self.itemCountsPerline-1)) / 2.; //与屏幕的间距(左间距 & 右间距)
//            
//            CGFloat startX = gap_side + row*itemWidth + row*self.imageGap_h;
//            CGFloat startY = 0;
//            CGFloat difference_lineHeight = itemHeight + self.imageGap_v; //两行之间的高度差
//            NSInteger difference_position = self.currentPosition - self.startPosition; //当前的位置与初始位置之间的位置差
//            if (difference_position > 0) {
//                NSInteger difference_line = line - line_start; //行数差
//                startY = self.startRect.origin.y + difference_line * difference_lineHeight;
//            }
//            else {
//                NSInteger difference_line = line_start - line; //行数差
//                startY = self.startRect.origin.y - difference_line * difference_lineHeight;
//            }
//            originalFrame = CGRectMake(startX, startY, itemWidth, itemHeight);
//        }
//    }
//    
//    return originalFrame;
//}
//
//
//#pragma mark - Actions -
//- (void)dismiss:(id)object {
//    if (self.itemCountsPerline <= 0) {   //没有给itemCountsPerline赋值的情况
//        [self dismiss_default:object];
//    }
//    else if (self.itemCountsPerline > 0) {
//        [self dismiss_originalLocation:object];
//    }
//    else {
//        
//    }
//}
//- (void)dismiss_default:(id)object {
//    QAImageBrowserView *imageBrowserView = (QAImageBrowserView *)object;
//    [UIView animateWithDuration:0.25
//                     animations:^{
//                         self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
//                         imageBrowserView.alpha = 0;
//                     }
//                     completion:^(BOOL finished) {
//                         if (finished) {
//                             [self.view removeFromSuperview];
//                             if (self.actionBlock) {
//                                 self.actionBlock(QAImageBrowserViewAction_SingleTap, self);
//                             }
//                         }
//                     }];
//}
//- (void)dismiss_originalLocation:(id)object {
//    QAImageBrowserView *imageBrowserView = (QAImageBrowserView *)object;
//    CGRect originalFrame = [self getOriginalFrameWithCurrentPosition];
//    
//    if (imageBrowserView.scrollView.zoomScale - 1. > 0) {
//        [imageBrowserView.scrollView setZoomScale:1 animated:NO];
//    }
//    
//    [UIView animateWithDuration:0.25
//                     animations:^{
//                         self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
//                         imageBrowserView.imageView.frame = originalFrame;
//                     }
//                     completion:^(BOOL finished) {
//                         if (finished) {
//                             [self.view removeFromSuperview];
//                             self.itemCountsPerline = 0;
//                             if (self.actionBlock) {
//                                 self.actionBlock(QAImageBrowserViewAction_SingleTap, self);
//                             }
//                         }
//                     }];
//}
//
//- (CGRect)zoomRect:(UIScrollView *)scrollView withScale:(CGFloat)scale centerPoint:(CGPoint)center {
//    CGRect zoomRect;
//    
//    zoomRect.size.height = [scrollView frame].size.height/scale;
//    zoomRect.size.width = [scrollView frame].size.width/scale;
//    
//    zoomRect.origin.x = center.x - zoomRect.size.width/2;
//    zoomRect.origin.y = center.y - zoomRect.size.height/2;
//    
//    return zoomRect;
//}
//
//- (void)longPress:(id)object {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    
//    UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:@"下载图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////        QAImageBrowserView *imageBrowserView = (QAImageBrowserView *)object;
////        [PhotoManager saveImageToAlbum:imageBrowserView.imageView.image];
//    }];
//    [alert addAction:downloadAction];
//    
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    [alert addAction:cancelAction];
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self presentViewController:alert animated:YES completion:^{
//        }];
//    });
//}
//
//
//#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    CGFloat pageWidth = scrollView.frame.size.width;
//    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    
//    if (currentPage < 0 || currentPage >= self.objects.count) {
//        return;
//    }
//    
//    if (self.currentPosition - currentPage > 0) {   //手指往右滑
//        
//    }
//    else {
//        
//    }
//    QAImageBrowserView *previousPageView = [scrollView viewWithTag:(self.currentPosition+DefaultTag)];
//    if (previousPageView) {
//        [previousPageView.scrollView setZoomScale:1 animated:YES];
//    }
//    self.currentPosition = currentPage;
//}
//
//
//#pragma mark - Property -
//- (UIScrollView *)scrollView {
//    if (!_scrollView) {
//        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//        _scrollView.delegate = self;
//        _scrollView.showsVerticalScrollIndicator = NO;
//        _scrollView.showsHorizontalScrollIndicator = NO;
//        _scrollView.alwaysBounceHorizontal = YES;
//        _scrollView.pagingEnabled = YES;
//    }
//    return _scrollView;
//}

//
//#pragma mark - 内存警告 -
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
//@end
