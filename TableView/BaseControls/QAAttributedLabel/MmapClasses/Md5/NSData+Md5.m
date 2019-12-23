//
//  NSData+Md5.m
//  Avery
//
//  Created by Avery on 15/11/12.
//  Copyright © 2015年 Avery. All rights reserved.
//

#import "NSData+Md5.h"

@implementation NSData (Md5)

- (NSString *)md5String {
    const char *str = [self bytes];
    
    // 创建字符数组用来接收加密之后的字符
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    // extern unsigned char *CC_MD5(const void *data, CC_LONG len, unsigned char *md)
    // data:需要加密的字符串
    // len:需要加密的字符串的长度、需要转化为CC_LONG类型(32位整形)
    // md:加密完成后的字符串存储的地方
    CC_MD5(str, (CC_LONG)self.length, result);
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02X", result[i]];
    }
    
    return [hash lowercaseString];
    // return [hash uppercaseString];
    // return [hash capitalizedString];
}

@end
