//
//  ImageOperation.m
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "ImageOperation.h"
#import "LBCacheManager.h"
#import <ImageIO/ImageIO.h>

@interface ImageOperation () <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property (strong, nonatomic) NSURLSession *sesstion;
@property (strong, nonatomic) NSString *urlString;
@property (copy, nonatomic) LBCacheOperationBlock imageBlock;
@property (copy, nonatomic) ProgressBlock progressBlock;
@property (strong, nonatomic) NSURL *location;
@property (nonatomic) LBCacheImageOptions options;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@end

@implementation ImageOperation
@synthesize executing = _executing;
@synthesize finished = _finished;

- (void) dealloc{
    [_sesstion invalidateAndCancel];
}

- (id) initWithURLString:(NSString *)urlString options:(LBCacheImageOptions)options progressBlock:(ProgressBlock)progressBlock completionBlock:(LBCacheOperationBlock)completionBlock
{
    self = [super init];
    if(self)
    {
        _executing = NO;
        _finished = NO;
        _options = options;
        _sesstion = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration ephemeralSessionConfiguration] delegate: self delegateQueue: nil];
        _urlString = urlString;
        _progressBlock = [progressBlock copy];
        _imageBlock = [completionBlock copy];
    }
    return self;
}


- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void) done
{
    self.finished = YES;
    self.executing = NO;
}


- (void) start
{
    if(self.isCancelled)
    {
        [self done];
        return;
    }
    
    if(!self.urlString)
    {
        NSError *error = [NSError errorWithDomain: @"LBErrorDomain" code: 1 userInfo: @{NSLocalizedDescriptionKey: @"Invalid URL."}];
        if(self.imageBlock)
            self.imageBlock(nil,error);
        [self done];
        return;
    }

    self.executing = YES;

    if(self.options == LBCacheImageOptionsDefault)
    {
        [self getImageFromCacheOrServer];
    }
    else if(self.options == LBCacheImageOptionsReloadFromWeb)
    {
        [self getImageFromTheServer];
    }
    else
    {
        [self loadOnlyFromCache];
    }
    
}

- (void) getImageFromCacheOrServer
{
    LBCacheManager *cacheManager = [LBCacheManager sharedInstance];
    NSString *imagePath = [cacheManager imagePathLocationForURLString: self.urlString];
    UIImage *image = nil;
    
    if(imagePath)
    {
        // if image exists at local path, create and return it
        UIImage *image = [UIImage imageWithContentsOfFile: imagePath];
        if(image) {
            if(self.imageBlock)
            {
                self.imageBlock(image,nil);   // LOADED FROM DISK
            }
            [self done];
        }
    }
    
    if (!image)
    {
        [self getImageFromTheServer];
    }
}


-(void) getImageFromTheServer {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: self.urlString] cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: kTimeoutInteral];
    [request setAllHTTPHeaderFields: @{@"Accept":@"image/*"}];
    [request setHTTPMethod: @"GET"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    
    NSURLSessionDownloadTask *task = [self.sesstion downloadTaskWithRequest: request];
    [task resume];
}

-(void) loadOnlyFromCache
{
    LBCacheManager *cacheManager = [LBCacheManager sharedInstance];
    NSString *imagePath = [cacheManager imagePathLocationForURLString: self.urlString];
    if(imagePath)
    {
        // if image exists at local path, create and return it
        UIImage *image = [UIImage imageWithContentsOfFile: imagePath];
        if(image)
        {
            if(self.imageBlock)
            {
                self.imageBlock(image,nil);   // LOADED FROM DISK
            }
        }
        else
        {
            // CAN'T CREATE IMAGE
            if(self.imageBlock)
            {
                NSError *error = [NSError errorWithDomain: kLBCacheErrorDomain code: LBCacheErrorCantCreateImage userInfo: @{NSLocalizedDescriptionKey: kCantCreateImageDescription}];
                self.imageBlock(nil,error);
            }
        }
    }
    else
    {   // file doesn't exists at local path
        if(self.imageBlock)
        {
            NSError *error = [NSError errorWithDomain: kLBCacheErrorDomain code: LBCacheErrorImageNotFound userInfo: @{NSLocalizedDescriptionKey: kImageNotFoundDescription}];
            self.imageBlock(nil,error);
        }
    }

    [self done];
}



