//
//  QAImageBrowserLayout.m
//  TableView
//
//  Created by Avery An on 2019/12/10.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "QAImageBrowserLayout.h"

@interface QAImageBrowserLayout ()
@property (nonatomic) NSMutableDictionary *cellLayoutInfo;    // 存放cell的布局
@property (nonatomic) NSMutableDictionary *headerLayoutInfo;  // 存放header的布局
@property (nonatomic) NSMutableDictionary *footerLayoutInfo;  // 存放footer的布局
@property (nonatomic) NSMutableDictionary *bottomYForItem;
@property (nonatomic) NSMutableDictionary *bottomRightForItem;
@property (nonatomic, assign) CGFloat currentContentHeight;         // 当前内容的高度
@property (nonatomic, assign) CGFloat currentContentWidth;          // 当前内容的宽度
@end


@implementation QAImageBrowserLayout

#pragma mark - Rewrite Method -
- (void)prepareLayout {
    [super prepareLayout];
    
    // 重新布局、需要清空数据:
    [self.cellLayoutInfo removeAllObjects];
    [self.headerLayoutInfo removeAllObjects];
    [self.footerLayoutInfo removeAllObjects];
    self.currentContentHeight = 0;
    self.currentContentWidth = 0;
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        [self processVerticalLayout];
    }
    else {
        [self processHorizontalLayout];
    }
}

/**
 * 决定cell的布局属性
 */
- (nullable NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray array];
    
    // 添加当前屏幕可见的cell的布局:
    [self.cellLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [allAttributes addObject:attribute];
        }
     }];
    
    // 添加当前屏幕可见的头视图的布局:
    [self.headerLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
         if (CGRectIntersectsRect(rect, attribute.frame)) {
             [allAttributes addObject:attribute];
         }
     }];
    
    // 添加当前屏幕可见的尾部的布局:
    [self.footerLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
         if (CGRectIntersectsRect(rect, attribute.frame)) {
             [allAttributes addObject:attribute];
         }
     }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([elementKind isEqualToString:@"UICollectionElementKindSectionHeader"]) {
        attribute = self.headerLayoutInfo[indexPath];
    }
    else if ([elementKind isEqualToString:@"UICollectionElementKindSectionFooter"]){
        attribute = self.footerLayoutInfo[indexPath];
    }
    
    return attribute;
}

/**
 * 内容的高度
 */
- (CGSize)collectionViewContentSize {
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return CGSizeMake(self.collectionView.frame.size.width, MAX(self.currentContentHeight, self.collectionView.frame.size.height));
    }
    else {
        return CGSizeMake(MAX(self.currentContentWidth, self.collectionView.frame.size.width), self.collectionView.frame.size.height);
    }
}


