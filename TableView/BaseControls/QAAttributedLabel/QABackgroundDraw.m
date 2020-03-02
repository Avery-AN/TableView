//
//  QABackgroundDraw.m
//  CoreText
//
//  Created by Avery An on 2020/2/25.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QABackgroundDraw.h"

static CGFloat minRadius = 1;   // 最小弧度

@implementation QABackgroundDraw

#pragma mark - Public Methods -
+ (void)drawBackgroundWithRects:(NSArray * _Nonnull)rects
                         radius:(CGFloat)radius
                backgroundColor:(UIColor * _Nonnull)backgroundColor {
    if (!backgroundColor) {
        return;
    }
    else if (!rects || rects.count == 0 || [backgroundColor isEqual:[UIColor clearColor]]) {
        return;
    }
    else if (radius - minRadius < 0) {
        radius = minRadius;
    }
    
    for (id obj in rects) {
        CGRect rect = [obj CGRectValue];
        CGRect newRect = CGRectMake(ceil(rect.origin.x), ceil(rect.origin.y), ceil(rect.size.width), ceil(rect.size.height));
        
        NSMutableArray *dots = [NSMutableArray array];
        [self getDotsWithRect:newRect dots:dots];
        [self drawWithDots:dots radius:radius backgroundColor:backgroundColor];
    }
}

+ (UIBezierPath *)drawBackgroundWithMaxWidth:(CGFloat)maxWidth
                                  lineWidths:(NSArray * _Nonnull)lineWidths
                                  lineHeight:(CGFloat)lineHeight
                                      radius:(CGFloat)radius
                               textAlignment:(Background_TextAlignment)textAlignment
                             backgroundColor:(UIColor * _Nonnull)backgroundColor {
    if (!backgroundColor) {
        return nil;
    }
    else if ([backgroundColor isEqual:[UIColor clearColor]]) {
        return nil;
    }
    else if (radius - minRadius < 0) {
        radius = minRadius;
    }
    
    NSMutableArray *dots = [NSMutableArray array];
    [self getDotsWithMaxWidth:maxWidth lineWidths:lineWidths lineHeight:lineHeight textAlignment:textAlignment dots:dots];
    
    UIBezierPath *path = [self drawWithDots:dots radius:radius backgroundColor:backgroundColor];
    return path;
}

+ (UIBezierPath *)drawWithDots:(NSArray *)dots
                        radius:(CGFloat)radius
               backgroundColor:(UIColor *)backgroundColor {
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < dots.count; i++) {
        NSInteger previous = i - 1;
        if (i == 0) {
            previous = dots.count - 1;
        }
        NSInteger next = i + 1;
        if (i == dots.count - 1) {
            next = 0;
        }
        NSValue *previousValue = [dots objectAtIndex:previous];
        CGPoint previousPoint = previousValue.CGPointValue;
        NSValue *currentValue = [dots objectAtIndex:i];
        CGPoint currentPoint = currentValue.CGPointValue;
        NSValue *nextValue = [dots objectAtIndex:next];
        CGPoint nextPoint = nextValue.CGPointValue;
        [self drawWithPath:path
             previousPoint:previousPoint
              currentPoint:currentPoint
                 nextPoint:nextPoint
                    radius:radius];
    }
    
    UIColor *fillColor = backgroundColor;
    [fillColor set];
    [path fill];
    
    return path;
}


