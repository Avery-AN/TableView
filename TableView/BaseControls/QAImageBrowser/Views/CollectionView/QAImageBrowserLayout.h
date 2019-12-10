//
//  QAImageBrowserLayout.h
//  TableView
//
//  Created by Avery An on 2019/12/10.
//  Copyright © 2019 Avery. All rights reserved.
//


/*
 UICollectionViewLayout 的主要目标是提供关于 collection view 中每个元素的位置和可视化状态信息;
 UICollectionViewLayout 对象不会创建 cell 或者 supplementary view、它仅仅是用正确的属性提供它们。
 
 创建一个自定义的 UICollectionViewLayout 分为 3 个步骤:
 自定义一个抽象类UICollectionViewLayout的子类并声明所有你需要进行布局计算的属性;
 执行所有的计算、提供所有 collection view 的元素并正确设置它们的属性、这是最复杂的步骤，因为你必须从零开始实现 CollectionViewLayout 的核心逻辑;
 让 collection view 使用新的 CustomLayout 类。
 */


#import <UIKit/UIKit.h>

static NSString * _Nonnull const QAImageBrowser_cellID = @"CellID";
static NSString * _Nonnull const QAImageBrowser_headerIdentifier = @"HeadID";
static NSString * _Nonnull const QAImageBrowser_footerIdentifier = @"FootID";

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
