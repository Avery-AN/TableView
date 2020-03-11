//
//  QAImageFileManager.m
//  TestProject
//
//  Created by Avery An on 2019/11/12.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "QAImageFileManager.h"
#import <sys/stat.h>
#import <malloc/malloc.h>
#import <objc/runtime.h>


typedef void (^mmapImageCompletionBlock)(void);

/**
处理固定大小的image时使用
 */
static CGFloat FixedPixelSizeRate = 1;   // image的宽高比 (值为1时表示宽高相等)

/**
 处理原始大小的image时使用
 "pixelSize|bytesPerPixel|bitsPerComponent|bitmapInfo|bytesPerRow"这些内容的长度不要超过metaInfoSize的值
 */
static int metaInfoSize = 64;

typedef NS_ENUM(NSUInteger, QAImageMmapStyle) {
    QAImageMmapStyle_Cache,
    QAImageMmapStyle_Request
};

static void _QAReleaseImageData(void *info, const void *data, size_t size) {
    if (info) {
        CFRelease(info);
    }
}

SEL mmapSelector;
void (*mmapAction)(id, SEL, NSString *, QAImageMmapStyle, NSInteger, NSString *, mmapImageCompletionBlock);

@interface QAImageFileManager ()
@property (nonatomic, assign) int fileDescriptor;
@property (nonatomic) void *bytes;
@property (nonatomic, assign) NSInteger imageLength;
@property (nonatomic, assign) NSInteger totalLength;
@end


@implementation QAImageFileManager

#pragma mark - Life Cycle -
- (void)dealloc {
    // NSLog(@"%s", __func__);
    [self clearTheBattlefield];
}
- (instancetype)init {
    if (self = [super init]) {
        mmapSelector = NSSelectorFromString(@"mmapImageFile:mmapStyle:imageLength:imageFormartInfo:completion:");
        IMP mmapSelectorImp = [self methodForSelector:mmapSelector];
        mmapAction = (void *)mmapSelectorImp;
    }
    return self;
}


