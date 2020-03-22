//
//  AdvancedDataGetterManager.m
//  TableView
//
//  Created by Avery An on 2019/12/2.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "AdvancedDataGetterManager.h"
#import "AdvancedCell.h"
#import "TrapezoidalCell.h"

@implementation AdvancedDataGetterManager

#pragma mark - Public Methods -
+ (NSMutableArray *)getDatas {
    NSMutableArray *datas = [NSMutableArray array];
    [self getRichTextCellDatas:datas];
    [self getTrapezoidalCellDatas:datas];
    return datas;
}


#pragma mark - Private Methods -
+ (void)getRichTextCellDatas:(NSMutableArray *)datas {
    for (int i = 0; i < 281; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];

        CGRect avatarFrame = CGRectMake(Avatar_left_gap, Avatar_top_gap, AvatarSize, AvatarSize);
        [dic setValue:[NSValue valueWithCGRect:avatarFrame] forKey:@"avatar-frame"];

        [dic setValue:[NSString stringWithFormat:@"name_%d",i] forKey:@"name"];
        NSInteger startX = Avatar_left_gap+AvatarSize+Avatar_title_gap;
        NSInteger Title_width = UIWidth - Title_gap_right - startX;
        CGRect nameFrame = CGRectMake(startX, Avatar_top_gap, Title_width, Title_height);
        [dic setValue:[NSValue valueWithCGRect:nameFrame] forKey:@"name-frame"];
        NSMutableDictionary *nameDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [nameDic setValue:[UIFont systemFontOfSize:14] forKey:@"font"];
        [nameDic setValue:HEXColor(@"333333") forKey:@"textColor"];
        [dic setValue:nameDic forKey:@"name-style"];

        [dic setValue:[NSString stringWithFormat:@"desc_%d",i] forKey:@"desc"];
        CGRect descFrame = CGRectMake(startX, Avatar_top_gap+AvatarSize-Desc_height, Title_width, Desc_height);
        [dic setValue:[NSValue valueWithCGRect:descFrame] forKey:@"desc-frame"];
        NSMutableDictionary *descDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [descDic setValue:[UIFont systemFontOfSize:14] forKey:@"font"];
        [descDic setValue:HEXColor(@"666666") forKey:@"textColor"];
        [dic setValue:descDic forKey:@"desc-style"];


        NSString *content = @"我们在Cell上添加系统控件的时候，实质上系统都需要调用底层的接口进行绘制，当我们大量添加控件时，对资源的开销也是很大的，所以我们可以直接绘制，提高效率。你猜到底是不是这样的呢？https://github.com/Avery-AN";
        NSString *content_2 = @"我们在Cell上添加系统控件的时候，实质上系统都需要调用底层的接口进行绘制，当我们大量添加控件时，对资源的开销也会是很大的，所以我们可以索性直接绘制，提高效率。这里替换了原来的网址";
        if (i % 10 == 0) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/15705790-16af8ef57a95f35a.jpg" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】%@", i, content];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 1) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/18224698-380ec562c8230618.png" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】#注意啦#%@", i, content];
            NSMutableString *string = [NSMutableString stringWithString:content];
            [string insertString:@"[nezha][nezha][nezha][nezha][nezha][nezha][nezha][nezha][nezha]" atIndex:80];
            [string appendString:@"[nezha][nezha][nezha][nezha]"];
            [dic setValue:string forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 2) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/15705790-d7125d495dea81ea" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】%@", i, content];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 3) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/21611422-50cd464a589b4cd4" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】%@", i, content];
            content = [NSString stringWithFormat:@"[emoji偷笑][emoji偷笑][emoji偷笑][emoji偷笑][emoji偷笑]END！%@",content];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 4) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/22045084-93437dae965a8af5.jpeg" forKey:@"avatar"];

            content = [NSString stringWithFormat:@"%@ 这里是第\n【%d】\n条数据！", @" hi~各位!具体代码详见: https://github.com/Avery-AN", i];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 5) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/18224698-044f07dfdea3350c.png" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】%@", i, content];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 6) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/15705790-24e41bb452b274c8" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】%@", i, content_2];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 7) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/169425-211781b78762cb80" forKey:@"avatar"];
            
            content = [NSString stringWithFormat:@"【%d】%@", i, @"mmap是一种内存映射文件的方法，即将一个文件或者其它对象映射到进程的地址空间，实现文件磁盘地址和进程虚拟地址空间中一段虚拟地址的一一对映关系。实现这样的映射关系后，进程就可以采用指针的方式读写操作这一段内存，而系统会自动回写脏页面到对应的文件磁盘上，即完成了对文件的操作而不必再调用read,write等系统调用函数。相反，内核空间对这段区域的修改也直接反映用户空间，从而可以实现不同进程间的文件共享。"];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 8) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/21611422-97a219f4fca94a19" forKey:@"avatar"];
            
            content = [NSString stringWithFormat:@"【%d】%@", i, @"mmap适用场景:\n(1) 有一个大file、你需要随时或者多次访问其内容。\n(2) 有一个小的file、你需要一次读入并且会频繁访问。这最适合大小不超过几个虚拟内存页面的文件。\n(3) 缓存一个文件的某一部分，无需映射整个文件，这样可以节省内存空间。"];
            [dic setValue:content forKey:@"content"];

            [datas addObject:dic];
        }
        if (i % 10 == 9) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/3490574-bd051666cafeda55.jpg" forKey:@"avatar"];

            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】%@", i, content_2];
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
        content = [content stringByAppendingString:@"滑动时按需加载，这个在大量图片展示，网络加载的时候很管用！@Avery-AN（SDWebImage已经实现异步加载，配合这条性能杠杠的）。对象的调整也经常是消耗 CPU 资源的地方。@这里是另外的一个需要注意的地方 CALayer:CALayer 内部并没有属性，当调用属性方法时，它内部是通过运行时 resolveInstanceMethod 为对象临时添加一个方法，哈哈哈😁❄️🌧🐟🌹@这是另外的一个人、并把对应属性值保存到内部的一个 Dictionary 里，同时还会通知 delegate、创建动画等等，非常消耗资源。UIView 的关于显示相关的属性（比如 frame/bounds/transform）等实际上都是 CALayer 属性映射来的，所以对 UIView 的这些属性进行调整时，消耗的资源要远大于一般的属性。对此你在应用中，应该尽量减少不必要的属性修改。当视图层次调整时，UIView、CALayer 之间会出现很多方法调用与通知，所以在优化性能时，应该尽量避免调整视图层次、添加和移除视图。"];
        [dic setValue:content forKey:@"content"];


        dic = [datas objectAtIndex:4];
        content = [dic valueForKey:@"content"];
        content = [content stringByAppendingString:@"尽量少用addView给Cell动态添加View，可以初始化时就添加，然后通过hide来控制是否显示。如果一个界面中包含大量文本（比如微博微信朋友圈等），文本的宽高计算会占用很大一部分资源，并且不可避免。如果你对文本显示没有特殊要求，可以参考下 UILabel 内部的实现方式：用 [NSAttributedString boundingRectWithSize:options:context:] 来计算文本宽高，用 -[NSAttributedString drawWithRect:options:context:] 来绘制文本。尽管这两个方法性能不错，但仍旧需要放到后台线程进行以避免阻塞主线程。如果你用 CoreText 绘制文本，那就可以先生成 CoreText 排版对象，然后自己计算了，并且 CoreText 对象还能保留以供稍后绘制使用。屏幕上能看到的所有文本内容控件，包括 UIWebView，在底层都是通过 CoreText 排版、绘制为 Bitmap 显示的。常见的文本控件 （UILabel、UITextView 等），其排版和绘制都是在主线程进行的，当显示大量文本时，CPU 的压力会非常大。对此解决方案只有一个，那就是自定义文本控件，用 TextKit 或最底层的 CoreText 对文本异步绘制。尽管这实现起来非常麻烦，但其带来的优势也非常大，CoreText 对象创建好后，能直接获取文本的宽高等信息，避免了多次计算（调整 UILabel 大小时算一遍、UILabel 绘制时内部再算一遍）；CoreText 对象占用内存较少，可以缓存下来以备稍后多次渲染。"];
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
        content = [content stringByAppendingString:@"加上正好最近也在优化项目中的类似朋友圈功能这块，思考了很多关于UITableView的优化技巧，相信这块是难点也是痛点，所以决定详细的整理下我对优化UITableView的理解。思路是把赋值和计算布局分离。这样让方法只负责赋值，方法只负责计算高度。注意：两个方法尽可能的各司其职，不要重叠代码！两者都需要尽可能的简单易算。Run一下，会发现UITableView滚动流畅了很多。。。基于上面的实现思路，我们可以在获得数据后，直接先根据数据源计算出对应的布局，并缓存到数据源中，这样在方法中就直接返回高度，而不需要每次都计算了。其实上面的改进方法并不是最佳方案，但基本能满足简单的界面！记得开头我的任务吗？像朋友圈那样的图文混排，这种方案还是扛不住的！我们需要进入更深层次的探究: 自定义Cell的绘制。"];
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
        [texts addObject:@"[nezha] Tiktok [nezha]"];
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
        [texts_2 addObject:@"Tiktok"];
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
