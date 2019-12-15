//
//  BaseCell.m
//  TestProject
//
//  Created by Avery An on 2019/8/25.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "BaseCell.h"

#define BaseCell_Taped_Name_MASK                (1 << 0)  // 0000 0000 0000 0001
#define BaseCell_Taped_Desc_MASK                (1 << 1)  // 0000 0000 0000 0010
#define BaseCell_Taped_Avatar_MASK              (1 << 2)  // 0000 0000 0000 0100
#define BaseCell_Taped_ContentImageView_MASK    (1 << 3)  // 0000 0000 0000 1000
#define BaseCell_Taped_Content_MASK             (1 << 4)  // 0000 0000 0001 0000

typedef struct {
    char tapedName : 1;
    char tapedDesc : 1;
    char tapedAvatar : 1;
    char tapedContentImageView : 1;
    char tapedContent : 1;
} Bits_struct;

typedef union {
    char bits;
    Bits_struct bits_struct;
} Bits_union;


@interface BaseCell () {
    Bits_union _bits_union;
}
@property (nonatomic) BOOL drawed;
@property (nonatomic) BOOL hasSetFunctions;
@end

@implementation BaseCell

#pragma mark - Life Cycle -
- (void)dealloc {
//    NSLog(@"%s",__func__);
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.avatar];
        // [self.contentView addSubview:self.contentImageView];
        // [self.contentView addSubview:self.flImageView];
        [self.contentView addSubview:self.yyImageView];
        // [self.contentView.layer addSublayer:self.contentImageLayer];
        [self.contentView addSubview:self.content];
    }
    
    return self;
}