#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if(totalBytesWritten == totalBytesExpectedToWrite)
    {
        if(self.progressBlock)
            self.progressBlock(100);
    }
    else
    {
        if(totalBytesWritten > 0)
        {
            NSUInteger percent = (NSUInteger)totalBytesWritten * 100.0 / (NSUInteger)totalBytesExpectedToWrite;
            if(self.progressBlock)
                self.progressBlock(percent);
        }
        else
        {
            if(self.progressBlock)
                self.progressBlock(0);
        }
    }
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString *str = downloadTask.response.URL.absoluteString;
    if(str) {
        NSString *hash = [str lbHashWithType: kDefaultHashType];
        if(hash) {
            NSURL *tempURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
            if(tempURL) {
                NSURL *imageURL = [tempURL URLByAppendingPathComponent: hash];
                
                NSError *error = nil;
                NSFileManager *fileManager = [[NSFileManager alloc] init];
                if([fileManager fileExistsAtPath: [imageURL path]])
                {
                    BOOL success = [fileManager replaceItemAtURL: imageURL withItemAtURL: location backupItemName:nil options:0 resultingItemURL: &imageURL error: &error];
                    if(success) {
                        self.location = imageURL;
                    }
                }
                else
                {
                    BOOL success = [fileManager copyItemAtURL: location toURL: imageURL error: &error];
                    if(success) {
                        self.location = imageURL;
                    }
                }
            }
        }
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(error)
    {
        if(self.imageBlock)
            self.imageBlock(nil,error);
    }
    else
    {
        if(self.imageBlock)
        {
            NSError *error = nil;
            NSURL *imageURL = [self saveImageAndReturnURLLocationWithTempLocation: self.location forURLString: self.urlString error: &error];

            if(imageURL)
            {
                UIImage *image = [self createImageWithContentsOfURL: imageURL];
                if(image) {
                    self.imageBlock(image, nil);
                }
                else
                {
                    NSError *error = [NSError errorWithDomain: kLBCacheErrorDomain code: LBCacheErrorCantCreateImage userInfo: @{NSLocalizedDescriptionKey: kCantCreateImageDescription}];

                    // remove the item at imageURL if the image can't be created.
                    NSFileManager *fm = [[NSFileManager alloc] init];
                    [fm removeItemAtURL: imageURL error: nil];
                    
                    self.imageBlock(nil,error);
                }
            }
            else
                self.imageBlock(nil,error);
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    
    [self done];
}



- (UIImage *) createImageWithContentsOfURL: (NSURL *) imageURL
{
    if(!imageURL)
        return nil;

    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)imageURL, NULL);
    if(!imageSource)
        return nil;
    
    NSInteger orientationValue = UIImageOrientationUp;    
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    if(properties) {
        CFTypeRef val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
        if (val) {
            CFNumberGetValue(val, kCFNumberNSIntegerType, &orientationValue);
        }
        CFRelease(properties);
    }
    
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    if(!imageRef)
    {
        if(imageSource)
            CFRelease(imageSource);
        return nil;
    }
    else
    {
        UIImage *img = [[UIImage alloc] initWithCGImage: imageRef scale:[UIScreen mainScreen].scale orientation:orientationValue];

        CFRelease(imageRef);
        if(imageSource)
            CFRelease(imageSource);
        
        if(img)
            return img;
        else
            return nil;
    }
}







#pragma mark - save/cache image method


- (NSURL *) saveImageAndReturnURLLocationWithTempLocation: (NSURL *) tempLocation forURLString: (NSString *) urlString error: (NSError * __autoreleasing*) error
{
    NSURL *imagesURLDirectory = [[LBCacheManager sharedInstance] getLBCacheDirectory];
    
    if(imagesURLDirectory)
    {
        NSString *imageName = [urlString lbHashWithType: kDefaultHashType];
        if(imageName)
        {
            if(tempLocation)
            {
                NSURL *imageURL = [imagesURLDirectory URLByAppendingPathComponent: imageName];
                
                NSFileManager *fileManager = [[NSFileManager alloc] init];
                if([fileManager fileExistsAtPath: [imageURL path]])
                {
                    BOOL success = [fileManager replaceItemAtURL: imageURL withItemAtURL: tempLocation backupItemName:nil options:0 resultingItemURL: &imageURL error: error];
                    if(!success)
                        return nil;
                    else
                        return imageURL;
                }
                else
                {
                    BOOL success = [fileManager copyItemAtURL: tempLocation toURL: imageURL error: error];
                    if(!success)
                        return nil;
                    else
                        return imageURL;
                }
            }
            else
            {
                if(error != NULL)
                    *error = [[NSError alloc] initWithDomain: @"LBErrorDomain" code: LBCacheErrorNilDownloadLocation userInfo: @{NSLocalizedDescriptionKey: kNilDownloadURLLocation}];
                return nil;
            }
        }
        {
            if(error != NULL)
                *error = [NSError errorWithDomain: @"LBErrorDomain" code: LBCacheErrorNilHashFromURLString userInfo: @{NSLocalizedDescriptionKey: kNilURLStringToHash}];
            return nil;
        }
    }
    else
    {
        if(error != NULL)
            *error = [NSError errorWithDomain: @"LBErrorDomain" code: LBCacheErrorNilCacheDirectory userInfo: @{NSLocalizedDescriptionKey: kNilLBCacheDicrectory}];
        return nil;
    }
}

@end