#pragma mark - Private Methods -
+ (void)getDotsWithRect:(CGRect)rect
                   dots:(NSMutableArray *)dots {
    CGPoint point_1 = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint point_2 = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    CGPoint point_3 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGPoint point_4 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    [dots addObject:[NSValue valueWithCGPoint:point_1]];
    [dots addObject:[NSValue valueWithCGPoint:point_2]];
    [dots addObject:[NSValue valueWithCGPoint:point_3]];
    [dots addObject:[NSValue valueWithCGPoint:point_4]];
}
+ (void)getDotsWithMaxWidth:(CGFloat)viewWidth
                 lineWidths:(NSArray *)lineWidths
                 lineHeight:(CGFloat)lineHeight
              textAlignment:(Background_TextAlignment)textAlignment
                       dots:(NSMutableArray *)dots {
    NSInteger dotCounts = 0;
    if (textAlignment == Background_TextAlignment_Center) {
        dotCounts = 4 * lineWidths.count;   // 总点数
        [self getCenterDotsWithMaxWidth:viewWidth
                             lineWidths:lineWidths
                             lineHeight:lineHeight
                              dotCounts:dotCounts
                                   dots:dots];
    }
    else {
        dotCounts = 2 * lineWidths.count + 2;   // 总点数
        [self getBothendsDotsWithMaxWidth:viewWidth
                               lineWidths:lineWidths
                               lineHeight:lineHeight
                                dotCounts:dotCounts
                            textAlignment:textAlignment
                                     dots:dots];
    }
}
+ (void)getBothendsDotsWithMaxWidth:(CGFloat)viewWidth
                         lineWidths:(NSArray *)lineWidths
                         lineHeight:(CGFloat)lineHeight
                          dotCounts:(NSInteger)dotCounts
                      textAlignment:(Background_TextAlignment)textAlignment
                               dots:(NSMutableArray *)dots {
    for (int dotIndex = 0; dotIndex < dotCounts; dotIndex++) {
        NSInteger currentLine = 0;
        CGFloat currentX = 0;
        CGFloat currentY = 0;
        CGFloat lineWidth = 0;
        if (textAlignment == Background_TextAlignment_Left) {
            if (dotIndex == 0) {
                currentLine = 0;   // 当前点所在的行数
                lineWidth = [[lineWidths objectAtIndex:currentLine] floatValue];
                currentX = 0;
                currentY = 0;
            }
            else if (dotIndex == 1) {
                currentLine = lineWidths.count - 1;
                lineWidth = [[lineWidths objectAtIndex:currentLine] floatValue];
                currentX = 0;
                currentY = lineHeight * lineWidths.count;
            }
            else {
                currentLine = ((dotCounts-1) - dotIndex) / 2;
                lineWidth = [[lineWidths objectAtIndex:currentLine] floatValue];
                currentX = lineWidth;
                currentY = (dotCounts - dotIndex) / 2 * lineHeight;
            }
        }
        else {
            if (dotIndex == dotCounts - 1) {
                currentLine = 0;   // 当前点所在的行数
                lineWidth = [[lineWidths objectAtIndex:currentLine] floatValue];
                currentX = viewWidth;
                currentY = 0;
            }
            else if (dotIndex == dotCounts - 2) {
                currentLine = lineWidths.count - 1;
                lineWidth = [[lineWidths objectAtIndex:currentLine] floatValue];
                currentX = viewWidth;
                currentY = lineHeight * lineWidths.count;
            }
            else {
                currentLine = dotIndex / 2;
                lineWidth = [[lineWidths objectAtIndex:currentLine] floatValue];
                currentX = viewWidth - lineWidth;
                currentY = (dotIndex+1) / 2 * lineHeight;
            }
        }
        
        CGPoint currentPoint = CGPointMake(currentX, currentY);
        [dots addObject:[NSValue valueWithCGPoint:currentPoint]];
    }
}
+ (void)getCenterDotsWithMaxWidth:(CGFloat)viewWidth
                       lineWidths:(NSArray *)lineWidths
                       lineHeight:(CGFloat)lineHeight
                        dotCounts:(NSInteger)dotCounts
                             dots:(NSMutableArray *)dots {
    for (int dotIndex = 0; dotIndex < dotCounts; dotIndex++) {
        NSInteger currentLine = 0;
        if (dotIndex < dotCounts/2) {
            currentLine = dotIndex/2;   // 当前点所在的行数
        }
        else {
            currentLine = ((dotCounts-1)-dotIndex)/2;
        }
        CGFloat lineWidth = [[lineWidths objectAtIndex:currentLine] floatValue];
        
        CGFloat currentX = 0;
        if (dotIndex < dotCounts/2) {
            currentX = (viewWidth - lineWidth) / 2;
        }
        else {
            currentX = (viewWidth - lineWidth) / 2 + lineWidth;
        }
        
        CGFloat currentY = 0;
        if (dotIndex < dotCounts/2) {
            currentY = (dotIndex+1)/2 * lineHeight;
        }
        else {
            currentY = (dotCounts-dotIndex)/2 * lineHeight;
        }
        
        CGPoint currentPoint = CGPointMake(currentX, currentY);
        [dots addObject:[NSValue valueWithCGPoint:currentPoint]];
    }
}

