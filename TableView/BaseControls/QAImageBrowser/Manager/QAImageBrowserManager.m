//
//  QAImageBrowserManager.m
//  Avery
//
//  Created by Avery on 2018/8/31.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QAImageBrowserManager.h"
#import "QAImageBrowserViewController.h"

@interface QAImageBrowserManager ()
@property (nonatomic) UIWindow *window;
@property (nonatomic) QAImageBrowserViewController *imageBrowserViewController;
@end

@implementation QAImageBrowserManager

#pragma mark - Life Cycle -
- (void)dealloc {
    NSLog(@"  %s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    __weak typeof(self) weakSelf = self;
    if (!self.imageBrowserViewController) {
        self.imageBrowserViewController = [[QAImageBrowserViewController alloc] init];
        [self.imageBrowserViewController showImageWithTapedObject:tapedImageView
                                                           images:images
                                                         finished:^(NSInteger index, YYAnimatedImageView * _Nonnull imageView) {
            __strong typeof(weakSelf) strongSelf = weakSelf;

            [strongSelf performSelector:@selector(quit) withObject:nil afterDelay:0];

            if (finishedBlock) {
                finishedBlock(index, imageView);
            }
        }];
    }
    
    if (!self.window) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.windowLevel = UIWindowLevelAlert - 1;
        [self.window makeKeyAndVisible];
    }
    self.window.rootViewController = self.imageBrowserViewController;
}


#pragma mark - Private Method -
- (void)quit {
    [self.window resignKeyWindow];
    self.imageBrowserViewController = nil;
    self.window = nil;
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

@end
