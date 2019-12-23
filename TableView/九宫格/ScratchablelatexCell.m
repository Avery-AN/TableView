//
//  ScratchablelatexCell.m
//  TestProject
//
//  Created by Avery An on 2019/9/8.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "ScratchablelatexCell.h"

static BOOL openClipsToBounds = YES;

@interface ScratchablelatexCell ()
@property (nonatomic, assign) ScratchablelatexCell_TapedPosition tapedPosition;
@property (nonatomic, copy) NSDictionary *tapedInfo;
@property (nonatomic, unsafe_unretained) id tapedObject;
@end

@implementation ScratchablelatexCell

#pragma mark - Life Cycle -
- (void)dealloc {
//    NSLog(@"%s",__func__);
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.contentImageView_1];
        [self.contentView addSubview:self.contentImageView_2];
        [self.contentView addSubview:self.contentImageView_3];
        [self.contentView addSubview:self.contentImageView_4];
        [self.contentView addSubview:self.contentImageView_5];
        [self.contentView addSubview:self.contentImageView_6];
        [self.contentView addSubview:self.contentImageView_7];
        [self.contentView addSubview:self.contentImageView_8];
        [self.contentView addSubview:self.contentImageView_9];
    }
    
    return self;
}


#pragma mark - Override Methods -
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    NSArray *contentImageViews = [self.styleInfo valueForKey:@"contentImageViews"];
    if (contentImageViews && [contentImageViews isKindOfClass:[NSArray class]]) {
        for (int i = 0; i < contentImageViews.count; i++) {
            NSDictionary *dic = [contentImageViews objectAtIndex:i];
            CGRect contentImageViewFrame = [[dic valueForKey:@"frame"] CGRectValue];
            
            if (CGRectContainsPoint(contentImageViewFrame, point)) {
                self.tapedPosition = i;
                self.tapedInfo = dic;
                self.tapedObject = [self.contentView viewWithTag:DefaultTag_contentImageView + i];
                return;
            }
        }
    }
    
    [super touchesBegan:touches withEvent:event];
    
    [self.nextResponder touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (self.tapedInfo) {
        if (self.scratchablelatexCellTapImageAction) {
            self.scratchablelatexCellTapImageAction(self, self.tapedObject, self.tapedPosition, self.tapedInfo);
        }
        self.tapedInfo = nil;
        self.tapedPosition = ScratchablelatexCell_Taped_Null;
        self.tapedObject = nil;
        return;
    }
    
    [super touchesEnded:touches withEvent:event];
    
    [self.nextResponder touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    self.tapedInfo = nil;
    self.tapedPosition = ScratchablelatexCell_Taped_Null;
    self.tapedObject = nil;
    
    [super touchesCancelled:touches withEvent:event];
    
    [self.nextResponder touchesCancelled:touches withEvent:event];
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
    self.styleInfo = dic;
    
    // 设置cell的相关属性:
    [self setProperties:self.styleInfo];
    
    // 清除cell上已绘制的内容:
    [self clear];
    
    // 设置cell的样式布局:
    [self masonryLayout:self.styleInfo];
    
    // 绘制cell需要显示的内容:
    [self draw:self.styleInfo];
}


#pragma mark - Cell的布局 -
- (void)masonryLayout:(NSDictionary *)dic {
    [super masonryLayout:dic];
    
    NSArray *contentImageViews = [dic valueForKey:@"contentImageViews"];
    if (contentImageViews && [contentImageViews isKindOfClass:[NSArray class]]) {
        self.yyImageView.hidden = NO;
        
        for (int i = 0; i < contentImageViews.count; i++) {
            UIImageView *contentImageView = [self.contentView viewWithTag:DefaultTag_contentImageView + i];
            contentImageView.hidden = NO;
            NSDictionary *dic = [contentImageViews objectAtIndex:i];
            CGRect rect = [[dic valueForKey:@"frame"] CGRectValue];
            contentImageView.frame = rect;
            /*
             [contentImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                 make.top.mas_equalTo(rect.origin.y);
                 make.left.mas_equalTo(rect.origin.x);
                 make.size.mas_equalTo(rect.size);
             }];
             */
        }
        [self hideImageView:contentImageViews.count];
    }
}


#pragma mark - Private Method -
- (void)hideImageView:(NSInteger)startPosition {
    for (NSUInteger i = startPosition; i < 9; i++) {
        UIImageView *contentImageView = [self.contentView viewWithTag:DefaultTag_contentImageView+i];
        contentImageView.image = nil;
        contentImageView.hidden = YES;
    }
}


#pragma mark - Cell的绘制 -
- (void)clear {
    self.contentImageView_1.image = nil;
    self.contentImageView_2.image = nil;
    self.contentImageView_3.image = nil;
    self.contentImageView_4.image = nil;
    self.contentImageView_5.image = nil;
    self.contentImageView_6.image = nil;
    self.contentImageView_7.image = nil;
    self.contentImageView_8.image = nil;
    self.contentImageView_9.image = nil;
    
    [super clear];
}

- (void)draw:(NSDictionary *)dic {
    [super draw:dic];
    
    [self drawScratchablelatex];  // 九宫格的绘制
}
- (void)drawScratchablelatex {
    NSArray *contentImageViews = [self.styleInfo valueForKey:@"contentImageViews"];
    if (contentImageViews && [contentImageViews isKindOfClass:[NSArray class]]) {
        for (int i = 0; i < contentImageViews.count; i++) {
            NSDictionary *dic = [contentImageViews objectAtIndex:i];
            NSString *url = [dic valueForKey:@"url"];
            UIImageView *contentImageView = [self.contentView viewWithTag:DefaultTag_contentImageView + i];
            SDWebImageOptions opt = SDWebImageRetryFailed | SDWebImageAvoidAutoSetImage;
            [contentImageView sd_setImageWithURL:[NSURL URLWithString:url]
                                placeholderImage:nil
                                         options:opt
                                       completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                           if ([url hasSuffix:@".gif"]) { // UIImageView显示jif的时候fps会下降到46左右 (严重影响流畅性)
                                               NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:imageURL.absoluteString];
                                               NSData *data = [NSData dataWithContentsOfFile:path];
                                               UIImage *gifImage = [UIImage sd_animatedGIFWithData:data];
                                               contentImageView.image = gifImage;
                                           }
                                           else {
                                               contentImageView.image = image;
                                           }
                                       }];
        }
    }
}


