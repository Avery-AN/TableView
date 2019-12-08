//
//  QAAttributedLabel.m
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QAAttributedLabel.h"
#import "QAAttributedLayer.h"
#import "QATextLayout.h"
#import "QATextDrawer.h"


#define LinkHighlight_MASK          (1 << 0)  // 0000 0001
#define ShowShortLink_MASK          (1 << 1)  // 0000 0010
#define AtHighlight_MASK            (1 << 2)  // 0000 0100
#define TopicHighlight_MASK         (1 << 3)  // 0000 1000
#define ShowMoreText_MASK           (1 << 4)  // 0001 0000
#define Display_async_MASK          (1 << 5)  // 0010 0000

#define TapedLink_MASK              (1 << 0)  // 0000 0001
#define TapedAt_MASK                (1 << 1)  // 0000 0010
#define TapedTopic_MASK             (1 << 2)  // 0000 0100
#define TapedMore_MASK              (1 << 3)  // 0000 1000
#define Touching_MASK               (1 << 4)  // 0001 0000

typedef struct {
    char linkHighlight : 1;
    char showShortLink : 1;
    char atHighlight : 1;
    char topicHighlight : 1;
    char showMoreText : 1;
    char display_async : 1;
} Bits_struct_property;
typedef union {
    char bits;  // char 占用1个字节
    Bits_struct_property bits_struct;
} Bits_union_property;


typedef struct {
    char tapedLink : 1;
    char tapedAt : 1;
    char tapedTopic : 1;
    char tapedSeeMore : 1;
    char touching : 1;
} Bits_struct_taped;
typedef union {
    char bits;  // char 占用1个字节
    Bits_struct_taped bits_struct;
} Bits_union_taped;

static void *TouchingContext = &TouchingContext;

@interface QAAttributedLabel () {
    Bits_union_property _bits_union_property;
    Bits_union_taped _bits_union_taped;
    NSMutableArray *_searchRanges;
    NSDictionary *_searchAttributeInfo;
}
@property (nonatomic, copy, nullable) NSString *tapedHighlightContent;
@property (nonatomic, assign) NSRange tapedHighlightRange;
@end

@implementation QAAttributedLabel

#pragma mark - Life Cycle -
- (void)dealloc {
//    NSLog(@" %s",__func__);
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];  // 初始化一些默认值
    }
    return self;
}
- (void)setUp {
    _lineBreakMode = NSLineBreakByWordWrapping;
    _textColor = [UIColor blackColor];
    _font = [UIFont systemFontOfSize:14];
    _numberOfLines = 0;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.contentsScale = [UIScreen mainScreen].scale;
}


#pragma mark - Override Methods -
+ (Class)layerClass {
    return [QAAttributedLayer class];
}

/**
 此处只处理了高度的自适应
 */