#pragma mark - Override Methods -
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    
    CGRect nameFrame = [[self.styleInfo valueForKey:@"name-frame"] CGRectValue];
    if (CGRectContainsPoint(nameFrame, point)) {
        _bits_union.bits |= BaseCell_Taped_Name_MASK;
        return;
    }
    
    CGRect descFrame = [[self.styleInfo valueForKey:@"desc-frame"] CGRectValue];
    if (CGRectContainsPoint(descFrame, point)) {
        _bits_union.bits |= BaseCell_Taped_Desc_MASK;
        return;
    }
    
    CGRect avatarFrame = [[self.styleInfo valueForKey:@"avatar-frame"] CGRectValue];
    if (CGRectContainsPoint(avatarFrame, point)) {
        _bits_union.bits |= BaseCell_Taped_Avatar_MASK;
        return;
    }
    
    CGRect contentImageViewFrame = [[self.styleInfo valueForKey:@"contentImageView-frame"] CGRectValue];
    if (CGRectContainsPoint(contentImageViewFrame, point)) {
        _bits_union.bits |= BaseCell_Taped_ContentImageView_MASK;
        return;
    }
    /*
     CGRect contentFrame = [[self.styleInfo valueForKey:@"content-frame"] CGRectValue];
     if (CGRectContainsPoint(contentFrame, point)) {
        _bits_union.bits |= BaseCell_Taped_Content_MASK;
        return;
     }
     */
    
    [self.nextResponder touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    __weak typeof(self) weakSelf = self;
    
    if (!!(_bits_union.bits & BaseCell_Taped_Name_MASK)) {
        _bits_union.bits &= ~BaseCell_Taped_Name_MASK;
        if (self.baseCellTapAction) {
            self.baseCellTapAction(self, BaseCell_Taped_Name, [weakSelf.styleInfo valueForKey:@"name"]);
            return;
        }
    }
    else if (!!(_bits_union.bits & BaseCell_Taped_Desc_MASK)) {
        _bits_union.bits &= ~BaseCell_Taped_Desc_MASK;
        if (self.baseCellTapAction) {
            self.baseCellTapAction(self, BaseCell_Taped_Desc, [weakSelf.styleInfo valueForKey:@"desc"]);
            return;
        }
    }
    else if (!!(_bits_union.bits & BaseCell_Taped_Avatar_MASK)) {
        _bits_union.bits &= ~BaseCell_Taped_Avatar_MASK;
        if (self.baseCellTapAction) {
            self.baseCellTapAction(self, BaseCell_Taped_Avatar, [weakSelf.styleInfo valueForKey:@"avatar"]);
            return;
        }
    }
    else if (!!(_bits_union.bits & BaseCell_Taped_ContentImageView_MASK)) {
        _bits_union.bits &= ~BaseCell_Taped_ContentImageView_MASK;
        if (self.baseCellTapAction) {
            self.baseCellTapAction(self, BaseCell_Taped_ContentImageView, [weakSelf.styleInfo valueForKey:@"contentImageView"]);
            return;
        }
    }
    /*
     else if (!!(_bits_union.bits & BaseCell_Taped_Content_MASK)) {
         _bits_union.bits &= ~BaseCell_Taped_Content_MASK;
         if (self.baseCellTapAction) {
             self.baseCellTapAction(self, BaseCell_Taped_Content, [weakSelf.styleInfo valueForKey:@"content"]);
             return;
         }
     }
     */
    
    [self.nextResponder touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (!!(_bits_union.bits & BaseCell_Taped_Name_MASK)) {
        _bits_union.bits &= ~BaseCell_Taped_Name_MASK;
    }
    else if (!!(_bits_union.bits & BaseCell_Taped_Desc_MASK)) {
        _bits_union.bits &= ~BaseCell_Taped_Desc_MASK;
    }
    else if (!!(_bits_union.bits & BaseCell_Taped_Avatar_MASK)) {
        _bits_union.bits &= ~BaseCell_Taped_Avatar_MASK;
    }
    else if (!!(_bits_union.bits & BaseCell_Taped_ContentImageView_MASK)) {
        _bits_union.bits &= ~BaseCell_Taped_ContentImageView_MASK;
    }
    else if (!!(_bits_union.bits & BaseCell_Taped_Content_MASK)) {
        _bits_union.bits &= ~BaseCell_Taped_Content_MASK;
    }
    
    [self.nextResponder touchesCancelled:touches withEvent:event];
}


#pragma mark - Cell的布局 -
- (void)masonryLayout:(NSDictionary *)dic {
    if ([[dic allKeys] indexOfObject:NSStringFromSelector(@selector(avatar))] != NSNotFound) {
        self.avatar.hidden = NO;
        CGRect rect = [[dic valueForKey:@"avatar-frame"] CGRectValue];
        self.avatar.frame = rect;
        /*
         [self.avatar mas_remakeConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(rect.origin.y);
             make.left.mas_equalTo(rect.origin.x);
             make.size.mas_equalTo(rect.size);
         }];
         */
    }
    else {
        self.avatar.hidden = YES;
    }
    
    if ([[dic allKeys] indexOfObject:NSStringFromSelector(@selector(contentImageView))] != NSNotFound) {
        CGRect rect = [[dic valueForKey:@"contentImageView-frame"] CGRectValue];
        
        self.yyImageView.hidden = NO;
        self.yyImageView.frame = rect;
        /*
         [self.yyImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(rect.origin.y);
             make.left.mas_equalTo(rect.origin.x);
             make.size.mas_equalTo(rect.size);
         }];
         */
        
        
//        NSString *imageUrl = [dic valueForKey:@"contentImageView"];
//        if ([imageUrl hasSuffix:@".gif"]) {
////            self.contentImageView.hidden = YES;
////            self.flImageView.hidden = NO;
//            self.yyImageView.hidden = NO;
////            [self.flImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
////                make.top.mas_equalTo(rect.origin.y);
////                make.left.mas_equalTo(rect.origin.x);
////                make.size.mas_equalTo(rect.size);
////            }];
//            [self.yyImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(rect.origin.y);
//                make.left.mas_equalTo(rect.origin.x);
//                make.size.mas_equalTo(rect.size);
//            }];
//        }
//        else {
////            self.flImageView.hidden = YES;
////            self.yyImageView.hidden = YES;
////            self.contentImageView.hidden = NO;
////            [self.contentImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
////                make.top.mas_equalTo(rect.origin.y);
////                make.left.mas_equalTo(rect.origin.x);
////                make.size.mas_equalTo(rect.size);
////            }];
//        }
        
        /*
         self.contentImageLayer.hidden = NO;
         CGRect rect = [[dic valueForKey:@"contentImageView-frame"] CGRectValue];
         self.contentImageLayer.frame = rect;
         */
    }
    else {
//        self.contentImageView.hidden = YES;
//        self.flImageView.hidden = YES;
        self.yyImageView.hidden = YES;
        
        /*
         self.contentImageLayer.hidden = YES;
         */
    }
    
    if ([[dic allKeys] indexOfObject:NSStringFromSelector(@selector(content))] != NSNotFound) {
        self.content.hidden = NO;
        CGRect rect = [[dic valueForKey:@"content-frame"] CGRectValue];
        self.content.frame = rect;
        /*
         [self.content mas_remakeConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(rect.origin.y);
             make.left.mas_equalTo(rect.origin.x);
             make.size.mas_equalTo(rect.size);
         }];
         */
    }
    else {
        self.content.hidden = YES;
    }
    
    
    CGRect cellFrame = [[dic valueForKey:@"cell-frame"] CGRectValue];
    CGRect frame = self.frame;
    frame = (CGRect){frame.origin.x, frame.origin.y, cellFrame.size};
    self.frame = frame;
    self.contentView.frame = frame;
}


#pragma mark - Cell的绘制 -
- (void)clear {
    if (self.drawed == NO) {
        return;
    }
    
    self.avatar.image = nil;
//    self.contentImageView.image = nil;
//    self.flImageView.image = nil;
    self.yyImageView.image = nil;
    self.content.text = nil;
    self.content.attributedText = nil;
    self.content.layer.contents = nil;
    // self.contentImageLayer.contents = nil;
    self.contentView.layer.contents = nil;
    self.drawed = NO;
}

- (void)draw:(NSDictionary *)dic {
    if (self.drawed) {  // cell已经被绘制
        return;
    }
    else {  // cell尚未被异步绘制
        // 异步绘制:
        self.drawed = YES;
        CGRect cellFrame = [[dic valueForKey:@"cell-frame"] CGRectValue];
        
        @weakify(self)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self)
            
            UIGraphicsBeginImageContextWithOptions(cellFrame.size, YES, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            // *** 【1】背景颜色填充:
            [[UIColor whiteColor] set];
            CGContextFillRect(context, cellFrame); // 全局背景色
            
            // *** 【2】avatar
            if ([[dic allKeys] indexOfObject:NSStringFromSelector(@selector(avatar))] != NSNotFound) {
                NSString *avatar = [dic valueForKey:@"avatar"];
                
                SDWebImageOptions opt = SDWebImageRetryFailed | SDWebImageAvoidAutoSetImage;
                [self.avatar sd_setImageWithURL:[NSURL URLWithString:avatar]
                               placeholderImage:nil
                                        options:opt
                                      completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *roundedImage = [image roundedImage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.avatar.image = roundedImage;
                    });
                });
                                      }];
            }
            
            
            // *** 【3】用户名 & desc 的绘制:
            {
                NSString *userName = [dic valueForKey:@"name"];
                CGRect nameFrame = [[dic valueForKey:@"name-frame"] CGRectValue];
                NSDictionary *style = [dic valueForKey:@"name-style"];
                NSInteger startX = nameFrame.origin.x;
                NSInteger startY = nameFrame.origin.y;
                [userName drawInContext:context
                           withPosition:CGPointMake(startX, startY)
                                   font:[style valueForKey:@"font"]
                              textColor:[style valueForKey:@"textColor"]
                                 height:nameFrame.size.height
                          lineBreakMode:NSLineBreakByCharWrapping
                          textAlignment:NSTextAlignmentLeft];
                
                
                NSString *desc = [dic valueForKey:@"desc"];
                CGRect descFrame = [[dic valueForKey:@"desc-frame"] CGRectValue];
                startX = descFrame.origin.x;
                startY = descFrame.origin.y;
                [desc drawInContext:context
                       withPosition:CGPointMake(startX, startY)
                               font:[style valueForKey:@"font"]
                          textColor:[style valueForKey:@"textColor"]
                             height:descFrame.size.height
                      lineBreakMode:NSLineBreakByCharWrapping
                      textAlignment:NSTextAlignmentLeft];
            }
            
            
            // *** 【4】content
            if ([[dic allKeys] indexOfObject:NSStringFromSelector(@selector(content))] != NSNotFound) {
                NSMutableAttributedString *attributedText = [dic valueForKey:@"content-attributed"];
                self.content.attributedText = attributedText;
            }
            
            
            // *** 【5】contentImageView
            if ([[dic allKeys] indexOfObject:NSStringFromSelector(@selector(contentImageView))] != NSNotFound) {
                NSString *imageUrl = [dic valueForKey:@"contentImageView"];
                if ([imageUrl isEqualToString:@"https://qq.yh31.com/tp/zjbq/201711142021166458.gif"]) {  // 本例中只是加载了本地的gif
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSBundle *bundle = [NSBundle mainBundle];
                        NSString *resourcePath = [bundle resourcePath];
                        NSString *filePath = [resourcePath stringByAppendingPathComponent:@"demo.GIF"];
                        YYImage *yyImage = [YYImage imageWithContentsOfFile:filePath];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.yyImageView.image = yyImage;
                        });
                    });
                }
                else {
                    SDWebImageOptions opt = SDWebImageRetryFailed | SDWebImageAvoidAutoSetImage;
                    [self.yyImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                                             placeholderImage:nil
                                                      options:opt
                                                    completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                                        if ([imageUrl hasSuffix:@".gif"]) { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                            NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:imageURL.absoluteString];
                                                            NSData *data = [NSData dataWithContentsOfFile:path];
                                                            YYImage *yyImage = [YYImage imageWithData:data];
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                self.yyImageView.image = yyImage;
                                                            });
                                                            
                                                            /*
                                                             FLAnimatedImage *flImage = [FLAnimatedImage animatedImageWithGIFData:data];
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 self.flImageView.animatedImage = flImage;
                                                             });
                                                             */
                                                            });
                                                        }
                                                        else {
                                                            // self.contentImageView.image = image;
                                                            self.yyImageView.image = image;
                                                        }
                                                    }];
                }
                
                /*
                [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                                                completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                                }];
                 */
                
                /*
                SDWebImageOptions opt = SDWebImageRetryFailed | SDWebImageAvoidAutoSetImage;
                [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                             placeholderImage:nil
                                      options:opt
                                    completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                        if ([imageUrl hasSuffix:@".gif"]) {
                                            // UIImageView显示jif的时候fps会下降到46左右 (严重影响流畅性)
                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:imageURL.absoluteString];
                                                NSData *data = [NSData dataWithContentsOfFile:path];
                                                UIImage *gifImage = [UIImage sd_animatedGIFWithData:data];
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    self.contentImageView.image = gifImage;
                                                });
                                            });
                                        }
                                        else {
                                            self.contentImageView.image = image;
                                        }
                                    }];
                */
                
                /*
                [[SDWebImageDownloader sharedDownloader]
                 downloadImageWithURL:[NSURL URLWithString:imageUrl]
                 options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {

                 } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                         UIImage *decodeImage = [image decodeImage];  // image的解码
                         dispatch_async(dispatch_get_main_queue(), ^{
                             self.contentImageLayer.contents = (__bridge id _Nullable)(decodeImage.CGImage);
                         });
                     });
                 }];
                 */
            }
            
            
            // *** 【6】
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                self.contentView.layer.contents = (__bridge id)image.CGImage;
            });
        });
    }
}