#pragma mark - Public Methods -
- (void)processCache:(NSString * _Nonnull)fileSavedPath
        imageFormart:(QAImageFormat * _Nonnull)imageFormart
               image:(UIImage * _Nonnull)image {
    CGSize pixelSize = imageFormart.pixelSize;
    NSInteger bytesPerPixel = imageFormart.bytesPerPixel;
    NSInteger bytesPerRow = (NSInteger)_QAByteAlignForCoreAnimation(pixelSize.width * bytesPerPixel);
    NSInteger imageLength = bytesPerRow * (NSInteger)pixelSize.height;
    NSInteger bitsPerComponent = imageFormart.bitsPerComponent;
    CGBitmapInfo bitmapInfo = imageFormart.bitmapInfo;
    NSString *imageFormartInfo = [NSString stringWithFormat:@"%@|%@|%@|%@|%@",NSStringFromCGSize(pixelSize),@(bytesPerPixel),@(bitsPerComponent),@(imageFormart.bitmapInfo),@(bytesPerRow)];
    
    [self mmapImageFile:fileSavedPath
              mmapStyle:QAImageMmapStyle_Cache
            imageLength:imageLength
       imageFormartInfo:imageFormartInfo
             completion:^{
        [self cacheImageAfterTruncatingSize:image
                                  pixelSize:pixelSize
                           bitsPerComponent:bitsPerComponent
                                 bitmapInfo:bitmapInfo
                                bytesPerRow:bytesPerRow];
        
        [self flush];
        
        {
            close(self.fileDescriptor);  // 关闭文件描述符
            munmap(self.bytes, self.totalLength);  // 解除映射
            self.bytes = NULL;
        }
    }];
}
- (UIImage *)processRequest:(NSString * _Nonnull)fileSavedPath
               imageFormart:(QAImageFormat * _Nullable)imageFormart {
    @autoreleasepool {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
        __block CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        __block CGSize pixelSize = CGSizeZero;
        __block NSInteger bitsPerComponent = 0;
        __block NSInteger bitsPerPixel = 0;
        __block NSInteger bytesPerRow = 0;
        NSInteger imageLength = 0;
        
        if (imageFormart) {
            pixelSize = imageFormart.pixelSize;
            bitsPerComponent = imageFormart.bitsPerComponent;
            bitsPerPixel = imageFormart.bytesPerPixel * BYTE_SIZE;
            bitmapInfo = imageFormart.bitmapInfo;
            bytesPerRow = (NSInteger)_QAByteAlignForCoreAnimation(pixelSize.width * imageFormart.bytesPerPixel);
            imageLength = pixelSize.width * bytesPerRow;
        }
        
        __block UIImage *cachedImage = nil;
        __weak typeof(self) weakSelf = self;
        
        mmapAction(self, mmapSelector, fileSavedPath, QAImageMmapStyle_Request, imageLength, nil, ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (CGSizeEqualToSize(pixelSize, CGSizeZero)) {
                // "pixelSize|bytesPerPixel|bitsPerComponent|bitmapInfo|bytesPerRow"
                char * imageFormatInfo_char = (char*)malloc(sizeof(char) * metaInfoSize);
                memcpy(imageFormatInfo_char, (const void *)(strongSelf.bytes + strongSelf.imageLength), metaInfoSize);
                NSString *imageFormatInfo = [[NSString alloc] initWithCString:imageFormatInfo_char
                                                                     encoding:NSASCIIStringEncoding];

                NSArray *array = [imageFormatInfo componentsSeparatedByString:@"|"];
                pixelSize = CGSizeFromString([array firstObject]);
                NSInteger bytesPerPixel = [[array objectAtIndex:1] integerValue];
                bitsPerPixel = bytesPerPixel * BYTE_SIZE;
                bitsPerComponent = [[array objectAtIndex:2] integerValue];
                bitmapInfo = [[array objectAtIndex:3] intValue];
                bytesPerRow = [[array objectAtIndex:4] integerValue];
            }
            
            
            /**
             CGImageCreateWithJPEGDataProvider方法没办法处理字节对齐:
             CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, strongSelf.bytes, strongSelf.imageLength, _QAReleaseImageData);
             CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
             CGImageRef imageRef = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, renderingIntent);
            */
            
            

            // CGDataProviderCreateWithData(void * _Nullable info, const void * _Nullable data, size_t size, CGDataProviderReleaseDataCallback  _Nullable releaseData)
            CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, strongSelf.bytes, strongSelf.imageLength, _QAReleaseImageData);

            // CGImageRef imageRef = CGImageCreate(size_t width, size_t height, size_t bitsPerComponent, size_t bitsPerPixel, size_t bytesPerRow, CGColorSpaceRef  _Nullable space, CGBitmapInfo bitmapInfo, CGDataProviderRef  _Nullable provider, const CGFloat * _Nullable decode, bool shouldInterpolate, CGColorRenderingIntent intent);
            CGImageRef imageRef = CGImageCreate(pixelSize.width, pixelSize.height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, bitmapInfo, dataProvider, NULL, YES, renderingIntent);

            if (imageRef != NULL) {
                UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                cachedImage = image;
                CGImageRelease(imageRef);
            }
            else {
                NSString *errorMessage = @"Error: could not create a new CGImageRef";
                NSLog(@"error: %@",errorMessage);
            }

            CGColorSpaceRelease(colorSpace);
            CGDataProviderRelease(dataProvider);
        });
        
        return cachedImage;
    }
}

