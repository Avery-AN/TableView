//
//  QAImageBrowserLayout.h
//  TableView
//
//  Created by Avery An on 2019/12/10.
//  Copyright © 2019 Avery. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * _Nonnull const QAImageBrowser_cellID = @"QAImageBrowser_cellID";
static NSString * _Nonnull const QAImageBrowser_headerIdentifier = @"QAImageBrowser_headerIdentifier";
static NSString * _Nonnull const QAImageBrowser_footerIdentifier = @"QAImageBrowser_footerIdentifier";

static int PagesGap = 10;  // 作为图片浏览器时使用(collectionView.scrollDirection = UICollectionViewScrollDirectionHorizontal)

NS_ASSUME_NONNULL_BEGIN

@interface QAImageBrowserLayout : UICollectionViewFlowLayout

// 布局方式(1)  (设定每行元素的个数、每个元素的大小、元素之间的间隔自适应):
@property (nonatomic, assign) NSInteger itemWidth;          // 元素的宽度 (需要注意水平方向上的宽度之和不要超过Collection的宽度)
@property (nonatomic, assign) NSInteger itemHeight;         // 元素的高度 (需要注意垂直方向上的高度之和不要超过Collection的高度)

// 布局方式(2)  (设定每行元素的个数、元素之间的间隔、元素大小自适应):
@property (nonatomic, assign) CGFloat itemSpace;            // 两个item之间的间距

// 公共参数:
@property (nonatomic, assign) NSInteger itemCountsPerLine;  // 每行元素的个数
@property (nonatomic, assign) NSInteger lineCounts;         // 行数
@property (nonatomic, assign) CGFloat lineSpace;            // 行间距 (需要注意垂直方向上的高度之和不要超过Collection的高度)
@property (nonatomic, assign) CGFloat leftSpace;            // item到左边框的间距 (需要注意水平方向上的宽度之和不要超过Collection的宽度)
@property (nonatomic, assign) CGFloat rightSpace;           // item到右边框的间距 (需要注意水平方向上的宽度之和不要超过Collection的宽度)
@property (nonatomic, assign) CGFloat topSpace;             // item到顶部的间距 (需要注意垂直方向上的高度之和不要超过Collection的高度)
@property (nonatomic, assign) CGFloat bottomSpace;          // item到底部的间距 (需要注意垂直方向上的高度之和不要超过Collection的高度)
@property (nonatomic, assign) CGFloat headerViewHeight;     // 头视图的高度
@property (nonatomic, assign) CGFloat footViewHeight;       // 尾视图的高度

@end

NS_ASSUME_NONNULL_END
