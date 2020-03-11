//
//  TrapezoidalCell.m
//  TableView
//
//  Created by Avery An on 2020/3/9.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "TrapezoidalCell.h"

@implementation TrapezoidalCell

#pragma mark - Public Methods -
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.avatar];
        [self.contentView addSubview:self.yyImageView];
        [self.contentView addSubview:self.trapezoidalLabel];
    }
    
    return self;
}
- (void)setTrapezoidalTexts:(NSDictionary *)trapezoidalInfo lineHeight:(CGFloat)lineHeight {
    self.styleInfo = trapezoidalInfo;
    
    [self masonryLayout:trapezoidalInfo];
    
    self.trapezoidalLabel.trapezoidalLineHeight = lineHeight;
    self.trapezoidalLabel.trapezoidalTexts = [trapezoidalInfo valueForKey:@"trapezoidalTexts"];
    

    // *** avatar
    if ([[trapezoidalInfo allKeys] indexOfObject:NSStringFromSelector(@selector(avatar))] != NSNotFound) {
        NSString *avatar = [trapezoidalInfo valueForKey:@"avatar"];
        
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
    
    
    // *** 用户名 & desc 的绘制:
    {
        CGRect cellFrame = [[trapezoidalInfo valueForKey:@"cell-frame"] CGRectValue];
        
        UIGraphicsBeginImageContextWithOptions(cellFrame.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [[UIColor whiteColor] set];
        CGContextFillRect(context, cellFrame); // 全局背景色
        
        NSString *userName = [trapezoidalInfo valueForKey:@"name"];
        CGRect nameFrame = [[trapezoidalInfo valueForKey:@"name-frame"] CGRectValue];
        NSDictionary *style = [trapezoidalInfo valueForKey:@"name-style"];
        NSInteger startX = nameFrame.origin.x;
        NSInteger startY = nameFrame.origin.y;
        [userName drawInContext:context
                   withPosition:CGPointMake(startX, startY)
                           font:[style valueForKey:@"font"]
                      textColor:[style valueForKey:@"textColor"]
                         height:nameFrame.size.height
                  lineBreakMode:NSLineBreakByCharWrapping
                  textAlignment:NSTextAlignmentLeft];
        
        
        NSString *desc = [trapezoidalInfo valueForKey:@"desc"];
        CGRect descFrame = [[trapezoidalInfo valueForKey:@"desc-frame"] CGRectValue];
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
    
    // *** contentImageView
    if ([[trapezoidalInfo allKeys] indexOfObject:NSStringFromSelector(@selector(contentImageView))] != NSNotFound) {
        NSString *imageUrl = [trapezoidalInfo valueForKey:@"contentImageView"];
        SDWebImageOptions opt = SDWebImageRetryFailed | SDWebImageAvoidAutoSetImage;
        [self.yyImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                                 placeholderImage:nil
                                          options:opt
                                        completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                            self.yyImageView.image = image;
                                        }];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contentView.layer.contents = (__bridge id)image.CGImage;
    });
}


#pragma mark --
- (void)masonryLayout:(NSDictionary *)dic {
    self.avatar.hidden = NO;
    CGRect avatarRect = [[dic valueForKey:@"avatar-frame"] CGRectValue];
    self.avatar.frame = avatarRect;
    
    if ([[dic allKeys] indexOfObject:NSStringFromSelector(@selector(contentImageView))] != NSNotFound) {
        CGRect rect = [[dic valueForKey:@"contentImageView-frame"] CGRectValue];
        
        self.yyImageView.hidden = NO;
        self.yyImageView.frame = rect;
    }
    else {
        self.yyImageView.hidden = YES;
    }
    
    CGRect contentRect = [[dic valueForKey:@"content-frame"] CGRectValue];
    self.trapezoidalLabel.frame = contentRect;
    
    CGRect cellFrame = [[dic valueForKey:@"cell-frame"] CGRectValue];
    CGRect frame = self.frame;
    frame = (CGRect){frame.origin.x, frame.origin.y, cellFrame.size};
    self.contentView.frame = frame;
    self.frame = frame;
}


#pragma MARK - Property -
- (QATrapezoidalLabel *)trapezoidalLabel {
    if (!_trapezoidalLabel) {
        _trapezoidalLabel = [[QATrapezoidalLabel alloc] init];
        _trapezoidalLabel.backgroundColor = [UIColor whiteColor];
        _trapezoidalLabel.lineBackgroundColor = [UIColor purpleColor];
        _trapezoidalLabel.wordSpace = 3;
        // _trapezoidalLabel.highlightTextBackgroundColor = [UIColor yellowColor];
        _trapezoidalLabel.font = [UIFont fontWithName:@"PingFangTC-Regular" size:26];
        _trapezoidalLabel.textColor = [UIColor whiteColor];
        _trapezoidalLabel.textAlignment = NSTextAlignmentCenter;
        _trapezoidalLabel.highlightTextColor = [UIColor cyanColor];
        _trapezoidalLabel.highlightTapedTextColor = [UIColor greenColor];
        _trapezoidalLabel.highlightTapedBackgroundColor = [UIColor lightGrayColor];
        _trapezoidalLabel.highlightAtTextColor = [UIColor greenColor];
        _trapezoidalLabel.highlightLinkTextColor = [UIColor blueColor];
        _trapezoidalLabel.highlightTopicTextColor = [UIColor orangeColor];
        _trapezoidalLabel.highlightAtTapedTextColor = [UIColor redColor];
        _trapezoidalLabel.highlightLinkTapedTextColor = [UIColor magentaColor];
        _trapezoidalLabel.highlightTopicTapedTextColor = [UIColor redColor];
        _trapezoidalLabel.atHighlight = YES;
        _trapezoidalLabel.topicHighlight = YES;
        _trapezoidalLabel.linkHighlight = YES;
    }
    return _trapezoidalLabel;
}

@end
