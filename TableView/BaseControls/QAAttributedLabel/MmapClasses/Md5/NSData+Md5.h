//
//  NSData+Md5.h
//  Avery
//
//  Created by Avery on 15/11/12.
//  Copyright © 2015年 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSData (Md5)

- (NSString *)md5String;

@end
