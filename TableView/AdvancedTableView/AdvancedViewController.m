//
//  AdvancedViewController.m
//  TestProject
//
//  Created by Avery An on 2019/8/25.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "AdvancedViewController.h"
#import "AdvancedCell.h"
#import "AdvancedCell+SelfManager.h"
#import "AdvancedDataManager.h"
#import "QAImageBrowserManager.h"
#import "TrapezoidalCell.h"

static NSInteger TrapezoidalLineHeight = 56;

@interface AdvancedViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSMutableArray *showDatas;
@property (nonatomic, assign) __block BOOL setOldValue;  // 监听时使用
@property (nonatomic, assign) __block CGFloat oldValue;  // 监听时使用
@property (nonatomic, assign) CGFloat currentValue;      // 监听时使用
@property (nonatomic, assign) BOOL donotDrawCell;   // 不需要绘制Cell (当滑动的速度太快达到某个限定的值时就不需要绘制Cell了)
@property (nonatomic) UITableView *tableView;
@property (nonatomic, assign) int frameCount;  // 累积帧数
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic) __block CADisplayLink *displayLink;
@property (nonatomic) dispatch_source_t timer;
@property (nonatomic) QAImageBrowserManager *imageBrowserManager;
@property (nonatomic) NSMutableDictionary *trapezoidalDic_index2;
@property (nonatomic) NSMutableDictionary *trapezoidalDic_index3;
@end


@implementation AdvancedViewController

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@"%s",__func__);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self performSelector:@selector(generateContent) withObject:nil afterDelay:0];  // 模拟服务器端数据(get数据)
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self performSelector:@selector(setFPS) withObject:nil afterDelay:.2];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self destroyDisplayLink];
}