// 两点之间进行绘制 (只绘制中间位置处的弧度、逆时针方向)
+ (void)drawWithPath:(UIBezierPath *)path
       previousPoint:(CGPoint)previousPoint
        currentPoint:(CGPoint)currentPoint
           nextPoint:(CGPoint)nextPoint
              radius:(CGFloat)radius {
    // 前后两个点重合的情况
    if ((currentPoint.x - nextPoint.x == 0 && currentPoint.y - nextPoint.y == 0) ||
        (currentPoint.x - previousPoint.x == 0 && currentPoint.y - previousPoint.y == 0)) {
        return;
    }
    
    // 正规的四边形 (全是逆时针绘制):
    if (previousPoint.x - currentPoint.x > 0 && previousPoint.y - currentPoint.y == 0 &&
        currentPoint.x - nextPoint.x == 0 && nextPoint.y - currentPoint.y > 0) {  // 左上角(逆时针)
        [self drawLeftTopCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:NO];
        // NSLog(@"左上角-逆时针 (正规四边形)");
    }
    else if (previousPoint.x - currentPoint.x == 0 && previousPoint.y - currentPoint.y < 0 &&
             currentPoint.x - nextPoint.x < 0 && nextPoint.y - currentPoint.y == 0) {  // 左下角(逆时针)
        [self drawLeftDownCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:NO];
        // NSLog(@"左下角-逆时针 (正规四边形)");
    }
    else if (previousPoint.x - currentPoint.x < 0 && previousPoint.y - currentPoint.y == 0 &&
             currentPoint.x - nextPoint.x == 0 && nextPoint.y - currentPoint.y < 0) {  // 右下角(逆时针)
        [self drawRightDownCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:NO];
        // NSLog(@"右下角-逆时针 (正规四边形)");
    }
    else if (previousPoint.x - currentPoint.x == 0 && previousPoint.y - currentPoint.y > 0 &&
             currentPoint.x - nextPoint.x > 0 && nextPoint.y - currentPoint.y == 0) {  // 右上角(逆时针)
        [self drawRightUpCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:NO];
        // NSLog(@"右上角-逆时针 (正规四边形)");
    }
    
    // 十字形(交叉点处的4个角):
    else if (previousPoint.x - currentPoint.x == 0 && previousPoint.y - currentPoint.y < 0 &&
        currentPoint.x - nextPoint.x > 0 && nextPoint.y - currentPoint.y == 0) {  // 右下角(顺时针)
        [self drawRightDownCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:YES];
        // NSLog(@"右下角-顺时针 (十字形)");
    }
    else if (previousPoint.x - currentPoint.x < 0 && previousPoint.y - currentPoint.y == 0 &&
             currentPoint.x - nextPoint.x == 0 && nextPoint.y - currentPoint.y > 0) {  // 右上角(顺时针)
        if (fabs(previousPoint.x - currentPoint.x) < 2*radius) {
            // NSLog(@"左上角-逆时针 (特殊)");
            [self drawLeftTopCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:NO];
        }
        else {
            [self drawRightUpCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:YES];
            // NSLog(@"右上角-顺时针 (十字形)");
        }
    }
    else if (previousPoint.x - currentPoint.x == 0 && previousPoint.y - currentPoint.y > 0 &&
             currentPoint.x - nextPoint.x < 0 && nextPoint.y - currentPoint.y == 0) {  // 左上角(顺时针)
        if (fabs(currentPoint.x - nextPoint.x) < 2*radius) {
            [self drawRightUpCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:NO];
            // NSLog(@"右上角-逆时针 (特殊)");
        }
        else {
            [self drawLeftTopCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:YES];
            // NSLog(@"左上角-顺时针 (十字形)");
        }
    }
    else if (previousPoint.x - currentPoint.x > 0 && previousPoint.y - currentPoint.y == 0 &&
             currentPoint.x - nextPoint.x == 0 && nextPoint.y - currentPoint.y < 0) {  // 左下角(顺时针)
        [self drawLeftDownCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:YES];
        // NSLog(@"左下角-顺时针 (十字形)");
    }
    
    // 工字形:
    else if (previousPoint.x - currentPoint.x < 0 && previousPoint.y - currentPoint.y == 0 &&
             currentPoint.x - nextPoint.x == 0 && nextPoint.y - currentPoint.y > 0) {  // 右上角(顺时针)
        [self drawRightUpCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:YES];
        // NSLog(@"右上角-顺时针 (工字形)");
    }
    else if (previousPoint.x - currentPoint.x == 0 && previousPoint.y - currentPoint.y < 0 &&
             currentPoint.x - nextPoint.x > 0 && nextPoint.y - currentPoint.y == 0) {  // 右下角(顺时针)
        [self drawRightDownCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:YES];
        // NSLog(@"右下角-顺时针 (工字形)");
    }
    /***
     else if (previousPoint.x - currentPoint.x > 0 && previousPoint.y - currentPoint.y == 0 &&
              currentPoint.x - nextPoint.x == 0 && nextPoint.y - currentPoint.y < 0) {  // 左下角(顺时针)
         [self drawLeftDownCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:YES];
     }
     else if (previousPoint.x - currentPoint.x == 0 && previousPoint.y - currentPoint.y > 0 &&
              currentPoint.x - nextPoint.x < 0 && nextPoint.y - currentPoint.y == 0) {  // 左上角(顺时针)
         [self drawLeftTopCornerWithPath:path currentPoint:currentPoint radius:radius clockwise:YES];
     }
     */
    
    // 绘制直线:
    CGPoint targetPoint = CGPointZero;
    if (currentPoint.x - nextPoint.x == 0) {   // Y轴方向上的直线
        if (currentPoint.y - nextPoint.y < 0) {    // 往下画直线
            targetPoint = CGPointMake(nextPoint.x, nextPoint.y - radius);
        }
        else if (currentPoint.y - nextPoint.y > 0) {    // 往上画直线
            targetPoint = CGPointMake(nextPoint.x, nextPoint.y + radius);
        }
    }
    else if (currentPoint.y - nextPoint.y == 0) {   // X轴方向上的直线
        if (currentPoint.x - nextPoint.x > 0) {   // 往左边画直线
            targetPoint = CGPointMake(nextPoint.x + radius, nextPoint.y);
        }
        else {   // 往右边画直线
            targetPoint = CGPointMake(nextPoint.x - radius, nextPoint.y);
        }
    }
    [path addLineToPoint:targetPoint];
}

