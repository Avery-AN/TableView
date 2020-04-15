//
//  RichTextDataGetterManager.m
//  TableView
//
//  Created by Avery An on 2019/12/2.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "RichTextDataGetterManager.h"
#import "RichTextCell.h"
#import "TrapezoidalCell.h"

@implementation RichTextDataGetterManager

#pragma mark - Public Methods -
+ (NSMutableArray *)getDatas {
    NSMutableArray *datas = [NSMutableArray array];
    [self getRichTextCellDatas:datas];
    [self getTrapezoidalCellDatas:datas];
    return datas;
}


#pragma mark - Private Methods -
+ (void)getRichTextCellDatas:(NSMutableArray *)datas {
    for (NSUInteger i = 0; i < 281; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];

        CGRect avatarFrame = CGRectMake(Avatar_left_gap, Avatar_top_gap, AvatarSize, AvatarSize);
        [dic setValue:[NSValue valueWithCGRect:avatarFrame] forKey:@"avatar-frame"];

        [dic setValue:[NSString stringWithFormat:@"name_%ld",i] forKey:@"name"];
        NSInteger startX = Avatar_left_gap+AvatarSize+Avatar_title_gap;
        NSInteger Title_width = UIWidth - Title_gap_right - startX;
        CGRect nameFrame = CGRectMake(startX, Avatar_top_gap, Title_width, Title_height);
        [dic setValue:[NSValue valueWithCGRect:nameFrame] forKey:@"name-frame"];
        NSMutableDictionary *nameDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [nameDic setValue:[UIFont systemFontOfSize:14] forKey:@"font"];
        [nameDic setValue:HEXColor(@"333333") forKey:@"textColor"];
        [dic setValue:nameDic forKey:@"name-style"];

        [dic setValue:[NSString stringWithFormat:@"desc_%ld",i] forKey:@"desc"];
        CGRect descFrame = CGRectMake(startX, Avatar_top_gap+AvatarSize-Desc_height, Title_width, Desc_height);
        [dic setValue:[NSValue valueWithCGRect:descFrame] forKey:@"desc-frame"];
        NSMutableDictionary *descDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [descDic setValue:[UIFont systemFontOfSize:14] forKey:@"font"];
        [descDic setValue:HEXColor(@"666666") forKey:@"textColor"];
        [dic setValue:descDic forKey:@"desc-style"];


        NSString *content = @"当我们在Cell上添加系统控件的时候、实质上系统都需要调用底层的接口进行绘制，当添加了大量控件时、对资源的开销也是很大的，所以我们可以直接绘制这样会提高效率。你猜到底是不是这样的呢？https://github.com/Avery-AN";
        NSString *content_2 = @"当我们在Cell上添加系统控件的时候、实质上系统都需要调用底层的接口进行绘制，当添加了大量控件时、对资源的开销也是很大的，所以我们可以直接绘制这样会提高效率。这里替换了原来的网址";
        if (i % 10 == 0) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/15705790-16af8ef57a95f35a.jpg" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】%@", i, content];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 1) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/18224698-380ec562c8230618.png" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】#注意啦#%@", i, content];
            NSMutableString *string = [NSMutableString stringWithString:content];
            [string insertString:@"[nezha][nezha][nezha][nezha][nezha][nezha][nezha][nezha][nezha]" atIndex:80];
            [string appendString:@"[nezha][nezha][nezha][nezha]"];
            [dic setValue:string forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 2) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/15705790-d7125d495dea81ea" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】%@", i, content];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 3) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/21611422-50cd464a589b4cd4" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】%@", i, content];
            content = [NSString stringWithFormat:@"[emoji偷笑][emoji偷笑][emoji偷笑][emoji偷笑][emoji偷笑]END！%@",content];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 4) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/22045084-93437dae965a8af5.jpeg" forKey:@"avatar"];

            content = [NSString stringWithFormat:@"%@ 这里是第\n【%ld】\n条数据！", @" hi~各位!具体代码详见: https://github.com/Avery-AN", i];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 5) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/18224698-044f07dfdea3350c.png" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】%@", i, content];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 6) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/15705790-24e41bb452b274c8" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】%@", i, content_2];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 7) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/169425-211781b78762cb80" forKey:@"avatar"];
            
            content = [NSString stringWithFormat:@"【%ld】%@", i, @"mmap是一种内存映射文件的方法，即将一个文件或者其它对象映射到进程的地址空间，实现文件磁盘地址和进程虚拟地址空间中一段虚拟地址的一一对映关系。实现这样的映射关系后，进程就可以采用指针的方式读写操作这一段内存，而系统会自动回写脏页面到对应的文件磁盘上，即完成了对文件的操作而不必再调用read,write等系统调用函数。相反，内核空间对这段区域的修改也直接反映用户空间，从而可以实现不同进程间的文件共享。"];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 8) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/21611422-97a219f4fca94a19" forKey:@"avatar"];
            
            content = [NSString stringWithFormat:@"【%ld】%@", i, @"mmap适用场景:\n(1) 有一个大file、你需要随时或者多次访问其内容。\n(2) 有一个小的file、你需要一次读入并且会频繁访问。这最适合大小不超过几个虚拟内存页面的文件。\n(3) 缓存一个文件的某一部分，无需映射整个文件，这样可以节省内存空间。"];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 9) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/3490574-bd051666cafeda55.jpg" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】%@", i, content_2];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }

        // 设置contentImageView:
        {
            [dic setValue:[dic valueForKey:@"avatar"] forKey:@"contentImageView"];
            CGFloat width = UIWidth - ContentImageView_left - ContentImageView_right;
            CGFloat height = width / ContentImageView_width_height_rate;
            CGFloat startY = Avatar_top_gap + AvatarSize + Avatar_bottomControl_gap;
            [dic setValue:[NSValue valueWithCGRect:CGRectMake(Avatar_left_gap, startY, width, height)] forKey:@"contentImageView-frame"];
        }
    }
    
    
    if (datas.count > 11) {
        NSMutableDictionary *dic = [datas objectAtIndex:1];
        [dic setValue:@"https://avery.com.gif" forKey:@"contentImageView"];
        NSString *content = [dic valueForKey:@"content"];
        content = [content stringByAppendingString:@"滑动时可以做成按需加载，这个在展示大量图片网络加载的时候效果还是很不错的。@Avery-AN 对象的调整也经常是消耗 CPU 资源的地方。@这里是另外的一个需要注意的地方 可以推测出在performAdditions方法中其实就是在指定线程的runloop中注册一个runloop source0、然后在回调中调用执行代码。需要注意的是在 waitUntilDone为YES时调用有不一样。这时分为两种情况，如果指定的线程为当前线程这时是正常的函数调用与runloop无关； 😁❄️🌧🐟🌹@这是另外的一个人、这一系列的函数都是通过 CALL_OUT_TIMER 调起的，同样的也可以推测delayedPerforming方法内部是通过增加runloop timer实现的。与上面一样在一个没有runloop的线程中使用delayedPerforming方法是不生效的。"];
        [dic setValue:content forKey:@"content"];


        dic = [datas objectAtIndex:4];
        content = [dic valueForKey:@"content"];
        content = [content stringByAppendingString:@"苹果注册了一个 Observer 监听事件，可以看到该回调函数其注册事件是activities = 0xa0（BeforeWaiting | Exit），它的优先级（order=2000000）比事件响应的优先级（order=0）要低（order的值越大优先级越低）。当在操作 UI 时，比如改变了 Frame、更新了 UIView/CALayer 的层次、或者手动调用了 UIView/CALayer 的setNeedsLayout/setNeedsDisplay方法后，这个 UIView/CALayer 就被标记为待处理，并被提交到一个全局的容器去。_ZN2CA11Transaction17observer_callbackEP19__CFRunLoopObservermPv()这个函数里会遍历所有待处理的 UIView/CAlayer 以执行实际的绘制和调整，并更新 UI 界面。"];
        content = [NSString stringWithFormat:@"https://www.sina.com.cn%@",content];
        [dic setValue:content forKey:@"content"];


        dic = [datas objectAtIndex:5];
        content = [NSString stringWithFormat:@"https://www.cctv.com%@",@"这里是中国中央电视台。"];
        [dic setValue:content forKey:@"content"];


        dic = [datas objectAtIndex:7];
        content = [dic valueForKey:@"content"];
        content = [content replace:@"哈哈哈哈哈哈" withString:@"⚡️🌧🐟🌹⛰🐶🐱🐰🐘"];
        [dic setValue:content forKey:@"content"];


        dic = [datas objectAtIndex:11];
        content = [dic valueForKey:@"content"];
        content = [content stringByAppendingString:@"用户触发事件时 IOKit.framework 生成一个 IOHIDEvent 事件并由 SpringBoard 接收，SpringBoard会利用mach port产生的source1来唤醒目标APP的com.apple.uikit.eventfetch-thread子线程的RunLoop。Eventfetch-thread会将main runloop 中__handleEventQueue所对应的source0设置为signalled == Yes状态，同时并唤醒main RunLoop。mainRunLoop继而再调用__handleEventQueue进行事件队列处理。__handleEventQueue会把 IOHIDEvent 处理并包装成 UIEvent 进行处理或分发给UIWindow。其中包括识别 UIGesture/UIButton点击/处理屏幕旋转等。"];
        [dic setValue:content forKey:@"content"];


        dic = [datas objectAtIndex:12];
        content = @"⚡️🌧🐟🌹\n⛰🐶🌧🐟🌹🐱🐰🐶🐘🐶😺\n1234567890\nABCDEFG";
        [dic setValue:content forKey:@"content"];

        
        dic = [datas objectAtIndex:16];
        content = @"hello world";
        [dic setValue:content forKey:@"content"];
        
        
        dic = [datas objectAtIndex:33];
        content = @"hi~\nAvery AN ~~~";
        [dic setValue:content forKey:@"content"];
        
        
        dic = [datas objectAtIndex:40];
        content = @"回家吃饭[nezha]\n回家吃饭[nezha][nezha]\n回家吃饭[nezha][nezha][nezha]\n回家吃饭吧 bla bla bla";
        [dic setValue:content forKey:@"content"];
        

        dic = [datas lastObject];
        content = [dic valueForKey:@"content"];
        content = [content stringByAppendingString:@"https://www.avery.com.cn"];
        [dic setValue:content forKey:@"content"];
    }
}

