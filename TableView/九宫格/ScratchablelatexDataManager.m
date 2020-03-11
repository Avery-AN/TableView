//
//  ScratchablelatexDataManager.m
//  TableView
//
//  Created by Avery An on 2019/12/2.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "ScratchablelatexDataManager.h"
#import "ScratchablelatexCell.h"

@implementation ScratchablelatexDataManager

+ (NSMutableArray *)getDatas {
    NSMutableArray *datas = [NSMutableArray array];
    
    for (int i = 0; i < 151; i++) {
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
        
        
        NSString *content = @"我们在Cell上添加系统控件的时候，实质上系统都需要调用底层的接口进行绘制，当我们大量添加控件时，对资源的开销也会是很大的，所以我们可以索性直接绘制，提高效率。https://github.com/Avery-AN";
        NSString *content_2 = @"我们在Cell上添加系统控件的时候，实质上系统都需要调用底层的接口进行绘制，当我们大量添加控件时，对资源的开销也会是很大的，所以我们可以索性直接绘制，提高效率。这里替换了原来的网址";
        if (i % 10 == 0) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/15705790-16af8ef57a95f35a.jpg" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】%@", i, content];
            NSMutableString *string = [NSMutableString stringWithString:content];
            [string insertString:@"[nezha][nezha][nezha][nezha][nezha][nezha][nezha][nezha][nezha]" atIndex:41];
            [dic setValue:string forKey:@"content"];
            
            [datas addObject:dic];
        }
        if (i % 10 == 1) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/21611422-50cd464a589b4cd4" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】#注意啦#%@", i, content];
            [dic setValue:content forKey:@"content"];
            
            [datas addObject:dic];
        }
        if (i % 10 == 2) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/22045084-93437dae965a8af5.jpeg" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】%@", i, content];
            [dic setValue:content forKey:@"content"];
            
            [datas addObject:dic];
        }
        if (i % 10 == 3) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/17788728-c70af7cb2d08d901.jpg" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】%@", i, content];
            //content = [content stringByAppendingString:@"[emoji偷笑][emoji偷笑][emoji偷笑]END！"];
            content = [NSString stringWithFormat:@"[emoji偷笑][emoji偷笑][emoji偷笑]END！%@",content];
            [dic setValue:content forKey:@"content"];
            
            [datas addObject:dic];
        }
        if (i % 10 == 4) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/15705790-d7125d495dea81ea" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】%@", i, content];
            [dic setValue:content forKey:@"content"];
            
            [datas addObject:dic];
        }
        if (i % 10 == 5) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/169425-211781b78762cb80" forKey:@"avatar"];
            
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
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/19956441-90202bedb62e0c90.jpg" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】%@", i, content];
            [dic setValue:content forKey:@"content"];
            
            [datas addObject:dic];
        }
        if (i % 10 == 8) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/21611422-5eb0d664f24af4be" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %d;",i];
            for (int j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%d】%@", i, content];
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
        
        // 设置contentImageViews:
        {
            NSMutableArray *contentImageViews = [NSMutableArray array];
            [dic setValue:contentImageViews forKey:@"contentImageViews"];
            
            NSMutableArray *urls = [NSMutableArray array];
            if (i == 1) {
               [urls addObject:[dic valueForKey:@"avatar"]];
            }
            else if (i % 10 == 3) {
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
            }
            else if (i % 10 == 5) {
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
            }
            else if (i % 10 == 7) {
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
            }
            else if (i % 10 == 8) {
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
            }
            else if (i % 10 == 9) {
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
            }
            else {
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
                [urls addObject:[dic valueForKey:@"avatar"]];
            }
            
            for (int j = 0; j < urls.count; j++) {
                NSMutableDictionary *contentImageViewDic = [NSMutableDictionary dictionary];
                [contentImageViews addObject:contentImageViewDic];
                CGFloat baseX = ContentImageView_left;
                CGFloat baseY = Avatar_top_gap + AvatarSize + Avatar_bottomControl_gap;
                CGFloat startX = 0;
                CGFloat startY = 0;
                CGFloat itemWidth = 0;
                CGFloat itemHeight = 0;
                if (urls.count == 1) {
                    itemWidth = UIWidth - ContentImageView_left - ContentImageView_right;
                    itemHeight = itemWidth / ContentImageView_width_height_rate;
                }
                else {
                    itemWidth = (UIWidth - ContentImageView_left - ContentImageView_right - ContentImageView_gap*(MaxItems-1)) / MaxItems;
                    itemHeight = itemWidth;
                }
                
                if (j % 3 == 0) {
                    startX = baseX;
                }
                else if (j % 3 == 1) {
                    startX = baseX + itemWidth + ContentImageView_gap;
                }
                else if (j % 3 == 2) {
                    startX = baseX + (itemWidth + ContentImageView_gap) * 2;
                }
                if (j / 3 == 0) {
                    startY = baseY;
                }
                else if (j / 3 == 1) {
                    startY = baseY + itemHeight + ContentImageView_gap;
                }
                else if (j / 3 == 2) {
                    startY = baseY + (itemHeight + ContentImageView_gap) * 2;
                }
                [contentImageViewDic setValue:[NSValue valueWithCGRect:CGRectMake(startX, startY, itemWidth, itemHeight)] forKey:@"frame"];
                if (i == 0) {
                    if (j == 0) {
                        [contentImageViewDic setValue:@"https://upload-images.jianshu.io/upload_images/15705790-16af8ef57a95f35a.jpg" forKey:@"url"];
                    }
                    else if (j == 1) {
                        [contentImageViewDic setValue:@"https://upload-images.jianshu.io/upload_images/19956441-90202bedb62e0c90.jpg" forKey:@"url"];
                    }
                    else if (j == 2) {
                        [contentImageViewDic setValue:@"https://upload-images.jianshu.io/upload_images/22045084-93437dae965a8af5.jpeg" forKey:@"url"];
                    }
                    else if (j == 3) {
                        [contentImageViewDic setValue:@"https://upload-images.jianshu.io/upload_images/21611422-97a219f4fca94a19" forKey:@"url"];
                    }
                    else if (j == 4) {
                        [contentImageViewDic setValue:@"https://upload-images.jianshu.io/upload_images/15705790-d7125d495dea81ea" forKey:@"url"];
                    }
                    else if (j == 5) {
                        [contentImageViewDic setValue:@"https://upload-images.jianshu.io/upload_images/21611422-50cd464a589b4cd4" forKey:@"url"];
                    }
                    else if (j == 6) {
                        [contentImageViewDic setValue:@"https://upload-images.jianshu.io/upload_images/15705790-24e41bb452b274c8" forKey:@"url"];
                    }
                    else if (j == 7) {
                        [contentImageViewDic setValue:@"https://upload-images.jianshu.io/upload_images/169425-211781b78762cb80" forKey:@"url"];
                    }
                    else if (j == 8) {
                        [contentImageViewDic setValue:@"https://upload-images.jianshu.io/upload_images/2748485-8caa321e4f1aadf5" forKey:@"url"];
                    }
                }
                else {
                    [contentImageViewDic setValue:[dic valueForKey:@"avatar"] forKey:@"url"];
                }
            }
        }
    }
    
    
    if (datas.count > 11) {
        NSMutableDictionary *dic = [datas objectAtIndex:1];
        NSString *content = [dic valueForKey:@"content"];
        content = [content stringByAppendingString:@"滑动时按需加载，这个在大量图片展示，网络加载的时候很管用！@Avery-AN（SDWebImage已经实现异步加载，配合这条性能杠杠的）。对象的调整也经常是消耗 CPU 资源的地方。这里特别说一下 CALayer：CALayer 内部并没有属性，当调用属性方法时，它内部是通过运行时 resolveInstanceMethod 为对象临时添加一个方法，并把对应属性值保存到内部的一个 Dictionary 里，同时还会通知 delegate、创建动画等等，非常消耗资源。UIView 的关于显示相关的属性（比如 frame/bounds/transform）等实际上都是 CALayer 属性映射来的，所以对 UIView 的这些属性进行调整时，消耗的资源要远大于一般的属性。@这是另外的一个人 对此你在应用中，应该尽量减少不必要的属性修改。当视图层次调整时，UIView、CALayer 之间会出现很多方法调用与通知，所以在优化性能时，应该尽量避免调整视图层次、添加和移除视图。"];
        [dic setValue:content forKey:@"content"];
        
        
        dic = [datas objectAtIndex:4];
        content = [dic valueForKey:@"content"];
        content = [content stringByAppendingString:@"尽量少用addView给Cell动态添加View，可以初始化时就添加，然后通过hide来控制是否显示。如果一个界面中包含大量文本（比如微博微信朋友圈等），文本的宽高计算会占用很大一部分资源，并且不可避免。如果你对文本显示没有特殊要求，可以参考下 UILabel 内部的实现方式：用 [NSAttributedString boundingRectWithSize:options:context:] 来计算文本宽高，用 -[NSAttributedString drawWithRect:options:context:] 来绘制文本。尽管这两个方法性能不错，但仍旧需要放到后台线程进行以避免阻塞主线程。如果你用 CoreText 绘制文本，那就可以先生成 CoreText 排版对象，然后自己计算了，并且 CoreText 对象还能保留以供稍后绘制使用。屏幕上能看到的所有文本内容控件，包括 UIWebView，在底层都是通过 CoreText 排版、绘制为 Bitmap 显示的。常见的文本控件 （UILabel、UITextView 等），其排版和绘制都是在主线程进行的，当显示大量文本时，CPU 的压力会非常大。对此解决方案只有一个，那就是自定义文本控件，用 TextKit 或最底层的 CoreText 对文本异步绘制。尽管这实现起来非常麻烦，但其带来的优势也非常大，CoreText 对象创建好后，能直接获取文本的宽高等信息，避免了多次计算（调整 UILabel 大小时算一遍、UILabel 绘制时内部再算一遍）；CoreText 对象占用内存较少，可以缓存下来以备稍后多次渲染。"];
        content = [NSString stringWithFormat:@"https://www.sina.com%@",content];
        [dic setValue:content forKey:@"content"];
        
        
        dic = [datas objectAtIndex:5];
        content = [dic valueForKey:@"content"];
        content = [NSString stringWithFormat:@"https://www.cctv.com%@",@"这里是中国中央电视台。"];
        [dic setValue:content forKey:@"content"];
        
        
        dic = [datas objectAtIndex:11];
        content = [dic valueForKey:@"content"];
        content = [content stringByAppendingString:@"加上正好最近也在优化项目中的类似朋友圈功能这块，思考了很多关于UITableView的优化技巧，相信这块是难点也是痛点，所以决定详细的整理下我对优化UITableView的理解。思路是把赋值和计算布局分离。这样让方法只负责赋值，方法只负责计算高度。注意：两个方法尽可能的各司其职，不要重叠代码！两者都需要尽可能的简单易算。Run一下，会发现UITableView滚动流畅了很多。。。基于上面的实现思路，我们可以在获得数据后，直接先根据数据源计算出对应的布局，并缓存到数据源中，这样在方法中就直接返回高度，而不需要每次都计算了。其实上面的改进方法并不是最佳方案，但基本能满足简单的界面！记得开头我的任务吗？像朋友圈那样的图文混排，这种方案还是扛不住的！我们需要进入更深层次的探究: 自定义Cell的绘制。"];
        [dic setValue:content forKey:@"content"];
        
        
        dic = [datas lastObject];
        content = [dic valueForKey:@"content"];
        content = [content stringByAppendingString:@"https://www.avery.com.cn"];
        [dic setValue:content forKey:@"content"];
    }
    return datas;
}

@end