// 绘制左上角
+ (void)drawLeftTopCornerWithPath:(UIBezierPath *)path
                     currentPoint:(CGPoint)currentPoint
                           radius:(CGFloat)radius
                        clockwise:(BOOL)clockwise {
    CGFloat startAngle = 0;
    CGFloat endAngle = 0;
    CGFloat offsetX = 0;
    CGFloat offsetY = 0;
    if (clockwise) {
        startAngle = M_PI;
        endAngle = -M_PI/2;
        offsetX = radius;
        offsetY = 0;
    }
    else {
        startAngle = -M_PI/2;
        endAngle = -M_PI;
        offsetX = 0;
        offsetY = radius;
    }
    // Center:圆点的坐标; startAngle:起始弧度; endAngle:结束弧度; clockwise:YES为顺时针，No为逆时针
    [path addArcWithCenter:CGPointMake(currentPoint.x + radius, currentPoint.y + radius) radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
    [path addLineToPoint:CGPointMake(currentPoint.x + offsetX, currentPoint.y + offsetY)];
}

// 绘制左下角
+ (void)drawLeftDownCornerWithPath:(UIBezierPath *)path
                      currentPoint:(CGPoint)currentPoint
                            radius:(CGFloat)radius
                         clockwise:(BOOL)clockwise {
    CGFloat startAngle = 0;
    CGFloat endAngle = 0;
    CGFloat offsetX = 0;
    CGFloat offsetY = 0;
    if (clockwise) {
        startAngle = M_PI/2;
        endAngle = M_PI;
        offsetX = 0;
        offsetY = -radius;
    }
    else {
        startAngle = M_PI;
        endAngle = M_PI/2;
        offsetX = radius;
        offsetY = 0;
    }
    // Center:圆点的坐标; startAngle:起始弧度; endAngle:结束弧度; clockwise:YES为顺时针，No为逆时针
    [path addArcWithCenter:CGPointMake(currentPoint.x + radius, currentPoint.y - radius) radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
    [path addLineToPoint:CGPointMake(currentPoint.x + offsetX, currentPoint.y + offsetY)];
}

// 绘制右下角
+ (void)drawRightDownCornerWithPath:(UIBezierPath *)path
                       currentPoint:(CGPoint)currentPoint
                             radius:(CGFloat)radius
                          clockwise:(BOOL)clockwise {
    CGFloat startAngle = 0;
    CGFloat endAngle = 0;
    CGFloat offsetX = 0;
    CGFloat offsetY = 0;
    if (clockwise) {
        startAngle = 0;
        endAngle = M_PI/2;
        offsetX = -radius;
        offsetY = 0;
    }
    else {
        startAngle = M_PI/2;
        endAngle = 0;
        offsetX = 0;
        offsetY = -radius;
    }
    // Center:圆点的坐标; startAngle:起始弧度; endAngle:结束弧度; clockwise:YES为顺时针，No为逆时针
    [path addArcWithCenter:CGPointMake(currentPoint.x - radius, currentPoint.y - radius) radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
    [path addLineToPoint:CGPointMake(currentPoint.x + offsetX, currentPoint.y + offsetY)];
}

// 绘制右上角
+ (void)drawRightUpCornerWithPath:(UIBezierPath *)path
                       currentPoint:(CGPoint)currentPoint
                             radius:(CGFloat)radius
                          clockwise:(BOOL)clockwise {
    CGFloat startAngle = 0;
    CGFloat endAngle = 0;
    CGFloat offsetX = 0;
    CGFloat offsetY = 0;
    if (clockwise) {
        startAngle = -M_PI/2;
        endAngle = 0;
        offsetX = 0;
        offsetY = radius;
    }
    else {
        startAngle = 0;
        endAngle = 3*M_PI/2;
        offsetX = -radius;
        offsetY = 0;
    }
    // Center:圆点的坐标; startAngle:起始弧度; endAngle:结束弧度; clockwise:YES为顺时针，No为逆时针
    [path addArcWithCenter:CGPointMake(currentPoint.x - radius, currentPoint.y + radius) radius:radius startAngle:startAngle  endAngle:endAngle clockwise:clockwise];
    [path addLineToPoint:CGPointMake(currentPoint.x + offsetX, currentPoint.y + offsetY)];
}

@end