+ (void)getTrapezoidalCellDatas:(NSMutableArray *)datas {  // 这里只生成TrapezoidalCell的数据
    {
        NSMutableDictionary *trapezoidalDic_index1 = [NSMutableDictionary dictionary];
        [trapezoidalDic_index1 setValue:@"label style" forKey:@"name"];
        NSInteger startX = TrapezoidalCell_Avatar_left_gap+TrapezoidalCell_AvatarSize+TrapezoidalCell_Avatar_title_gap;
        NSInteger Title_width = UIWidth - TrapezoidalCell_Title_gap_right - startX;
        CGRect name_frame = CGRectMake(startX, Avatar_top_gap, Title_width, Title_height);
        [trapezoidalDic_index1 setValue:[NSValue valueWithCGRect:name_frame] forKey:@"name-frame"];

        [trapezoidalDic_index1 setValue:@"测试label样式" forKey:@"desc"];
        CGRect desc_frame = CGRectMake(startX, TrapezoidalCell_Avatar_top_gap+TrapezoidalCell_AvatarSize-Desc_height, Title_width, Desc_height);
        [trapezoidalDic_index1 setValue:[NSValue valueWithCGRect:desc_frame] forKey:@"desc-frame"];

        NSMutableDictionary *style = [NSMutableDictionary dictionary];
        [style setValue:[UIFont systemFontOfSize:14] forKey:@"font"];
        [style setValue:HEXColor(@"333333") forKey:@"textColor"];
        [trapezoidalDic_index1 setValue:style forKey:@"name-style"];

        [trapezoidalDic_index1 setValue:@"https://upload-images.jianshu.io/upload_images/19956441-90202bedb62e0c90.jpg" forKey:@"avatar"];
        CGRect avatar_frame = CGRectMake(TrapezoidalCell_Avatar_left_gap, TrapezoidalCell_Avatar_top_gap, TrapezoidalCell_AvatarSize, TrapezoidalCell_AvatarSize);
        [trapezoidalDic_index1 setValue:[NSValue valueWithCGRect:avatar_frame] forKey:@"avatar-frame"];


        [trapezoidalDic_index1 setValue:[trapezoidalDic_index1 valueForKey:@"avatar"] forKey:@"contentImageView"];
        CGFloat imageWidth = UIWidth - TrapezoidalCell_ContentImageView_left - TrapezoidalCell_ContentImageView_right;
        CGFloat imageHeight = imageWidth / TrapezoidalCell_ContentImageView_width_height_rate;
        CGFloat imageY = TrapezoidalCell_Avatar_top_gap + TrapezoidalCell_AvatarSize + TrapezoidalCell_Avatar_content_gap;
        [trapezoidalDic_index1 setValue:[NSValue valueWithCGRect:CGRectMake(TrapezoidalCell_ContentImageView_left, imageY, imageWidth, imageHeight)] forKey:@"contentImageView-frame"];


        NSMutableArray *texts = [NSMutableArray array];
        [texts addObject:@"其它样式的Label"];
        [texts addObject:@"[nezha] 异形 [nezha]"];
        [texts addObject:@"将点击背景做#圆角#处理"];
        [trapezoidalDic_index1 setValue:texts forKey:@"trapezoidalTexts"];
        [trapezoidalDic_index1 setValue:@(NSTextAlignmentCenter) forKey:@"TextAlignment"];
        [datas insertObject:trapezoidalDic_index1 atIndex:2];


        NSMutableDictionary *trapezoidalDic_index2 = [[NSMutableDictionary alloc] initWithDictionary:trapezoidalDic_index1];
        [trapezoidalDic_index2 setValue:@"https://upload-images.jianshu.io/upload_images/11206370-77f9900187553dca" forKey:@"avatar"];
        [trapezoidalDic_index2 setValue:@"https://upload-images.jianshu.io/upload_images/11206370-77f9900187553dca" forKey:@"contentImageView"];
        [trapezoidalDic_index2 setValue:[NSValue valueWithCGRect:name_frame] forKey:@"name-frame"];
        [trapezoidalDic_index2 setValue:[NSValue valueWithCGRect:desc_frame] forKey:@"desc-frame"];
        NSMutableArray *texts_2 = [NSMutableArray array];
        [texts_2 addObject:@"左对齐Label"];
        [texts_2 addObject:@"#圆角#点击背景😃"];
        [trapezoidalDic_index2 setValue:texts_2 forKey:@"trapezoidalTexts"];
        [trapezoidalDic_index2 setValue:@(NSTextAlignmentLeft) forKey:@"TextAlignment"];
        [datas insertObject:trapezoidalDic_index2 atIndex:3];
        
        

        NSMutableDictionary *trapezoidalDic_index3 = [[NSMutableDictionary alloc] initWithDictionary:trapezoidalDic_index1];
        [trapezoidalDic_index3 setValue:@"https://upload-images.jianshu.io/upload_images/3398976-b8f4ba28567bc9b8" forKey:@"avatar"];
        [trapezoidalDic_index3 setValue:@"https://upload-images.jianshu.io/upload_images/3398976-b8f4ba28567bc9b8" forKey:@"contentImageView"];
        [trapezoidalDic_index3 setValue:[NSValue valueWithCGRect:name_frame] forKey:@"name-frame"];
        [trapezoidalDic_index3 setValue:[NSValue valueWithCGRect:desc_frame] forKey:@"desc-frame"];
        NSMutableArray *texts_3 = [NSMutableArray array];
        [texts_3 addObject:@"右对齐Label"];
        [texts_3 addObject:@"@Tiktok"];
        [texts_3 addObject:@"😃#圆角#点击背景"];
        [trapezoidalDic_index3 setValue:texts_3 forKey:@"trapezoidalTexts"];
        [trapezoidalDic_index3 setValue:@(NSTextAlignmentRight) forKey:@"TextAlignment"];
        [datas insertObject:trapezoidalDic_index3 atIndex:4];
    }
}

@end