#pragma MARK - Property -
- (QAAttributedLabel *)styleLabel {
    if (!_styleLabel) {
        NSInteger content_width = UIWidth - Avatar_left_gap - Avatar_left_gap;
        NSInteger content_height = 15;
        _styleLabel = [[QAAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, content_width, content_height)];
        _styleLabel.font = [UIFont systemFontOfSize:17];
        _styleLabel.textColor = HEXColor(@"666666");
        _styleLabel.lineSpace = 1.1;
        _styleLabel.wordSpace = 3;
        _styleLabel.display_async = YES;
        _styleLabel.linkHighlight = YES;
        _styleLabel.atHighlight = YES;
        _styleLabel.showShortLink = YES;
        _styleLabel.shortLink = @"这里是网址短链接";
        _styleLabel.numberOfLines = 0;
//        _styleLabel.numberOfLines = 6;
        _styleLabel.topicHighlight = YES;
        _styleLabel.showMoreText = YES;
        _styleLabel.seeMoreText = @"...查看全文";
        _styleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _styleLabel.moreTextColor = [UIColor purpleColor];
        _styleLabel.moreTapedTextColor = [UIColor greenColor];
        _styleLabel.textAlignment = NSTextAlignmentJustified;
        _styleLabel.highLightTexts = [NSArray arrayWithObjects:@"大量添加控件",@"直接绘制", nil];
        _styleLabel.highlightTextColor = [UIColor purpleColor];
        _styleLabel.highlightTapedTextColor = [UIColor greenColor];
        _styleLabel.highlightAtTextColor = [UIColor greenColor];
        _styleLabel.highlightLinkTextColor = [UIColor orangeColor];
        _styleLabel.highlightTopicTextColor = [UIColor magentaColor];
        _styleLabel.highlightAtTapedTextColor = [UIColor redColor];
        _styleLabel.highlightLinkTapedTextColor = [UIColor magentaColor];
        _styleLabel.highlightTopicTapedTextColor = [UIColor greenColor];
    }
    return _styleLabel;
}