- (void)processFixedSizeCache:(NSString * _Nonnull)fileSavedPath
                 imageFormart:(QAImageFormat * _Nonnull)imageFormart
                        image:(UIImage * _Nonnull)image {
    UIImage *fixedSizeImage = _QAFixedSizeImageFromImage(image, FixedPixelSizeRate);
    imageFormart.imageSize = fixedSizeImage.size;
    float screenCale = [UIScreen mainScreen].scale;
    CGSize pixelSize = CGSizeMake(fixedSizeImage.size.width * screenCale, fixedSizeImage.size.height * screenCale);
    imageFormart.pixelSize = pixelSize;
    NSInteger bytesPerPixel = imageFormart.bytesPerPixel;
    NSInteger bytesPerRow = (NSInteger)_QAByteAlignForCoreAnimation(pixelSize.width * bytesPerPixel);
    NSInteger imageLength = bytesPerRow * (NSInteger)pixelSize.height;
    NSInteger bitsPerComponent = imageFormart.bitsPerComponent;
    CGBitmapInfo bitmapInfo = imageFormart.bitmapInfo;
    NSString *imageFormartInfo = [NSString stringWithFormat:@"%@|%@|%@|%@|%@",NSStringFromCGSize(pixelSize),@(bytesPerPixel),@(bitsPerComponent),@(imageFormart.bitmapInfo),@(bytesPerRow)];
    
    [self mmapImageFile:fileSavedPath
              mmapStyle:QAImageMmapStyle_Cache
            imageLength:imageLength
       imageFormartInfo:imageFormartInfo
             completion:^(void) {
        [self cacheImageAfterTruncatingSize:fixedSizeImage
                                  pixelSize:pixelSize
                           bitsPerComponent:bitsPerComponent
                                 bitmapInfo:bitmapInfo
                                bytesPerRow:bytesPerRow];
        [self flush];
        [self clearTheBattlefield];
    }];
}
- (void)clearTheBattlefield {
    if (self.fileDescriptor >= 0) {
        close(self.fileDescriptor);  // 关闭文件描述符
        // int closeResult = close(self.fileDescriptor);  // 关闭文件描述符
        // NSLog(@"关闭文件描述符: %d",closeResult);
    }
    if (self.bytes) {
        munmap(self.bytes, self.totalLength);  // 解除映射
        // int closeResult = munmap(self.bytes, self.totalLength);  // 解除映射
        self.bytes = NULL;
        // NSLog(@"解除映射: %d",closeResult);
    }
}