- (void)sizeToFit {
    CGRect frame = self.frame;
    CGSize size = [self getContentSize];

    if (frame.size.height - size.height > 0.) {
        QAAttributedLayer *layer = (QAAttributedLayer *)self.layer;
        CGImageRef currentCGImage = (__bridge CGImageRef)(layer.currentCGImage);
        if (!currentCGImage) {
            return;
        }
        CGImageRef newCGImage = [UIImage cutCGImage:currentCGImage withRect:(CGRect){{0, 0}, self.textLayout.textBoundSize}];
        layer.contents = (__bridge id _Nullable)(newCGImage);
        
        self.frame = (CGRect) {frame.origin, size};
    }
    else if (frame.size.height - size.height == 0.) {
        return;
    }
    else {
        /*
         一种方案是在这里进行重绘 (需要处理下layer的display逻辑、将layer.attributedText_backup置为nil)
         另外一种方案就是绘制的时候将frame设置到最大、不按照label.bounds来绘制、显示的时候再对image进行裁剪。
         */
        self.frame = (CGRect) {frame.origin, size};
        [self.layer setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // NSLog(@" %s",__func__);

    self.tapedHighlightContent = nil;
    CGPoint point = [[touches anyObject] locationInView:self];
    QAAttributedLayer *layer = (QAAttributedLayer *)self.layer;
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(isTouching))];
    _bits_union_taped.bits |= Touching_MASK;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isTouching))];
    
    // 处理"...查看全文":
    NSMutableAttributedString *attributedText = self.attributedText;
    if (self.numberOfLines != 0 && self.showMoreText && attributedText.showMoreTextEffected) {
        NSDictionary *highlightFrameDic = layer.textDrawer.highlightFrameDic; // (key:range - value:CGRect-array)
        NSString *truncationRangeKey = [attributedText.truncationInfo valueForKey:@"truncationRange"];
        if (truncationRangeKey) {
            NSRange truncationRange = NSRangeFromString(truncationRangeKey);
            NSArray *highlightRects = [highlightFrameDic valueForKey:truncationRangeKey];
            for (NSValue *value in highlightRects) {
                CGRect frame = [value CGRectValue];
                if (CGRectContainsPoint(frame, point)) {
                    self.tapedHighlightRange = truncationRange;
                    [layer drawHighlightColor:truncationRange];

                    self.tapedHighlightContent = self.seeMoreText;
                    _bits_union_taped.bits |= TapedMore_MASK;

                    return;
                }
            }
        }
    }

    // 处理高亮文案的点击效果:
    if (self.atHighlight || self.linkHighlight || self.topicHighlight) {
        // 获取self的属性:
        NSDictionary *highlightFrameDic = layer.textDrawer.highlightFrameDic; // (key:range - value:CGRect-array)
        for (NSString *key in highlightFrameDic) {
            NSArray *highlightRects = [highlightFrameDic valueForKey:key];

            for (int i = 0; i < highlightRects.count; i++) {
                NSValue *value = [highlightRects objectAtIndex:i];
                CGRect frame = [value CGRectValue];
                
                if (CGRectContainsPoint(frame, point)) {
                    NSRange highlightRange = NSRangeFromString(key);
                    self.tapedHighlightRange = highlightRange;
                    [layer drawHighlightColor:highlightRange];

                    NSDictionary *highlightTextDic = attributedText.textDic;
                    if (highlightTextDic && highlightTextDic.count > 0) {
                        NSString *key = NSStringFromRange(highlightRange);
                        NSString *highlightText = [highlightTextDic valueForKey:key];
                        NSString *tapedType = [self.attributedText.textTypeDic valueForKey:key];
                        if (!tapedType) {
                            return;
                        }
                        else if ([tapedType isEqualToString:@"link"]) {
                            _bits_union_taped.bits |= TapedLink_MASK;
                        }
                        else if ([tapedType isEqualToString:@"at"]) {
                            _bits_union_taped.bits |= TapedAt_MASK;
                        }
                        else if ([tapedType isEqualToString:@"topic"]) {
                            _bits_union_taped.bits |= TapedTopic_MASK;
                        }
                        self.tapedHighlightContent = highlightText;
                        
                        return;
                    }
                }
            }
        }
    }

    [self.nextResponder touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    // NSLog(@" %s",__func__);
    
    if (self.tapedHighlightContent && self.tapedHighlightContent.length > 0) {
        QAAttributedLayer *layer = (QAAttributedLayer *)self.layer;
        [layer clearHighlightColor:self.tapedHighlightRange];

        if (self.QAAttributedLabelTapAction) {
            __weak typeof(self) weakSelf = self;

            if (!!(_bits_union_taped.bits & TapedMore_MASK)) {
                self.QAAttributedLabelTapAction(weakSelf.tapedHighlightContent, QAAttributedLabel_Taped_More);
                _bits_union_taped.bits &= ~TapedMore_MASK;
            }
            else if (!!(_bits_union_taped.bits & TapedLink_MASK)) {
                self.QAAttributedLabelTapAction(weakSelf.tapedHighlightContent, QAAttributedLabel_Taped_Link);
                _bits_union_taped.bits &= ~TapedLink_MASK;
            }
            else if (!!(_bits_union_taped.bits & TapedAt_MASK)) {
                self.QAAttributedLabelTapAction(weakSelf.tapedHighlightContent, QAAttributedLabel_Taped_At);
                _bits_union_taped.bits &= ~TapedAt_MASK;
            }
            else if (!!(_bits_union_taped.bits & TapedTopic_MASK)) {
                self.QAAttributedLabelTapAction(weakSelf.tapedHighlightContent, QAAttributedLabel_Taped_Topic);
                _bits_union_taped.bits &= ~TapedTopic_MASK;
            }
        }
    }
    else {
        self.QAAttributedLabelTapAction(@"点击了label自身", QAAttributedLabel_Taped_Label);
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(isTouching))];
    _bits_union_taped.bits &= ~Touching_MASK;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isTouching))];

    [self.nextResponder touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    // NSLog(@" %s",__func__);
    
    if (self.tapedHighlightContent && self.tapedHighlightContent.length > 0) {
        QAAttributedLayer *layer = (QAAttributedLayer *)self.layer;
        [layer clearHighlightColor:self.tapedHighlightRange];
    }
    
    if (!!(_bits_union_taped.bits & TapedMore_MASK)) {
        _bits_union_taped.bits &= ~TapedMore_MASK;
    }
    else if (!!(_bits_union_taped.bits & TapedLink_MASK)) {
        _bits_union_taped.bits &= ~TapedLink_MASK;
    }
    else if (!!(_bits_union_taped.bits & TapedAt_MASK)) {
        _bits_union_taped.bits &= ~TapedAt_MASK;
    }
    else if (!!(_bits_union_taped.bits & TapedTopic_MASK)) {
        _bits_union_taped.bits &= ~TapedTopic_MASK;
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(isTouching))];
    _bits_union_taped.bits &= ~Touching_MASK;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isTouching))];
    
    [self.nextResponder touchesCancelled:touches withEvent:event];
}


