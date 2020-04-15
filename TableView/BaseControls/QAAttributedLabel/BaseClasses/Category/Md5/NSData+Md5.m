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
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)self.length, result);
    
    NSMutableString *hash = [NSMutableString string];
    for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02X", result[i]];
    }
    
    return [hash lowercaseString];
    // return [hash uppercaseString];
    // return [hash capitalizedString];
}

@end