- (UIImageView *)contentImageView_1 {
    if (!_contentImageView_1) {
        _contentImageView_1 = [UIImageView new];
        if (openClipsToBounds) {
            _contentImageView_1.clipsToBounds = YES;
        }
        _contentImageView_1.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView_1.tag = DefaultTag_contentImageView;
    }
    return _contentImageView_1;
}
- (UIImageView *)contentImageView_2 {
    if (!_contentImageView_2) {
        _contentImageView_2 = [UIImageView new];
        if (openClipsToBounds) {
            _contentImageView_2.clipsToBounds = YES;
        }
        _contentImageView_2.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView_2.tag = DefaultTag_contentImageView+1;
    }
    return _contentImageView_2;
}
- (UIImageView *)contentImageView_3 {
    if (!_contentImageView_3) {
        _contentImageView_3 = [UIImageView new];
        if (openClipsToBounds) {
            _contentImageView_3.clipsToBounds = YES;
        }
        _contentImageView_3.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView_3.tag = DefaultTag_contentImageView+2;
    }
    return _contentImageView_3;
}
- (UIImageView *)contentImageView_4 {
    if (!_contentImageView_4) {
        _contentImageView_4 = [UIImageView new];
        if (openClipsToBounds) {
            _contentImageView_4.clipsToBounds = YES;
        }
        _contentImageView_4.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView_4.tag = DefaultTag_contentImageView+3;
    }
    return _contentImageView_4;
}
- (UIImageView *)contentImageView_5 {
    if (!_contentImageView_5) {
        _contentImageView_5 = [UIImageView new];
        if (openClipsToBounds) {
            _contentImageView_5.clipsToBounds = YES;
        }
        _contentImageView_5.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView_5.tag = DefaultTag_contentImageView+4;
    }
    return _contentImageView_5;
}
- (UIImageView *)contentImageView_6 {
    if (!_contentImageView_6) {
        _contentImageView_6 = [UIImageView new];
        if (openClipsToBounds) {
            _contentImageView_6.clipsToBounds = YES;
        }
        _contentImageView_6.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView_6.tag = DefaultTag_contentImageView+5;
    }
    return _contentImageView_6;
}
- (UIImageView *)contentImageView_7 {
    if (!_contentImageView_7) {
        _contentImageView_7 = [UIImageView new];
        if (openClipsToBounds) {
            _contentImageView_7.clipsToBounds = YES;
        }
        _contentImageView_7.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView_7.tag = DefaultTag_contentImageView+6;
    }
    return _contentImageView_7;
}
- (UIImageView *)contentImageView_8 {
    if (!_contentImageView_8) {
        _contentImageView_8 = [UIImageView new];
        if (openClipsToBounds) {
            _contentImageView_8.clipsToBounds = YES;
        }
        _contentImageView_8.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView_8.tag = DefaultTag_contentImageView+7;
    }
    return _contentImageView_8;
}
- (UIImageView *)contentImageView_9 {
    if (!_contentImageView_9) {
        _contentImageView_9 = [UIImageView new];
        if (openClipsToBounds) {
            _contentImageView_9.clipsToBounds = YES;
        }
        _contentImageView_9.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView_9.tag = DefaultTag_contentImageView+8;
    }
    return _contentImageView_9;
}

@end