#pragma mark - Private Methods -
- (void)setFPS {
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}
- (void)destroyDisplayLink {
    if (self.displayLink) {
        [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink.paused = YES;
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

/**
 模拟网络请求
 */
- (void)generateContent {
    {   // 这里只生成第2行的数据:
        self.trapezoidalDic_index2 = [NSMutableDictionary dictionary];
        
        [self.trapezoidalDic_index2 setValue:@"label style" forKey:@"name"];
        NSInteger startX = TrapezoidalCell_Avatar_left_gap+TrapezoidalCell_AvatarSize+TrapezoidalCell_Avatar_title_gap;
        NSInteger Title_width = UIWidth - TrapezoidalCell_Title_gap_right - startX;
        CGRect name_frame = CGRectMake(startX, Avatar_top_gap, Title_width, Title_height);
        [self.trapezoidalDic_index2 setValue:[NSValue valueWithCGRect:name_frame] forKey:@"name-frame"];
        
        [self.trapezoidalDic_index2 setValue:@"测试label样式" forKey:@"desc"];
        CGRect desc_frame = CGRectMake(startX, TrapezoidalCell_Avatar_top_gap+TrapezoidalCell_AvatarSize-Desc_height, Title_width, Desc_height);
        [self.trapezoidalDic_index2 setValue:[NSValue valueWithCGRect:desc_frame] forKey:@"desc-frame"];
        
        NSMutableDictionary *style = [NSMutableDictionary dictionary];
        [style setValue:[UIFont systemFontOfSize:14] forKey:@"font"];
        [style setValue:HEXColor(@"333333") forKey:@"textColor"];
        [self.trapezoidalDic_index2 setValue:style forKey:@"name-style"];
        
        [self.trapezoidalDic_index2 setValue:@"https://upload-images.jianshu.io/upload_images/19956441-90202bedb62e0c90.jpg" forKey:@"avatar"];
        CGRect avatar_frame = CGRectMake(TrapezoidalCell_Avatar_left_gap, TrapezoidalCell_Avatar_top_gap, TrapezoidalCell_AvatarSize, TrapezoidalCell_AvatarSize);
        [self.trapezoidalDic_index2 setValue:[NSValue valueWithCGRect:avatar_frame] forKey:@"avatar-frame"];
        
        
        [self.trapezoidalDic_index2 setValue:[self.trapezoidalDic_index2 valueForKey:@"avatar"] forKey:@"contentImageView"];
        CGFloat imageWidth = UIWidth - TrapezoidalCell_ContentImageView_left - TrapezoidalCell_ContentImageView_right;
        CGFloat imageHeight = imageWidth / TrapezoidalCell_ContentImageView_width_height_rate;
        CGFloat imageY = TrapezoidalCell_Avatar_top_gap + TrapezoidalCell_AvatarSize + TrapezoidalCell_Avatar_content_gap;
        [self.trapezoidalDic_index2 setValue:[NSValue valueWithCGRect:CGRectMake(TrapezoidalCell_ContentImageView_left, imageY, imageWidth, imageHeight)] forKey:@"contentImageView-frame"];
        
        
        NSMutableArray *texts = [NSMutableArray array];
        [texts addObject:@"其它样式的Label"];
        [texts addObject:@"[nezha] Tiktok [nezha]"];
        [texts addObject:@"将点击背景处理成#圆角#"];
        [self.trapezoidalDic_index2 setValue:texts forKey:@"trapezoidalTexts"];
        CGFloat contentHeight = texts.count*TrapezoidalLineHeight;  // 这里只是临时计算
        CGFloat contentY = imageY + imageHeight + TrapezoidalCell_ContentImageView_bottomControl_gap;
        CGRect content_frame = CGRectMake(TrapezoidalCell_Content_left, contentY, UIWidth - (TrapezoidalCell_Content_left+TrapezoidalCell_Content_right), contentHeight);
        [self.trapezoidalDic_index2 setValue:[NSValue valueWithCGRect:content_frame] forKey:@"content-frame"];
        
        CGFloat cellHeight = contentY + contentHeight+TrapezoidalCell_Content_bottom;
        CGRect cell_frame = CGRectMake(0, 0, UIWidth, cellHeight);
        [self.trapezoidalDic_index2 setValue:[NSValue valueWithCGRect:cell_frame] forKey:@"cell-frame"];
        
        
        
        self.trapezoidalDic_index3 = [[NSMutableDictionary alloc] initWithDictionary:self.trapezoidalDic_index2];
        [self.trapezoidalDic_index3 setValue:@"https://upload-images.jianshu.io/upload_images/11206370-77f9900187553dca" forKey:@"avatar"];
        [self.trapezoidalDic_index3 setValue:@"https://upload-images.jianshu.io/upload_images/11206370-77f9900187553dca" forKey:@"contentImageView"];
        [self.trapezoidalDic_index3 setValue:[NSValue valueWithCGRect:name_frame] forKey:@"name-frame"];
        [self.trapezoidalDic_index3 setValue:[NSValue valueWithCGRect:desc_frame] forKey:@"desc-frame"];
        NSMutableArray *texts_ = [NSMutableArray array];
        [texts_ addObject:@"左对齐Label"];
        [texts_ addObject:@"Tiktok"];
        [texts_ addObject:@"#圆角#点击背景😃"];
        [self.trapezoidalDic_index3 setValue:texts_ forKey:@"trapezoidalTexts"];
        contentHeight = texts_.count*TrapezoidalLineHeight;  // 这里只是临时计算
        contentY = imageY + imageHeight + TrapezoidalCell_ContentImageView_bottomControl_gap;
        content_frame = CGRectMake(TrapezoidalCell_Content_left, contentY, UIWidth - (TrapezoidalCell_Content_left+TrapezoidalCell_Content_right), contentHeight);
        [self.trapezoidalDic_index3 setValue:[NSValue valueWithCGRect:content_frame] forKey:@"content-frame"];
        
        cellHeight = contentY + contentHeight+TrapezoidalCell_Content_bottom;
        cell_frame = CGRectMake(0, 0, UIWidth, cellHeight);
        [self.trapezoidalDic_index3 setValue:[NSValue valueWithCGRect:cell_frame] forKey:@"cell-frame"];
    }
    
    {   // 生成其它行的数据:
        NSMutableArray *originalDatas = [AdvancedDataManager getDatas];
        [self processDatas:originalDatas];
    }
}
- (void)processDatas:(NSMutableArray *)originalDatas {
    if (!self.showDatas) {
        self.showDatas = [NSMutableArray arrayWithCapacity:0];
    }
    else {
        [self.showDatas removeAllObjects];
    }
    
    /*
     maxConcurrentOperationCount的主要作用是加快首屏cell的渲染
     maxConcurrentOperationCount的值可以根据cell的height以及tableView.contentView.height来计算
     */
    NSInteger maxConcurrentOperationCount = 5;
    if (originalDatas.count < maxConcurrentOperationCount) {
        maxConcurrentOperationCount = originalDatas.count;
    }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:maxConcurrentOperationCount];
    [AdvancedCell getStytle:originalDatas maxConcurrentOperationCount:maxConcurrentOperationCount completion:^(NSInteger start, NSInteger end) {
        // NSLog(@"已获取到新数据: %ld - %ld", (long)start , (long)end);
        
        [indexPaths removeAllObjects];
        for (NSInteger i = start; i <= end; i++) {
            [self.showDatas addObject:[originalDatas objectAtIndex:i]];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPaths addObject:indexPath];
        }
        if (self.tableView.superview == nil) {
            [self.view addSubview:self.tableView];
            // [self observerTableviewVelocity];
        }
        else {
            // [self.tableView reloadData];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}


#pragma mark - DataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showDatas.count+2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        NSValue *value = [self.trapezoidalDic_index2 valueForKey:@"cell-frame"];
        CGRect rect = value.CGRectValue;
        return rect.size.height;
    }
    else if (indexPath.row == 3) {
        NSValue *value = [self.trapezoidalDic_index3 valueForKey:@"cell-frame"];
        CGRect rect = value.CGRectValue;
        return rect.size.height;
    }
    else {
        NSDictionary *dic = nil;
        if (indexPath.row <= 2) {
            dic = [self.showDatas objectAtIndex:indexPath.row];
        }
        else {
            dic = [self.showDatas objectAtIndex:indexPath.row-2];
        }
        CGRect cellFrame = [[dic valueForKey:@"cell-frame"] CGRectValue];
        NSInteger defaultHeight = Avatar_top_gap + AvatarSize + Avatar_bottomControl_gap;
        return cellFrame.size.height - defaultHeight > 0 ? cellFrame.size.height : defaultHeight;
    }
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row == 2 || indexPath.row == 3) {
        TrapezoidalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrapezoidalCell"];
        if (cell == nil) {
            cell = [[TrapezoidalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TrapezoidalCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            __weak typeof(self) weakSelf = self;
            cell.baseCellTapAction = ^(BaseCell *cell, BaseCell_TapedStyle style, NSString * _Nonnull content) {
                NSLog(@"   TrapezoidalCell-TapAction style: %lu; content: %@", (unsigned long)style, content);
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf tapedAdvancedCell:cell tapedStyle:style content:content];
            };
            cell.content.QAAttributedLabelTapAction = ^(NSString * _Nullable content, QAAttributedLabel_TapedStyle style) {
                NSLog(@"   TrapezoidalCell-Label-TapAction: %@; style: %lu", content, (unsigned long)style);
            };
        }
        
        if (indexPath.row == 2) {
            cell.trapezoidalLabel.highLightTexts = nil;
            cell.trapezoidalLabel.textAlignment = NSTextAlignmentCenter;
            [cell setTrapezoidalTexts:self.trapezoidalDic_index2 lineHeight:TrapezoidalLineHeight];
        }
        else {
            cell.trapezoidalLabel.highLightTexts = [NSArray arrayWithObject:@"Tiktok"];
            cell.trapezoidalLabel.textAlignment = NSTextAlignmentLeft;
            // cell.trapezoidalLabel.textAlignment = NSTextAlignmentRight;
            [cell setTrapezoidalTexts:self.trapezoidalDic_index3 lineHeight:TrapezoidalLineHeight];
        }

        return cell;
    }
    else {
        AdvancedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdvancedCell"];
        if (cell == nil) {
            cell = [[AdvancedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AdvancedCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            __weak typeof(self) weakSelf = self;
            cell.baseCellTapAction = ^(BaseCell *cell, BaseCell_TapedStyle style, NSString * _Nonnull content) {
                NSLog(@"   AdvancedCell-TapAction style: %lu; content: %@", (unsigned long)style, content);
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf tapedAdvancedCell:cell tapedStyle:style content:content];
            };
            cell.content.QAAttributedLabelTapAction = ^(NSString * _Nullable content, QAAttributedLabel_TapedStyle style) {
                NSLog(@"   AdvancedCell-Label-TapAction: %@; style: %lu", content, (unsigned long)style);
            };


            /**
             这里仅仅是为了测试 QAAttributedLabel的 'searchTexts:' 这个方法
             这里仅仅是为了测试 QAAttributedLabel的 'searchTexts:' 这个方法
             这里仅仅是为了测试 QAAttributedLabel的 'searchTexts:' 这个方法
             */
            cell.content.highLightTexts = nil;
            if (indexPath.row == 1) {
                [self performSelector:@selector(searchText:) withObject:cell afterDelay:.7];
            }
        }
        if (self.donotDrawCell) {
            return cell;
        }
        else {
            NSDictionary *dic = nil;
            if (indexPath.row <= 2) {
                dic = [self.showDatas objectAtIndex:indexPath.row];
            }
            else {
                dic = [self.showDatas objectAtIndex:indexPath.row-2];
            }
            [cell showStytle:dic];

            return cell;
        }
    }
}


#pragma mark - Actions -
- (void)tapedAdvancedCell:(BaseCell *)cell
               tapedStyle:(BaseCell_TapedStyle)tapedStyle
                  content:(NSString * _Nonnull)content {
    if (BaseCell_Taped_ContentImageView == tapedStyle) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[cell.styleInfo valueForKey:@"contentImageView"] forKey:@"url"];
        [dic setValue:[cell.styleInfo valueForKey:@"contentImageView-frame"] forKey:@"frame"];
        if ([dic valueForKey:@"url"] && [dic valueForKey:@"frame"]) {
            if ([[dic valueForKey:@"url"] hasSuffix:@".gif"]) {  // 本DEMO中的gif显示的均是本地的demo.GIF (可删除dic中的image)
                [dic setValue:cell.yyImageView.image forKey:@"image"];
            }
            if (!self.imageBrowserManager) {
                self.imageBrowserManager = [[QAImageBrowserManager alloc] init];
            }

            // __weak typeof(cell) weakCell = cell;
            [self.imageBrowserManager showImageWithTapedObject:cell.yyImageView
                                                        images:[NSArray arrayWithObject:dic]
                                                      finished:^(NSInteger index, YYAnimatedImageView * _Nonnull imageView) {
                // __strong typeof(weakCell) strongCell = weakCell;
            }];
        }
    }
}


#pragma mark - SearchText 【【 仅仅用于验证label的"searchTexts:方法"是否能正确工作 】】 -
- (void)searchText:(AdvancedCell *)cell {
    [cell.content searchTexts:[NSArray arrayWithObjects:@"是另外的", @"需要注意的", @"提高效率", nil]
        resetSearchResultInfo:^NSDictionary * _Nullable {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:[UIColor whiteColor] forKey:@"textColor"];
            [dic setValue:[UIColor orangeColor] forKey:@"textBackgroundColor"];
            return dic;
        }];
}


#pragma mark - UITableView - Delegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"tableView - didSelectRowAtIndexPath: %ld", (long)indexPath.row);
}

