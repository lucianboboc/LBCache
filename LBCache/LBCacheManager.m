//
//  LBCache.m
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "LBCacheManager.h"
#import "ImageOperation.h"

@interface LBCacheManager ()
@property (strong, nonatomic) NSCache *memoryCache;
@property (strong, nonatomic) NSOperationQueue *imagesQueue;

@property (nonatomic) NSInteger imageDownloadCount;
@property (strong, nonatomic) dispatch_queue_t barrierQueue;

- (void) removeCachedImages;

@end

@implementation LBCacheManager
@synthesize memoryCache = _memoryCache;
@synthesize imagesQueue = _imagesQueue;


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidReceiveMemoryWarningNotification object: [UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationWillTerminateNotification object: [UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self name: LBCacheDownloadImageStartedNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: LBCacheDownloadImageStoppedNotification object: nil];
}


#pragma mark - lyfecycle methods


- (NSCache *) memoryCache
{
    if(!_memoryCache)
    {
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.countLimit = 100;
    }
    return _memoryCache;
}

- (NSOperationQueue *) imagesQueue
{
    if(!_imagesQueue)
    {
        _imagesQueue = [[NSOperationQueue alloc] init];
        _imagesQueue.maxConcurrentOperationCount = kMaxConcurrentOperations;
    }
    return _imagesQueue;
}

+ (LBCacheManager *) sharedInstance
{
    static LBCacheManager *lbInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lbInstance = [[super allocWithZone: nil] init];
        
        [[NSNotificationCenter defaultCenter] addObserver: lbInstance selector: @selector(memoryWarningAction:) name: UIApplicationDidReceiveMemoryWarningNotification object: [UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver: lbInstance selector: @selector(memoryWarningAction:) name: UIApplicationWillTerminateNotification object: [UIApplication sharedApplication]];
        
        [[NSNotificationCenter defaultCenter] addObserver: lbInstance selector: @selector(increaseDownloadImageCount:) name: LBCacheDownloadImageStartedNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: lbInstance selector: @selector(decreaseDownloadImageCount:) name: LBCacheDownloadImageStoppedNotification object: nil];
        
        lbInstance.barrierQueue = dispatch_queue_create("com.lucianboboc.LBCache.BarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        
        [lbInstance removeCachedImages];
    });
    return lbInstance;
}

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (void) memoryWarningAction: (NSNotification *) notification
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self removeCachedImages];
    
    [self.memoryCache removeAllObjects];
    self.memoryCache = nil;
}










#pragma mark - increase / decrease download image count

- (void) increaseDownloadImageCount:(NSNotification *) notification
{
    dispatch_sync(self.barrierQueue, ^{
        if (self.imageDownloadCount == 0)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            }];
        }
        
        self.imageDownloadCount++;
    });
}

- (void) decreaseDownloadImageCount:(NSNotification *) notification
{
    dispatch_sync(self.barrierQueue, ^{
        if (self.imageDownloadCount == 1)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }];
        }
        self.imageDownloadCount--;
    });
}






#pragma mark - load and download methods


- (ImageOperation *) downloadImageFromURLString: (NSString *) urlString options: (LBCacheImageOptions) options progressBlock:(ProgressBlock)progressBlock completionBlock: (LBCacheImageBlock) completionBlock
{
    if(options == LBCacheImageOptionsDefault)
    {
        UIImage *image = [self.memoryCache objectForKey: urlString];
        if(image)
        {
            // if image is found in cache, return it
            if(completionBlock)
            {
                completionBlock(image,nil);  // LOADED FROM MEMORY CACHE
                return nil;
            }
        }
    }

    ImageOperation *imageOperation = [self startOperationWithURLString:urlString options:options progressBlock:progressBlock completionBlock: completionBlock];
    return imageOperation;
}





