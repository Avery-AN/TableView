//
//  TrapezoidalCell.h
//  TableView
//
//  Created by Avery An on 2020/3/9.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "BaseCell.h"
#import "QATrapezoidalLabel.h"

static NSInteger TrapezoidalCell_AvatarSize = 38;
static NSInteger TrapezoidalCell_Avatar_left_gap = 13;
static NSInteger TrapezoidalCell_Avatar_top_gap = 13;
static NSInteger TrapezoidalCell_Avatar_title_gap = 13;
static NSInteger TrapezoidalCell_Avatar_content_gap = 10;
static NSInteger TrapezoidalCell_Title_gap_right = 10;
static NSInteger TrapezoidalCell_Content_left = 10;
static NSInteger TrapezoidalCell_Content_right = 10;
static NSInteger TrapezoidalCell_Content_bottom = 13;

static NSInteger TrapezoidalCell_ContentImageView_left = 13;
static NSInteger TrapezoidalCell_ContentImageView_right = 10;
static NSInteger TrapezoidalCell_ContentImageView_bottomControl_gap = 10;  // ContentImageView与其下方的控件之间的间隔
static CGFloat TrapezoidalCell_ContentImageView_width_height_rate = 16/9.;

NS_ASSUME_NONNULL_BEGIN

@interface TrapezoidalCell : BaseCell

@property (nonatomic) QATrapezoidalLabel *trapezoidalLabel;

/**
 设置文案与单行的行高度
 
 @param trapezoidalTexts 显示文本
 @param lineHeight 单行行高
 */
- (void)setTrapezoidalTexts:(NSDictionary *)trapezoidalTexts lineHeight:(CGFloat)lineHeight;

@end

NS_ASSUME_NONNULL_END
