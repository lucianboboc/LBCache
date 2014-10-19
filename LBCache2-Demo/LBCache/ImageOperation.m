//
//  ImageOperation.m
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "ImageOperation.h"
#import "NSURLSession+LBcategory.h"
#import "LBCache.h"
#import <ImageIO/ImageIO.h>

@interface ImageOperation () <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property (strong, nonatomic) NSURLSession *sesstion;
@property (strong, nonatomic) NSString *urlString;
@property (copy, nonatomic) LBCacheOperationBlock imageBlock;
@property (copy, nonatomic) ProgressBlock progressBlock;
@property (strong, nonatomic) NSURL *location;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@end

@implementation ImageOperation
@synthesize executing = _executing;
@synthesize finished = _finished;

- (void) dealloc{
    [_sesstion invalidateAndCancel];
}

- (id) initWithURLString: (NSString *) urlString progressBlock:(ProgressBlock)progressBlock completionBlock: (LBCacheOperationBlock) completionBlock
{
    self = [super init];
    if(self)
    {
        _executing = NO;
        _finished = NO;
        _sesstion = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration ephemeralSessionConfiguration] delegate: self delegateQueue: nil];
        self.urlString = urlString;
        self.progressBlock = progressBlock;
        self.imageBlock = completionBlock;
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
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: self.urlString] cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: kTimeoutInteral];
    [request setAllHTTPHeaderFields: @{@"Accept":@"image/*"}];
    [request setHTTPMethod: @"GET"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    
    NSURLSessionDownloadTask *task = [self.sesstion downloadTaskWithRequest: request];
    [task resume];

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
                if(image)
                    self.imageBlock(image, nil);
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
    
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    if(!imageRef)
    {
        if(imageSource)
            CFRelease(imageSource);
        return nil;
    }
    else
    {
        UIImage *img = [[UIImage alloc] initWithCGImage: imageRef];

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
    NSURL *imagesURLDirectory = [[LBCache sharedInstance] getLBCacheDirectory];
    
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