#pragma mark - Public Methods -
- (void)getTextContentSizeWithLayer:(QAAttributedLayer * _Nonnull)layer
                            content:(id _Nonnull)content
                           maxWidth:(CGFloat)width
                    completionBlock:(GetTextContentSizeBlock _Nullable)block {
    if (!content ||
        (![content isKindOfClass:[NSAttributedString class]] &&
        ![content isKindOfClass:[NSString class]])) {
        return;
    }
    self.getTextContentSizeBlock = block;
    
    NSMutableAttributedString *attributedString = nil;
    if ([content isKindOfClass:[NSAttributedString class]]) {
        attributedString = content;
    }
    else {
        attributedString = [layer getAttributedStringWithString:content
                                                       maxWidth:width];
    }
    
    CGSize suggestedSize = [QAAttributedStringSizeMeasurement textSizeWithAttributeString:attributedString
                                                                     maximumNumberOfLines:self.numberOfLines
                                                                                 maxWidth:width];
    
    /*
     dispatch_async(dispatch_get_main_queue(), ^{
        if (self.getTextContentSizeBlock) {
            self.getTextContentSizeBlock(suggestedSize, attributedString);
        }
    });
     */
    
    if (self.getTextContentSizeBlock) {
        self.getTextContentSizeBlock(suggestedSize, attributedString);
    }
}
- (void)setContentsImage:(UIImage * _Nonnull)image
        attributedString:(NSMutableAttributedString * _Nonnull)attributedString {
    if (!image || !attributedString) {
        return;
    }
    else if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        return;
    }
    
    QAAttributedLayer *layer = (QAAttributedLayer *)self.layer;
    layer.contents = (__bridge id _Nullable)(image.CGImage);
    
    // 后台绘制attributedString (作用是:在layer.textDrawer中保存highlightFrameDic的值以供点击高亮文本时使用)
    [layer drawTextBackgroundWithAttributedString:attributedString];
}
- (void)searchTexts:(NSArray * _Nonnull)texts resetSearchResultInfo:(NSDictionary * _Nullable (^_Nullable)(void))searchResultInfo {
    if (!texts || texts.count == 0) {
        return;
    }
    
    NSMutableArray *searchRanges = [NSMutableArray array];
    [self.attributedText searchTexts:texts saveWithRangeArray:&searchRanges];
    if (searchRanges.count > 0) {
        NSDictionary *info = searchResultInfo();
        if (self.isTouching == NO) {
            [self processSearchResult:searchRanges searchAttributeInfo:info];
        }
        else {
            _searchRanges = searchRanges;
            _searchAttributeInfo = info;
            [self addObserver:self forKeyPath:NSStringFromSelector(@selector(isTouching)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:TouchingContext];
        }
    }
}


#pragma mark - Private Methods -
- (void)updateText:(NSString *)text {
    _text = text;
}
- (void)updateAttributedText:(NSMutableAttributedString *)attributedText {
    if ([attributedText isKindOfClass:[NSMutableAttributedString class]]) {
        _attributedText = attributedText;
    }
    else {
        _attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    }
}
- (CGSize)getContentSize {
    NSMutableAttributedString *attributedText;
    if (self.attributedText && self.attributedText.string &&
        self.attributedText.length > 0 && self.attributedText.string.length > 0) {
        attributedText = self.attributedText;
    }
    else {
        [self.textLayout getTextAttributes];
        attributedText = [[NSMutableAttributedString alloc] initWithString:self.text attributes:self.textLayout.textAttributes];
    }
    
    CGSize size = CGSizeZero;
    if (self.textLayout) {
        [self.textLayout setupContainerSize:(CGSize){self.bounds.size.width, CGFLOAT_MAX} attributedText:attributedText];
        size = self.textLayout.textBoundSize;
    }
    else {
        size = [QAAttributedStringSizeMeasurement calculateSizeWithString:attributedText maxWidth:self.bounds.size.width];
    }
    return size;
}
- (void)processSearchResult:(NSMutableArray *)searchRanges searchAttributeInfo:(NSDictionary *)info {
    self.attributedText.searchRanges = searchRanges;
    self.attributedText.searchAttributeInfo = info;
    
    if (searchRanges && [searchRanges isKindOfClass:[NSArray class]] && searchRanges.count > 0 &&
        info && [info isKindOfClass:[NSDictionary class]] && info.count > 0) {
        QAAttributedLayer *layer = (QAAttributedLayer *)self.layer;
        [layer drawHighlightColorWithSearchRanges:searchRanges attributeInfo:info];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == TouchingContext) {
        if (keyPath && [keyPath isEqualToString:NSStringFromSelector(@selector(isTouching))]) {
            NSString *oldKey = [change objectForKey:NSKeyValueChangeOldKey];
            NSString *newKey = [change objectForKey:NSKeyValueChangeNewKey];
            
            if (oldKey.intValue == 1 && newKey.intValue == 0) {
                [self processSearchResult:_searchRanges searchAttributeInfo:_searchAttributeInfo];
                
                [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(isTouching))];
            }
        }
    }
}


