//
//  NSString+Md5.m
//  Avery
//
//  Created by Avery on 15/11/13.
//  Copyright © 2015年 Avery. All rights reserved.
//

#import "NSString+Md5.h"
#import "NSData+Md5.h"

@implementation NSString (Md5)

- (NSString *)md5Hash {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data md5String];
}

@end
