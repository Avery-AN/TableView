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
    
    for (NSUInteger i = 0; i < 151; i++) {
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
            NSMutableString *string = [NSMutableString stringWithString:content];
            [string insertString:@"[nezha][nezha][nezha][nezha][nezha][nezha][nezha][nezha][nezha]" atIndex:41];
            [dic setValue:string forKey:@"content"];
            
            [datas addObject:dic];
        }
        if (i % 10 == 1) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/21611422-50cd464a589b4cd4" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】#注意啦#%@", i, content];
            [dic setValue:content forKey:@"content"];
            
            [datas addObject:dic];
        }
        if (i % 10 == 2) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/22045084-93437dae965a8af5.jpeg" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】%@", i, content];
            [dic setValue:content forKey:@"content"];
            
            [datas addObject:dic];
        }
        if (i % 10 == 3) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/17788728-c70af7cb2d08d901.jpg" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】%@", i, content];
            //content = [content stringByAppendingString:@"[emoji偷笑][emoji偷笑][emoji偷笑]END！"];
            content = [NSString stringWithFormat:@"[emoji偷笑][emoji偷笑][emoji偷笑]END！%@",content];
            [dic setValue:content forKey:@"content"];
            
            [datas addObject:dic];
        }
        if (i % 10 == 4) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/15705790-d7125d495dea81ea" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】%@", i, content];
            [dic setValue:content forKey:@"content"];
            
            [datas addObject:dic];
        }
        if (i % 10 == 5) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/169425-211781b78762cb80" forKey:@"avatar"];
            
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
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/19956441-90202bedb62e0c90.jpg" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】%@", i, content];
            [dic setValue:content forKey:@"content"];
            
            [datas addObject:dic];
        }
        if (i % 10 == 8) {
            [dic setValue:@"https://upload-images.jianshu.io/upload_images/21611422-5eb0d664f24af4be" forKey:@"avatar"];
            
            NSString *baseString = [NSString stringWithFormat:@"哈哈哈哈哈哈哈 - %ld;",i];
            for (NSUInteger j = 0; j < i; j++) {
                content = [content stringByAppendingString:baseString];
            }
            content = [NSString stringWithFormat:@"【%ld】%@", i, content];
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
            
            for (NSUInteger j = 0; j < urls.count; j++) {
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
        content = [content stringByAppendingString:@"滑动时可以做成按需加载，这个在展示大量图片网络加载的时候效果还是很不错的。@Avery-AN 对象的调整也经常是消耗 CPU 资源的地方。@这里是另外的一个需要注意的地方 可以推测出在performAdditions方法中其实就是在指定线程的runloop中注册一个runloop source0、然后在回调中调用执行代码。需要注意的是在 waitUntilDone为YES时调用有不一样。这时分为两种情况，如果指定的线程为当前线程这时是正常的函数调用与runloop无关； 😁❄️🌧🐟🌹@这是另外的一个人、这一系列的函数都是通过 CALL_OUT_TIMER 调起的，同样的也可以推测delayedPerforming方法内部是通过增加runloop timer实现的。与上面一样在一个没有runloop的线程中使用delayedPerforming方法是不生效的。"];
        [dic setValue:content forKey:@"content"];
        
        
        dic = [datas objectAtIndex:4];
        content = [dic valueForKey:@"content"];
        content = [content stringByAppendingString:@"苹果注册了一个 Observer 监听事件，可以看到该回调函数其注册事件是activities = 0xa0（BeforeWaiting | Exit），它的优先级（order=2000000）比事件响应的优先级（order=0）要低（order的值越大优先级越低）。当在操作 UI 时，比如改变了 Frame、更新了 UIView/CALayer 的层次、或者手动调用了 UIView/CALayer 的setNeedsLayout/setNeedsDisplay方法后，这个 UIView/CALayer 就被标记为待处理，并被提交到一个全局的容器去。_ZN2CA11Transaction17observer_callbackEP19__CFRunLoopObservermPv()这个函数里会遍历所有待处理的 UIView/CAlayer 以执行实际的绘制和调整，并更新 UI 界面。"];
        content = [NSString stringWithFormat:@"https://www.sina.com%@",content];
        [dic setValue:content forKey:@"content"];
        
        
        dic = [datas objectAtIndex:5];
        content = [NSString stringWithFormat:@"https://www.cctv.com%@",@"这里是中国中央电视台。"];
        [dic setValue:content forKey:@"content"];
        
        
        dic = [datas objectAtIndex:11];
        content = [dic valueForKey:@"content"];
        content = [content stringByAppendingString:@"用户触发事件时 IOKit.framework 生成一个 IOHIDEvent 事件并由 SpringBoard 接收，SpringBoard会利用mach port产生的source1来唤醒目标APP的com.apple.uikit.eventfetch-thread子线程的RunLoop。Eventfetch-thread会将main runloop 中__handleEventQueue所对应的source0设置为signalled == Yes状态，同时并唤醒main RunLoop。mainRunLoop继而再调用__handleEventQueue进行事件队列处理。__handleEventQueue会把 IOHIDEvent 处理并包装成 UIEvent 进行处理或分发给UIWindow。其中包括识别 UIGesture/UIButton点击/处理屏幕旋转等。"];
        [dic setValue:content forKey:@"content"];
        
        
        dic = [datas lastObject];
        content = [dic valueForKey:@"content"];
        content = [content stringByAppendingString:@"https://www.avery.com.cn"];
        [dic setValue:content forKey:@"content"];
    }
    return datas;
}

@end