- (ImageOperation *) startOperationWithURLString:(NSString *)urlString options:(LBCacheImageOptions)options progressBlock:(ProgressBlock)progressBlock completionBlock:(LBCacheImageBlock)completionBlock
{
    __weak LBCacheManager *weakSelf = self;
    ImageOperation *operation = [[ImageOperation alloc] initWithURLString:urlString options:options progressBlock:^(NSUInteger percent) {
        if(progressBlock)
            progressBlock(percent);
    } completionBlock:^(UIImage *image, NSError *error) {
        
        LBCacheManager *strongSelf = weakSelf;
        if(error)
        {
            if(completionBlock)
            {
                completionBlock(nil,error);
            }
        }
        else
        {
            // save UIImage to memoryCache
            [strongSelf.memoryCache setObject: image forKey: urlString];
            
            if(completionBlock)
            {
                completionBlock(image,nil);   // LOADED FROM THE WEB
            }
        }
    }];
    
    [self.imagesQueue addOperation: operation];
    return operation;
}










#pragma mark - local path and url methods


- (UIImage *) imageForURLString: (NSString *) urlString
{
    UIImage *image = [self.memoryCache objectForKey: urlString];
    if(image)
        return image;
    else
    {
        NSString *path = [self imagePathLocationForURLString: urlString];
        if(path)
        {
            image = [[UIImage alloc] initWithContentsOfFile: path];
            return image;
        }
        else
            return nil;
    }
}




- (NSString *) imagePathLocationForURLString: (NSString *) key
{
    if(!key)
        return nil;
    
    NSURL *imagesURLDirectory = [self getLBCacheDirectory];
    
    if(imagesURLDirectory)
    {
        NSString *imageName = [key lbHashWithType: kDefaultHashType];
        if(imageName)
        {
            NSURL *imageURL = [imagesURLDirectory URLByAppendingPathComponent: imageName];
            
            NSFileManager *fm = [[NSFileManager alloc] init];
            if([fm fileExistsAtPath: [imageURL path]])
                return [imageURL path];
            else
                return nil;
        }
        else
            return nil;
    }
    else
        return nil;
}


- (NSURL *)applicationCachesDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *) getLBCacheDirectory
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSURL *cachesURL = [self applicationCachesDirectory];
    NSURL *imagesURLDirectory = [cachesURL URLByAppendingPathComponent: @"LBCacheDirectory"];
    
    NSError *error = nil;
    BOOL isDir;
    if(![fm fileExistsAtPath: [imagesURLDirectory path] isDirectory: &isDir])
    {
        if(![fm createDirectoryAtURL: imagesURLDirectory withIntermediateDirectories: NO attributes: nil error: &error]){
            return nil;
        }
        else
        {
            return imagesURLDirectory;
        }
        
    }
    else
    {
        return imagesURLDirectory;
    }
}












#pragma mark - remove cache


- (void) removeCachedImages
{
   dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSURL *lbCacheDirectory = [self getLBCacheDirectory];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if(lbCacheDirectory)
        {
            NSError *error = nil;
            NSArray *images = [fm contentsOfDirectoryAtURL: lbCacheDirectory includingPropertiesForKeys: @[NSFileModificationDate] options: NSDirectoryEnumerationSkipsHiddenFiles error: &error];
            
            if(error)
                NSLog(@"contentsOfDirectoryAtURL error: %@",error.localizedDescription);
            
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.day = -(kDaysToKeepCache);
            
            NSDate *expirationDate = [[NSCalendar currentCalendar] dateByAddingComponents: components toDate: [NSDate date] options: 0];
            
            for(NSURL *image in images)
            {
                NSDictionary *attributes = [fm attributesOfItemAtPath: [image path] error: nil];
                if(attributes)
                {
                    NSDate *date = [attributes objectForKey: NSFileModificationDate];
                    if([expirationDate compare: date] == NSOrderedDescending)
                        [fm removeItemAtPath: [image path] error: nil];
                }
            }
        }
   });
}


@end