#pragma mark - Public Methods -
- (void)showStytle:(NSDictionary *)dic {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    else if ([self.styleInfo isEqual:dic]) {   // 避免重复绘制 (tableView刷新的时候)
        return;
    }
    else if (dic.count == 0) {
        // 清除cell上已绘制的内容:
        [self clear];
        
        return;
    }
    else {
        self.styleInfo = dic;
        
        // 设置cell的相关属性:
        [self setFunctions:self.styleInfo];
        
        // 清除cell上已绘制的内容:
        [self clear];
        
        // 设置cell的样式布局:
        [self masonryLayout:self.styleInfo];
        
        // 绘制cell需要显示的内容:
        [self draw:self.styleInfo];
    }
}
- (void)setFunctions:(NSDictionary *)dic {
    if (self.hasSetFunctions) {
        return;
    }
    self.hasSetFunctions = YES;
    
    NSDictionary *functions = [dic valueForKey:@"content-functions"];
    if (functions && functions.count > 0) {
        for (NSString *key in functions) {
            [self.content setValue:[functions valueForKey:key] forKey:key];
        }
    }
}


#pragma mark - Properties -
- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
    }
    return _avatar;
}
//- (UIImageView *)contentImageView {
//    if (!_contentImageView) {
//        _contentImageView = [[UIImageView alloc] init];
//        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
//        _contentImageView.clipsToBounds = YES;
//
//        /** UIImageView 进行如下设置并不会引起离屏渲染 ~~~
//         // _contentImageView_1.clipsToBounds = YES;
//         _contentImageView_1.layer.masksToBounds = YES;
//         _contentImageView_1.layer.cornerRadius = 50;
//         */
//
//        /** UIButton 进行如下设置会引起离屏渲染 !!!
//         UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//         button.frame = CGRectMake(15, 43, 80, 30);
//         button.backgroundColor = [UIColor redColor];
//         button.layer.masksToBounds = YES;
//         button.layer.cornerRadius = 16;
//         [_contentImageView_1 addSubview:button];
//         */
//    }
//    return _contentImageView;
//}
- (YYAnimatedImageView *)yyImageView {
    if (!_yyImageView) {
        _yyImageView = [[YYAnimatedImageView alloc] init];
        _yyImageView.contentMode = UIViewContentModeScaleAspectFill;
        _yyImageView.clipsToBounds = YES;
        _yyImageView.layer.cornerRadius = 3;
    }
    return _yyImageView;
}
//- (FLAnimatedImageView *)flImageView {
//    if (!_flImageView) {
//        _flImageView = [[FLAnimatedImageView alloc] init];
//        _flImageView.contentMode = UIViewContentModeScaleAspectFill;
//        _flImageView.clipsToBounds = YES;
//    }
//    return _flImageView;
//}
//- (CALayer *)contentImageLayer {
//    if (!_contentImageLayer) {
//        _contentImageLayer = [[CALayer alloc] init];
//        _contentImageLayer.contentsGravity = kCAGravityResizeAspectFill;
//    }
//    return _contentImageLayer;
//}
- (QAAttributedLabel *)content {
    if (!_content) {
        _content = [[QAAttributedLabel alloc] init];
    }
    return _content;
}

@end