#pragma mark - Private Method -
- (void)processHorizontalLayout {
    CGFloat collectionViewW = self.collectionView.bounds.size.width;
    collectionViewW = collectionViewW - PagesGap;
    NSInteger sectionsCount = [self.collectionView numberOfSections];  //获取section的个数
    
    for (NSInteger section = 0; section < sectionsCount; section++) {
        NSInteger rowCounts = [self.collectionView numberOfItemsInSection:section]; //每个section里row的总数
        
        CGFloat itemWidth = self.itemWidth;
        CGFloat itemHeight = self.itemHeight;
        CGFloat itemSpace = self.itemSpace;
        if (self.itemSpace - 0 > 0) {
            itemWidth = (collectionViewW - self.leftSpace - self.rightSpace - (self.itemCountsPerLine - 1) * self.itemSpace) / self.itemCountsPerLine;
            itemHeight = itemWidth;
        }
        else {
            NSInteger totalWidth = (collectionViewW - self.leftSpace - self.rightSpace - itemWidth*self.itemCountsPerLine);
            if (totalWidth == 0) {
                itemSpace = 0;
            }
            else if (totalWidth < 0) {
                NSLog(@"FUCK U ~~~");
                return;
            }
            else {
                if (self.itemCountsPerLine > 1) {
                    itemSpace = totalWidth / (self.itemCountsPerLine-1);
                }
                else {
                    itemSpace = totalWidth / 2;
                }
            }
        }
        
        for (NSInteger row = 0; row < rowCounts; row++) {
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:row inSection:section];
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndexPath];
            
            CGFloat startY = self.topSpace;
            CGFloat startX = self.leftSpace + (itemSpace + itemWidth) * (row%self.itemCountsPerLine);
            startX = startX + (itemSpace + itemWidth) * (row/self.itemCountsPerLine);
            CGFloat offsetX = row * PagesGap;
            CGFloat offsetWidth = (row+1) * PagesGap;
            attribute.frame = CGRectMake(startX+offsetX, startY, itemWidth, itemHeight);
            self.bottomRightForItem[@(row)] = @(startX + (itemSpace + itemWidth) + offsetWidth);
            
            //保存cell的布局对象:
            self.cellLayoutInfo[cellIndexPath] = attribute;
        }
        self.currentContentWidth = [self.bottomRightForItem[@(rowCounts-1)] floatValue];
    }
}
- (void)processVerticalLayout {
    CGFloat collectionViewW = self.collectionView.frame.size.width;
    NSInteger sectionsCount = [self.collectionView numberOfSections];  //获取section的个数
    
    for (NSInteger section = 0; section < sectionsCount; section++) {
        NSInteger rowCounts = [self.collectionView numberOfItemsInSection:section]; //每个section里row的总数
        
        /** // 【1】处理headerView:
         NSIndexPath *supplementaryViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
         if ([self.collectionView.dataSource respondsToSelector:@selector(collectionView: viewForSupplementaryElementOfKind:atIndexPath:)]) {
             UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:QAImageBrowser_headerIdentifier withIndexPath:supplementaryViewIndexPath];
             attribute.frame = CGRectMake(0, self.currentContentHeight, self.collectionView.frame.size.width, _headerViewHeight);
             
             //保存布局对象:
             self.headerLayoutInfo[supplementaryViewIndexPath] = attribute;
             
             //设置下个布局对象的开始Y值:
             self.currentContentHeight = self.currentContentHeight + _headerViewHeight;
         }
        */
        
        // *** 【2】处理cell:
        CGFloat itemWidth = self.itemWidth;
        CGFloat itemHeight = self.itemHeight;
        CGFloat itemSpace = self.itemSpace;
        
        // 将Section里每个cell的frame的Y值进行初始设置:
        for (int i = 0; i < rowCounts; i++) {
            self.bottomYForItem[@(i)] = @(self.currentContentHeight);
        }
        
        if (self.itemSpace - 0 > 0) {
            //计算item的宽度(纵向滑动的列表里这个是固定的)
            itemWidth = (collectionViewW - self.leftSpace - self.rightSpace - (self.itemCountsPerLine - 1) * self.itemSpace) / self.itemCountsPerLine;
            itemHeight = itemWidth;
        }
        else {
            NSInteger totalWidth = (collectionViewW - self.leftSpace - self.rightSpace - itemWidth*self.itemCountsPerLine);
            if (totalWidth == 0) {
                itemSpace = 0;
            }
            else if (totalWidth < 0) {
                NSLog(@"FUCK U ~~~");
                return;
            }
            else {
                if (self.itemCountsPerLine > 1) {
                    itemSpace = totalWidth / (self.itemCountsPerLine-1);
                }
                else {
                    itemSpace = totalWidth / 2;
                }
            }
        }
        
        for (NSInteger row = 0; row < rowCounts; row++) {
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:row inSection:section];
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndexPath];
            
            CGFloat startY = [self.bottomYForItem[@(row)] floatValue];
            CGFloat startX = self.leftSpace + (itemSpace + itemWidth) * (row%self.itemCountsPerLine);
            if (row < self.itemCountsPerLine) {
                startY = startY + self.topSpace;
            }
            else {
                startY = startY + self.topSpace + (self.lineSpace + itemHeight) * (row/self.itemCountsPerLine);
            }
            attribute.frame = CGRectMake(startX, startY, itemWidth, itemHeight);
            self.bottomYForItem[@(row)] = @(startY);
            
            //保存cell的布局对象:
            self.cellLayoutInfo[cellIndexPath] = attribute;
        }
        self.currentContentHeight = [self.bottomYForItem[@(rowCounts-1)] floatValue] + (self.lineSpace + itemHeight) + self.bottomSpace;
        
        
        /** // 【3】处理footerView:
         if ([self.collectionView.dataSource respondsToSelector:@selector(collectionView: viewForSupplementaryElementOfKind:atIndexPath:)]) {
             UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:QAImageBrowser_footerIdentifier withIndexPath:supplementaryViewIndexPath];
             
             attribute.frame = CGRectMake(0, self.currentContentHeight, self.collectionView.frame.size.width, _footViewHeight);
             self.footerLayoutInfo[supplementaryViewIndexPath] = attribute;
             self.currentContentHeight = self.currentContentHeight + _footViewHeight;
         }
         */
    }
}


#pragma mark - Property -
- (NSMutableDictionary *)cellLayoutInfo {
    if (!_cellLayoutInfo) {
        _cellLayoutInfo = [NSMutableDictionary dictionary];
    }
    
    return _cellLayoutInfo;
}
- (NSMutableDictionary *)headerLayoutInfo {
    if (!_headerLayoutInfo) {
        _headerLayoutInfo = [NSMutableDictionary dictionary];
    }
    
    return _headerLayoutInfo;
}
- (NSMutableDictionary *)footerLayoutInfo {
    if (!_footerLayoutInfo) {
        _footerLayoutInfo = [NSMutableDictionary dictionary];
    }
    
    return _footerLayoutInfo;
}
- (NSMutableDictionary *)bottomYForItem {
    if (!_bottomYForItem) {
        _bottomYForItem = [NSMutableDictionary dictionary];
    }
    
    return _bottomYForItem;
}
- (NSMutableDictionary *)bottomRightForItem {
    if (!_bottomRightForItem) {
        _bottomRightForItem = [NSMutableDictionary dictionary];
    }
    
    return _bottomRightForItem;
}

@end
