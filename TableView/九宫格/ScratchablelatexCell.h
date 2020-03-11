//
//  ScratchablelatexCell.h
//  TestProject
//
//  Created by Avery An on 2019/9/8.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "BaseCell.h"
#import "QARichTextLabel.h"

static NSInteger DefaultTag_contentImageView = 10;
static NSInteger MaxLines = 3;      // 最多显示3行
static NSInteger MaxItems = 3;      // 一行最多显示3张
static NSInteger AvatarSize = 38;
static NSInteger Avatar_left_gap = 13;
static NSInteger Avatar_top_gap = 10;
static NSInteger Avatar_title_gap = 13;
static NSInteger Title_gap_right = 13;
static NSInteger Avatar_bottomControl_gap = 10;     // 头像与其下方的控件之间的间隔
static NSInteger Content_bottom_gap = 10;
static NSInteger Title_height = 18;
static NSInteger Desc_height = 18;

static NSInteger ContentImageView_left = 13;
static NSInteger ContentImageView_right = 13;
static NSInteger ContentImageView_gap = 6;                  // 九宫格之间的间隔
static NSInteger ContentImageView_bottomControl_gap = 10;   // ContentImageView与其下方的控件之间的间隔
static CGFloat ContentImageView_width_height_rate = 16/9.;

typedef NS_ENUM(int, ScratchablelatexCell_TapedPosition) {
    ScratchablelatexCell_Taped_Null = -1,
    ScratchablelatexCell_Taped_First = 0,       // 点中了第1张图片
    ScratchablelatexCell_Taped_Second,          // 点中了第2张图片
    ScratchablelatexCell_Taped_Third,           // 点中了第3张图片
    ScratchablelatexCell_Taped_Fourth,          // 点中了第4张图片
    ScratchablelatexCell_Taped_Fifth,           // 点中了第5张图片
    ScratchablelatexCell_Taped_Six,             // 点中了第6张图片
    ScratchablelatexCell_Taped_Seven,           // 点中了第7张图片
    ScratchablelatexCell_Taped_Eight,           // 点中了第8张图片
    ScratchablelatexCell_Taped_Nine             // 点中了第9张图片
};


NS_ASSUME_NONNULL_BEGIN

@interface ScratchablelatexCell : BaseCell

@property (nonatomic) QARichTextLabel *styleLabel;

/**
 如果不显示gif、最好使用Calayer来代替UIImageView
 */
@property (nonatomic) UIImageView *contentImageView_1;
@property (nonatomic) UIImageView *contentImageView_2;
@property (nonatomic) UIImageView *contentImageView_3;
@property (nonatomic) UIImageView *contentImageView_4;
@property (nonatomic) UIImageView *contentImageView_5;
@property (nonatomic) UIImageView *contentImageView_6;
@property (nonatomic) UIImageView *contentImageView_7;
@property (nonatomic) UIImageView *contentImageView_8;
@property (nonatomic) UIImageView *contentImageView_9;
@property (nonatomic, copy) void (^ _Nullable scratchablelatexCellTapImageAction)(ScratchablelatexCell *cell, id tapedObject, ScratchablelatexCell_TapedPosition tapedPosition, NSDictionary *contentImageViewInfo);

/**
 存放需要显示的控件以及控件的样式
 dic: key(property) - value(CGRectValue)
 */
- (void)showStytle:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
