//
//  LBCache.m
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "LBCache.h"
#import "NSURLConnection+LBcategory.h"
#import "ImageOperation.h"

@interface LBCache ()
@property (strong, nonatomic) NSCache *memoryCache;
@property (strong, nonatomic) NSOperationQueue *imagesQueue;

- (ImageOperation *) downloadImageFromURLString:(NSString *)urlString completionBlock:(LBCacheImageBlock)completionBlock;
- (ImageOperation *) loadImageFromDiskOrFromWebURLString:(NSString *)urlString completionBlock:(LBCacheImageBlock)completionBlock;
- (void) loadImageFromDiskURLString:(NSString *)urlString completionBlock:(LBCacheImageBlock)completionBlock;
- (void) removeCachedImages;

@end

@implementation LBCache
@synthesize memoryCache = _memoryCache;
@synthesize imagesQueue = _imagesQueue;

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidReceiveMemoryWarningNotification object: [UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationWillTerminateNotification object: [UIApplication sharedApplication]];
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
        _imagesQueue.maxConcurrentOperationCount = 2;
    }
    return _imagesQueue;
}

+ (LBCache *) sharedInstance
{
    static LBCache *lbInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lbInstance = [[super allocWithZone: nil] init];
        
        [[NSNotificationCenter defaultCenter] addObserver: lbInstance selector: @selector(memoryWarningAction:) name: UIApplicationDidReceiveMemoryWarningNotification object: [UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver: lbInstance selector: @selector(memoryWarningAction:) name: UIApplicationWillTerminateNotification object: [UIApplication sharedApplication]];
        
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
















#pragma mark - load and download methods


- (ImageOperation *) downloadImageFromURLString: (NSString *) urlString options: (LBCacheImageOptions) options completionBlock: (LBCacheImageBlock) completionBlock
{
    ImageOperation *imageOperation = nil;
    
    if(options == LBCacheImageOptionsDefault)
    {
        UIImage *image = [self.memoryCache objectForKey: urlString];
        if(image)
        {
            // if image is found in cache, return it
            if(completionBlock)
            {
                completionBlock(image,nil);  // LOADED FROM MEMORY CACHE
            }
        }
        else
            imageOperation = [self loadImageFromDiskOrFromWebURLString: urlString completionBlock: completionBlock];
    }
    else if(options == LBCacheImageOptionsLoadOnlyFromCache)
    {
        UIImage *image = [self.memoryCache objectForKey: urlString];
        if(image)
        {
            // if image is found in cache, return it
            if(completionBlock)
            {
                completionBlock(image,nil);  // LOADED FROM MEMORY CACHE
            }
        }
        else
            [self loadImageFromDiskURLString: urlString completionBlock:completionBlock];
    }
    else
        imageOperation = [self downloadImageFromURLString: urlString completionBlock: completionBlock];

    return imageOperation;
}





- (void) loadImageFromDiskURLString:(NSString *)urlString completionBlock:(LBCacheImageBlock)completionBlock
{
    NSString *imagePath = [self imagePathLocationForURLString: urlString];
    if(imagePath)
    {
        // if image exists at local path, create and return it
        UIImage *image = [UIImage imageWithContentsOfFile: imagePath];
        if(image)
        {
            [self.memoryCache setObject: image forKey: urlString];
            
            if(completionBlock)
            {
                completionBlock(image,nil);   // LOADED FROM DISK
            }
        }
        else
        {
            // CAN'T CREATE IMAGE
            if(completionBlock)
            {
                NSError *error = [NSError errorWithDomain: kLBErrorDomain code: LBCacheErrorCantCreateImage userInfo: @{NSLocalizedDescriptionKey: kCantCreateImageDescription}];
                completionBlock(nil,error);
            }            
        }
    }
    else
    {   // file doesn't exists at local path
        if(completionBlock)
        {
            NSError *error = [NSError errorWithDomain: kLBErrorDomain code: LBCacheErrorImageNotFound userInfo: @{NSLocalizedDescriptionKey: kImageNotFoundDescription}];
            completionBlock(nil,error);
        }
    }
}


- (ImageOperation *) loadImageFromDiskOrFromWebURLString:(NSString *)urlString completionBlock:(LBCacheImageBlock)completionBlock
{
    ImageOperation *imageOperation = nil;
    
    NSString *imagePath = [self imagePathLocationForURLString: urlString];
    if(imagePath)
    {
        // if image exists at local path, create and return it
        UIImage *image = [UIImage imageWithContentsOfFile: imagePath];
        if(image)
        {
            [self.memoryCache setObject: image forKey: urlString];
            if(completionBlock)
            {
                completionBlock(image,nil);  // LOADED FROM DISK
            }
        }
        else
           imageOperation = [self downloadImageFromURLString:urlString completionBlock:completionBlock];
    }
    else
        imageOperation = [self downloadImageFromURLString:urlString completionBlock:completionBlock];

    return imageOperation;
}



- (ImageOperation *) downloadImageFromURLString:(NSString *)urlString completionBlock:(LBCacheImageBlock)completionBlock
{
    __weak LBCache *weakSelf = self;
    ImageOperation *operation = [[ImageOperation alloc] initWithURLString: urlString completionBlock:^(UIImage *image, NSData *imageData, NSError *error) {

        LBCache *strongSelf = weakSelf;
        if(error)
        {
            if(completionBlock)
                completionBlock(nil,error);  // ERROR
        }
        else
        {
            if(image)
            {
                // save NSData to local path
                [strongSelf saveImageData:imageData forURLString: urlString];
                
                // save UIImage to memoryCache
                [strongSelf.memoryCache setObject: image forKey: urlString];
                
                if(completionBlock)
                {
                    completionBlock(image,nil);   // LOADED FROM THE WEB
                }
            }
            else
            {
                // CAN'T CREATE IMAGE
                if(completionBlock)
                {
                    NSError *error = [NSError errorWithDomain: kLBErrorDomain code: LBCacheErrorCantCreateImage userInfo: @{NSLocalizedDescriptionKey: kCantCreateImageDescription}];
                    completionBlock(nil,error);
                }
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




- (void) saveImageData: (NSData *) imageData forURLString: (NSString *) urlString
{
    NSURL *imagesURLDirectory = [self getLBCacheDirectory];
    
    if(imagesURLDirectory)
    {
        NSString *imageName = [urlString lbHashWithType: kDefaultHashType];
        if(imageName)
        {
            NSURL *imageURL = [imagesURLDirectory URLByAppendingPathComponent: imageName];
            [imageData writeToURL: imageURL atomically: YES];
        }
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