#pragma mark - Private Methods -
- (void)mmapImageFile:(NSString * _Nonnull)fileSavedPath
            mmapStyle:(QAImageMmapStyle)mmapStyle
          imageLength:(NSInteger)imageLength
     imageFormartInfo:(NSString * _Nullable)imageFormartInfo
           completion:(void(^)(void))completion {
    @autoreleasepool {
        int fileDescriptor = open([fileSavedPath fileSystemRepresentation], O_RDWR | O_CREAT, 0666);
        self.fileDescriptor = fileDescriptor;
        if (fileDescriptor >= 0) {
            /*
             int fstat(int fildes, struct stat *buf);
             fstat()用来将参数fildes所指的文件状态，复制到参数buf中
             */
            struct stat statInfo;
            if (fstat(fileDescriptor, &statInfo) != 0 ) {
                NSLog(@"发生了error-1");
            }
            else {
                off_t fileLength = lseek(fileDescriptor, 0, SEEK_END);  // 获取文件大小 (bytes)
                /*
                 NSInteger length = statInfo.st_size;  // 获取文件大小 (bytes)
                 */
                
                switch (mmapStyle) {
                    case QAImageMmapStyle_Cache: {
                        self.imageLength = imageLength;
                        self.totalLength = self.imageLength + metaInfoSize;
                    }
                        break;
                        
                    case QAImageMmapStyle_Request: {
                        self.totalLength = fileLength;
                        self.imageLength = self.totalLength - metaInfoSize;
                    }
                        break;
                        
                    default:
                        break;
                }
                
                void *start = NULL; // 由系统选定地址
                off_t offset = 0;   // offset为文件映射的偏移量、设为0代表从文件最前方开始对应,offset必须是分页大小的整数倍。
                void *bytes = mmap(start, self.totalLength, (PROT_READ|PROT_WRITE), (MAP_FILE|MAP_SHARED), fileDescriptor, offset);
                self.bytes = bytes;
                if (bytes == MAP_FAILED) {
                    NSLog(@"Failed to mmap. errno=%d", errno);
                    bytes = NULL;
                }
                else {
                    if (fileLength == 0) {
                        int result = ftruncate(fileDescriptor, self.totalLength);
                        if (result != 0) {
                            NSLog(@"Failed to ftruncate. errno=%d", errno);
                        }
                        else {
                            if (imageFormartInfo) {
                                const char *imageFormartInfoString = [imageFormartInfo cStringUsingEncoding:NSASCIIStringEncoding];
                                memcpy(bytes+self.imageLength, imageFormartInfoString, metaInfoSize);
                            }
                            
                            if (completion) {
                                completion();
                            }
                        }
                    }
                    else {
                        if (completion) {
                            completion();
                        }
                    }
                }
            }
        }
    }
}
- (void)cacheImageAfterTruncatingSize:(UIImage * _Nonnull)image
                            pixelSize:(CGSize)pixelSize
                     bitsPerComponent:(NSInteger)bitsPerComponent
                           bitmapInfo:(CGBitmapInfo)bitmapInfo
                          bytesPerRow:(NSInteger)bytesPerRow {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat screenScale = [UIScreen mainScreen].scale;
    
    CGContextRef contextRef = CGBitmapContextCreate(self.bytes, pixelSize.width, pixelSize.height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    if (!contextRef) {
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(contextRef);
        return;
    }
    CGContextTranslateCTM(contextRef, 0, pixelSize.height);
    CGContextScaleCTM(contextRef, screenScale, -screenScale);
    
    CGRect pixelRect = CGRectMake(0, 0, pixelSize.width, pixelSize.height);
    CGPathRef path = _QACreateDrawRectPath(pixelRect, 0);
    CGContextAddPath(contextRef, path);
    CFRelease(path);
    CGContextEOClip(contextRef);
    
    CGRect drawRect = CGRectMake(0, 0, pixelSize.width/screenScale, pixelSize.height/screenScale);
    UIGraphicsPushContext(contextRef);
    [image drawInRect:drawRect];
    UIGraphicsPopContext();
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
}
- (void)flush {
    int result = msync(self.bytes, self.totalLength, MS_SYNC);
    if (result) {
        // NSLog(@"flush时发生了异常");
    }
    else {
        // NSLog(@"flush数据成功");
    }
}


#pragma mark - C Private Methods -
size_t _QAByteAlign(size_t width, size_t alignment) {
    return ((width + (alignment - 1)) / alignment) * alignment;
}
size_t _QAByteAlignForCoreAnimation(size_t bytesPerRow) {
    return _QAByteAlign(bytesPerRow, 64);
}
static CGMutablePathRef _QACreateDrawRectPath(CGRect rect, CGFloat cornerRadius) {
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat midX = CGRectGetMidX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat midY = CGRectGetMidY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    CGPathMoveToPoint(path, NULL, minX, midY);
    CGPathAddArcToPoint(path, NULL, minX, maxY, midX, maxY, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxX, maxY, maxX, midY, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxX, minY, midX, minY, cornerRadius);
    CGPathAddArcToPoint(path, NULL, minX, minY, minX, midY, cornerRadius);
    
    return path;
}

/**
将图片处理成指定的宽高比
*/
static UIImage * _QAFixedSizeImageFromImage(UIImage *image, CGFloat widthHeightRate) {
    UIImage *fixedSizeImage = nil;
    CGSize imageSize = [image size];

    CGFloat rate_image = imageSize.width / imageSize.height;
    if (fabs(rate_image - widthHeightRate) < 0.001) {
        fixedSizeImage = image;
    }
    else {
        CGRect cropRect;
        if (rate_image - widthHeightRate >= 0) {
            CGFloat height = imageSize.height;
            CGFloat width = height * widthHeightRate;
            cropRect = CGRectMake(rintf((imageSize.width - width)/2.), 0, width, height);
        }
        else {
            CGFloat width = imageSize.width;
            CGFloat height = width / widthHeightRate;
            cropRect = CGRectMake(0, rintf((imageSize.height - height)/2.), width, height);
        }
        CGImageRef croppedImageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
        fixedSizeImage = [UIImage imageWithCGImage:croppedImageRef];
        CGImageRelease(croppedImageRef);
    }
    
    return fixedSizeImage;
}

@end