/*
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSIndexPath *indexPath_position = [self.tableView indexPathForRowAtPoint:CGPointMake(0, targetContentOffset->y)];
    NSIndexPath *indexPath_current = [[self.tableView indexPathsForVisibleRows] lastObject];
    NSLog(@"indexPath_position.row: %ld",indexPath_position.row);
    NSInteger skipCount = 2;
    if (labs(indexPath_position.row - indexPath_current.row) > skipCount) {
        self.needLoadDatas = [self.tableView indexPathsForRowsInRect:CGRectMake(0, targetContentOffset->y, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        if (velocity.y < 0) {   // 手指往下滑
            
        }
        else {   // 手指往上滑
            
        }
    }
}
 */

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self resumeTimer];
//}
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self cancelTimer];
//}
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    if (decelerate == NO) {
//        [self cancelTimer];
//    }
//}


#pragma mark - Observe TableviewVelocity -
//- (void)observerTableviewVelocity {
//    return;
//
//
//    [self.tableView addObserver:self
//                     forKeyPath:@"contentOffset"
//                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
//                        context:NULL];
//}
//- (void)resumeTimer {
//    return;
//
//
//    if (!self.timer) {
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        uint64_t interval = 200000000;   // 值为"1 000 000 000"时表示为1秒
//        int leeway = 0;
//
//        self.timer = CreateDispatchTimer(interval, leeway, queue, ^{
//            NSLog(@"self.setOldValue(=0): %d",self.setOldValue);
//            NSLog(@"currentThread: %@",[NSThread currentThread]);
//            if (self.setOldValue == NO) {
//                CGFloat dif = self.currentValue - self.oldValue;
//                NSLog(@"dif: %f",dif);
//                self.setOldValue = YES;
//
//                if (dif - 1200 > 0) {
//                    self.donotDrawCell = YES;
//                }
//                else {
//                    self.donotDrawCell = NO;
//                }
//            }
//        });
//
//        dispatch_source_set_cancel_handler(self.timer, ^{
//            [self cancelTimer];
//        });
//    }
//}
//- (void)cancelTimer {
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//        if (self.timer) {
//            dispatch_source_cancel(self.timer);
//            self.timer = nil;
//        }
//    });
//}
//
//dispatch_source_t CreateDispatchTimer(uint64_t interval,
//                                      uint64_t leeway,
//                                      dispatch_queue_t queue,
//                                      dispatch_block_t block) {
//    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//    if (timer) {
//        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
//        dispatch_source_set_event_handler(timer, block);
//        dispatch_resume(timer);
//    }
//    return timer;
//}
//
//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary *)change
//                       context:(void *)context {
//    if([keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
//        // NSString *oldKey = [change objectForKey:NSKeyValueChangeOldKey];
//        // NSString *newKey = [change objectForKey:NSKeyValueChangeNewKey];
//
//        NSLog(@"self.setOldValue(+0): %d",self.setOldValue);
//        if (self.setOldValue) {
//            CGPoint point = [change[NSKeyValueChangeNewKey] CGPointValue];
//            self.oldValue = point.y;
//            self.setOldValue = NO;
//            NSLog(@"self.setOldValue(+1): %d",self.setOldValue);
//        }
//        CGPoint point = [change[NSKeyValueChangeNewKey] CGPointValue];
//        self.currentValue = point.y;
//    }
//}


#pragma mark - Property -
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavigationBarHeight, UIWidth, UIHeight - NavigationBarHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;

        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
    }
    return _tableView;
}


#pragma mark - displayLink - fps -
- (void)displayLinkTick {
    if (_lastTime == 0) {
        _frameCount = 0;
        _lastTime = self.displayLink.timestamp;
    }

    NSTimeInterval passTime = self.displayLink.timestamp - _lastTime;  // 累积时间
    if (passTime - 1 < 0) {
        _frameCount++;
        return;
    }
    else {
        // NSLog(@"frameCount: %d",_frameCount);
        // NSLog(@"passTime: %f",passTime);
        
        int fps = floor(_frameCount / rintf(passTime));  // 帧数 = 总帧数/时间
        if (fps - 59 < 0) {
            // NSLog(@"这里的UI有点问题!!! fps: %d",fps);
        }
        
        _lastTime = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = [NSString stringWithFormat:@"fps: %d",fps];
        });
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