#pragma mark - Properties -
- (void)setLinkHighlight:(BOOL)linkHighlight {
    if (linkHighlight) {
        _bits_union_property.bits |= LinkHighlight_MASK;
    }
    else {
        _bits_union_property.bits &= ~LinkHighlight_MASK;
    }
}
- (BOOL)linkHighlight {
    return !!(_bits_union_property.bits & LinkHighlight_MASK); //位移后的值不一定是bool类型、2次取反操作可以将任何类型数据变为bool
}
- (void)setShowShortLink:(BOOL)showShortLink {
    if (showShortLink) {
        _bits_union_property.bits |= ShowShortLink_MASK;
    }
    else {
        _bits_union_property.bits &= ~ShowShortLink_MASK;
    }
}
- (BOOL)showShortLink {
    return !!(_bits_union_property.bits & ShowShortLink_MASK);
}
- (void)setAtHighlight:(BOOL)atHighlight {
    if (atHighlight) {
        _bits_union_property.bits |= AtHighlight_MASK;
    }
    else {
        _bits_union_property.bits &= ~AtHighlight_MASK;
    }
}
- (BOOL)atHighlight {
    return !!(_bits_union_property.bits & AtHighlight_MASK);
}
- (void)setTopicHighlight:(BOOL)topicHighlight {
    if (topicHighlight) {
        _bits_union_property.bits |= TopicHighlight_MASK;
    }
    else {
        _bits_union_property.bits &= ~TopicHighlight_MASK;
    }
}
- (BOOL)topicHighlight {
    return !!(_bits_union_property.bits & TopicHighlight_MASK);
}
- (void)setShowMoreText:(BOOL)showMoreText {
    if (showMoreText) {
        _bits_union_property.bits |= ShowMoreText_MASK;
    }
    else {
        _bits_union_property.bits &= ~ShowMoreText_MASK;
    }
}
- (BOOL)showMoreText {
    return !!(_bits_union_property.bits & ShowMoreText_MASK);
}
- (void)setDisplay_async:(BOOL)display_async {
    if (display_async) {
        _bits_union_property.bits |= Display_async_MASK;
    }
    else {
        _bits_union_property.bits &= ~Display_async_MASK;
    }
}
- (BOOL)display_async {
    return !!(_bits_union_property.bits & Display_async_MASK);
}
- (BOOL)isTouching {
    return !!(_bits_union_taped.bits & Touching_MASK);
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.textLayout.font = font;
}
- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    self.textLayout.textAlignment = _textAlignment;
}
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    _lineBreakMode = lineBreakMode;
    self.textLayout.lineBreakMode = _lineBreakMode;
}
- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.textLayout.textColor = _textColor;
}
- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    if (numberOfLines < 0) {
        numberOfLines = 0;
    }
    _numberOfLines = numberOfLines;
    self.textLayout.numberOfLines = _numberOfLines;
}
- (void)setLineSpace:(CGFloat)lineSpace {
    _lineSpace = lineSpace;
    self.textLayout.lineSpace = _lineSpace;
}
- (void)setWordSpace:(NSUInteger)wordSpace {
    _wordSpace = wordSpace;
    self.textLayout.wordSpace = _wordSpace;
}
- (void)setParagraphSpace:(CGFloat)paragraphSpace {
    _paragraphSpace = paragraphSpace;
    self.textLayout.paragraphSpace = _paragraphSpace;
}
- (void)setHighlightFont:(UIFont *)highlightFont {
    _highlightFont = highlightFont;
}
- (void)setHighlightTextColor:(UIColor *)highlightTextColor {
    _highlightTextColor = highlightTextColor;
}
- (void)setHighlightTextBackgroundColor:(UIColor *)highlightTextBackgroundColor {
    _highlightTextBackgroundColor = highlightTextBackgroundColor;
}
- (void)setHighlightTapedBackgroundColor:(UIColor *)highlightTapedBackgroundColor {
    _highlightTapedBackgroundColor = highlightTapedBackgroundColor;
}
- (void)setSeeMoreText:(NSString *)seeMoreText {
    _seeMoreText = seeMoreText;
}
- (void)setMoreTextFont:(UIFont *)moreTextFont {
    _moreTextFont = moreTextFont;
    self.textLayout.moreTextFont = _moreTextFont;
}
- (void)setMoreTextColor:(UIColor *)moreTextColor {
    _moreTextColor = moreTextColor;
    self.textLayout.moreTextColor = _moreTextColor;
}
- (void)setMoreTextBackgroundColor:(UIColor *)moreTextBackgroundColor {
    _moreTextBackgroundColor = moreTextBackgroundColor;
    self.textLayout.moreTextBackgroundColor = _moreTextBackgroundColor;
}
- (void)setMoreTapedBackgroundColor:(UIColor *)moreTapedBackgroundColor {
    _moreTapedBackgroundColor = moreTapedBackgroundColor;
}

- (void)setText:(NSString *)text {
    _text = text;
    self.attributedText = nil;
}
- (void)setAttributedText:(NSMutableAttributedString *)attributedText {
    if (!attributedText || attributedText.length == 0) {
        _attributedText = nil;
    }
    else if ([attributedText isKindOfClass:[NSMutableAttributedString class]]) {
        _attributedText = attributedText;
    }
    else {
        _attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    }
    
    if ([NSThread isMainThread]) {
        [self.layer setNeedsDisplay];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.layer setNeedsDisplay];
        });
    }
}

- (QATextLayout *)textLayout {
    if (!_textLayout) {
        _textLayout = [QATextLayout new];
    }
    return _textLayout;
}

- (NSInteger)length {
    return self.attributedText.length;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
