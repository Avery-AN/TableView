//
//  RichTextCell.h
//  TestProject
//
//  Created by Avery An on 2019/8/25.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "BaseCell.h"

static NSInteger AvatarSize = 38;
static NSInteger Avatar_left_gap = 13;
static NSInteger Avatar_top_gap = 13;
static NSInteger Avatar_title_gap = 13;
static NSInteger Title_gap_right = 10;
static NSInteger Avatar_bottomControl_gap = 10;  // 头像与其下方的控件之间的间隔
static NSInteger Content_bottom_gap = 10;
static NSInteger Title_height = 18;
static NSInteger Desc_height = 18;

static NSInteger ContentImageView_left = 13;
static NSInteger ContentImageView_right = 10;
static NSInteger ContentImageView_bottomControl_gap = 10;  // ContentImageView与其下方的控件之间的间隔
static CGFloat ContentImageView_width_height_rate = 16/9.;


NS_ASSUME_NONNULL_BEGIN

@interface RichTextCell : BaseCell

@property (nonatomic) QARichTextLabel *styleLabel;

@end

NS_ASSUME_NONNULL_END
