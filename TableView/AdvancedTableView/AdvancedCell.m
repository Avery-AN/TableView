//
//  AdvancedCell.m
//  TestProject
//
//  Created by Avery An on 2019/8/25.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "AdvancedCell.h"

@implementation AdvancedCell

#pragma mark - Life Cycle -
- (void)dealloc {
//    NSLog(@"%s",__func__);
}


#pragma MARK - Property -
- (QAAttributedLabel *)styleLabel {
    if (!_styleLabel) {
        NSInteger content_width = UIWidth - Avatar_left_gap - Avatar_left_gap;
        NSInteger content_height = 15;
        _styleLabel = [[QAAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, content_width, content_height)];
        _styleLabel.backgroundColor = [UIColor whiteColor];
        _styleLabel.font = [UIFont systemFontOfSize:18];
//        _styleLabel.font = [UIFont fontWithName:@"AvenirNext-HeavyItalic" size:20];
        _styleLabel.textColor = HEXColor(@"666666");
        _styleLabel.lineSpace = 1.1;
        _styleLabel.wordSpace = 3;
        _styleLabel.display_async = YES;
        _styleLabel.linkHighlight = YES;
        _styleLabel.atHighlight = YES;
//        _styleLabel.showShortLink = YES;
//        _styleLabel.shortLink = @"这里就是网址呀";
//        _styleLabel.numberOfLines = 3;
        _styleLabel.numberOfLines = 21;
        _styleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _styleLabel.topicHighlight = YES;
        _styleLabel.showMoreText = YES;
        _styleLabel.seeMoreText = @"...查看全文";
        _styleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _styleLabel.moreTextColor = [UIColor purpleColor];
        _styleLabel.moreTapedTextColor = [UIColor greenColor];
        _styleLabel.textAlignment = NSTextAlignmentJustified;
//        _styleLabel.textAlignment = NSTextAlignmentLeft;
        _styleLabel.highLightTexts = [NSArray arrayWithObjects:@"大量添加控件",@"直接绘制", nil];
        _styleLabel.highlightTextColor = [UIColor purpleColor];
        _styleLabel.highlightTapedTextColor = [UIColor greenColor];
//        _styleLabel.highlightTapedBackgroundColor = [UIColor grayColor];
        _styleLabel.highlightAtTextColor = [UIColor greenColor];
        _styleLabel.highlightLinkTextColor = [UIColor orangeColor];
        _styleLabel.highlightTopicTextColor = [UIColor magentaColor];
        _styleLabel.highlightAtTapedTextColor = [UIColor redColor];
        _styleLabel.highlightLinkTapedTextColor = [UIColor blueColor];
        _styleLabel.highlightTopicTapedTextColor = [UIColor greenColor];
    }
    return _styleLabel;
}

@end
