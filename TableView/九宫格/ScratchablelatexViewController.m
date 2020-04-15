//
//  ScratchablelatexViewController.m
//  TestProject
//
//  Created by Avery An on 2019/9/8.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "ScratchablelatexViewController.h"
#import "ScratchablelatexCell.h"
#import "ScratchablelatexCell+SelfManager.h"
#import "QAImageBrowserManager.h"
#import "ScratchablelatexDataManager.h"

@interface ScratchablelatexViewController () <UITableViewDataSource, UITableViewDelegate> {
}
@property (nonatomic) NSArray *stumbleIndexs;
@property (nonatomic) NSMutableDictionary *stumblePaths;
@property (nonatomic) NSMutableArray *showDatas;
@property (nonatomic) UITableView *tableView;
@property (nonatomic, assign) int frameCount;  // 累积帧数
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic) __block CADisplayLink *displayLink;
@property (nonatomic) QAImageBrowserManager *imageBrowserManager;
@end


@implementation ScratchablelatexViewController

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
- (void)generateContent {
    NSMutableArray *originalDatas = [ScratchablelatexDataManager getDatas];
    [self processDatas:originalDatas];
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
    [ScratchablelatexCell getStytle:originalDatas maxConcurrentOperationCount:maxConcurrentOperationCount completion:^(NSInteger start, NSInteger end) {
        // NSLog(@"已获取到新数据: %ld - %ld", (long)start , (long)end);
        
        [indexPaths removeAllObjects];
        for (NSUInteger i = start; i <= end; i++) {
            [self.showDatas addObject:[originalDatas objectAtIndex:i]];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPaths addObject:indexPath];
        }
        
        if (self.tableView.superview == nil) {
            [self.view addSubview:self.tableView];
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
    return self.showDatas.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [self.showDatas objectAtIndex:indexPath.row];
    CGRect cellFrame = [[dic valueForKey:@"cell-frame"] CGRectValue];
    NSInteger defaultHeight = Avatar_top_gap + AvatarSize + Avatar_bottomControl_gap;
    return cellFrame.size.height - defaultHeight > 0 ? cellFrame.size.height : defaultHeight;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ScratchablelatexCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScratchablelatexCell"];
    if (cell == nil) {
        cell = [[ScratchablelatexCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ScratchablelatexCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        __weak typeof(self) weakSelf = self;
        cell.baseCellTapAction = ^(BaseCell *cell, BaseCell_TapedStyle style, NSString * _Nonnull content) {
            NSLog(@"   ScratchablelatexCell-TapAction style: %lu; content: %@", (unsigned long)style, content);
        };
        
        cell.scratchablelatexCellTapImageAction = ^(ScratchablelatexCell *cell, id tapedObject, ScratchablelatexCell_TapedPosition tapedPosition, NSDictionary * _Nonnull contentImageViewInfo) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf tapedScratchablelatexCell:cell tapedObject:tapedObject tapedPosition:tapedPosition contentImageViewInfo:contentImageViewInfo];
        };
        
        cell.content.QAAttributedLabelTapAction = ^(NSString * _Nullable content, QAAttributedLabel_TapedStyle style) {
            NSLog(@"   ScratchablelatexCell-Label-TapAction: %@; style: %lu", content, (unsigned long)style);
        };
        

        /**
         这里仅仅是为了测试 QAAttributedLabel的 'searchTexts:' 这个方法
         这里仅仅是为了测试 QAAttributedLabel的 'searchTexts:' 这个方法
         这里仅仅是为了测试 QAAttributedLabel的 'searchTexts:' 这个方法
         */
        cell.content.highLightTexts = nil;
        if (indexPath.row == 0) {
            [self performSelector:@selector(searchText:) withObject:cell afterDelay:.7];
        }
        else if (indexPath.row == 1) {
            [self performSelector:@selector(searchText:) withObject:cell afterDelay:.7];
        }
        
    }
    
    NSDictionary *dic = [self.showDatas objectAtIndex:indexPath.row];
    [cell showStytle:dic];
    
    return cell;
}


#pragma mark - Actions -
- (void)tapedScratchablelatexCell:(ScratchablelatexCell *)cell
                      tapedObject:(id)tapedObject
                    tapedPosition:(ScratchablelatexCell_TapedPosition)position
             contentImageViewInfo:(NSDictionary * _Nonnull)contentImageViewInfo {
    NSArray *images = [cell.styleInfo valueForKey:@"contentImageViews"];
    if (!self.imageBrowserManager) {
        self.imageBrowserManager = [[QAImageBrowserManager alloc] init];
    }
    
    // __weak typeof(cell) weakCell = cell;
    [self.imageBrowserManager showImageWithTapedObject:tapedObject
                                                images:images
                                              finished:^(NSInteger index, YYAnimatedImageView * _Nonnull imageView) {
        // __strong typeof(weakCell) strongCell = weakCell;
    }];
}


#pragma mark - SearchText 【【 仅仅用于验证label的"searchTexts:方法"是否能正确工作 】】 -
- (void)searchText:(ScratchablelatexCell *)cell {
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

@end
