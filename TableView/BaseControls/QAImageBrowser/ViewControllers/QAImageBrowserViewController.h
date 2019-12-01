////
////  QAImageBrowserViewController.h
////  Avery
////
////  Created by Avery on 2018/8/31.
////  Copyright © 2018年 Avery. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//#import "QAImageBrowserView.h"
//
//@interface QAImageBrowserViewController : UIViewController
//
//@property (nonatomic, copy) void(^ _Nullable actionBlock) (QAImageBrowserViewAction action, id _Nullable object);
//
//
///**
// 浏览一组图片 (本地 OR 网络图片)
// 
// @param objects 存放需要预览的一组图片
// @param currentPosition 当前点击的图片在这一组图片中的位置
// @param currentImage 当前点击的图片
// @param currentImageFrame 当前点击的图片的frame大小
// */
//- (void)showImageWithObjects:(NSArray *_Nonnull)objects
//             currentPosition:(NSInteger)currentPosition
//                currentImage:(UIImage *_Nonnull)currentImage
//           currentImageFrame:(CGRect)currentImageFrame;
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
//- (void)showImageWithObjects:(NSArray *_Nonnull)objects
//             currentPosition:(NSInteger)currentPosition
//                currentImage:(UIImage *_Nonnull)currentImage
//           currentImageFrame:(CGRect)currentImageFrame
//                  imageGap_h:(CGFloat)imageGap_h
//                  imageGap_v:(CGFloat)imageGap_v
//                  itemCounts:(NSInteger)itemCounts;
//
//@end
