//
//  ImageOperation.h
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+LBcategory.h"

/// kDefaultHashType is the method used to generate the hash which is used as the image name when saved on disk.
#define kDefaultHashType HashTypeSHA1
/// kTimeoutInteral is used to set the timeout for the NSMutableURLRequest.
#define kTimeoutInteral 30
/// kMaxConcurrentOperations is used to set the value of the NSOperationQueue's maxConcurrentOperationCount property.
#define kMaxConcurrentOperations 2


/// LBCacheOperationBlock block is used as a completion block for the ImageOperation.
typedef void(^LBCacheOperationBlock)( UIImage * __nullable image, NSError * __nullable error);

/// ProgressBlock block is used as a callback to pass the percent for the ImageOperation.
typedef void(^ProgressBlock)(NSUInteger percent);

/// LBCacheImageBlock block is used as a completion block for the UIImageView category methods.
typedef void(^LBCacheImageBlock)(UIImage  * __nullable image, NSError  * __nullable error);


/// LBCacheImageOptions enum is used as an option for the ImageOperation class and for the UIImageView category methods.
typedef NS_ENUM(NSUInteger,LBCacheImageOptions){
    
    /// Default option will search first into the cache, if the image is not found will download from the web.
    LBCacheImageOptionsDefault,
    
    /// ReloadFromWeb option will always download the image from the web even if it is already cached.
    LBCacheImageOptionsReloadFromWeb,
    
    /// LoadOnlyFromCache option will search only into the cache
    LBCacheImageOptionsLoadOnlyFromCache
};


/// ImageOperation class is used to download the image from the server or load it from disk. It is used by the LBCacheManager class.
@interface ImageOperation : NSOperation

/// The method will create an ImageOperation object which will be used to download the image from the server or load it from disk.
///
/// @param urlString is an NSString with the url string where the image is located.
/// @param options is an enum, `LBCacheImageOptions` option, which is used to decide how the image is loaded, from cache or web.
/// @param progressBlock is an ProgressBlock callback which is used to pass the percent for the ImageOperation.
/// @param completionBlock is an LBCacheOperationBlock callback which is used as a completion block for the ImageOperation.
/// @returns The ImageOperation object.
- (id __nonnull) initWithURLString:(NSString * __nonnull)urlString options:(LBCacheImageOptions)options progressBlock:(ProgressBlock __nullable)progressBlock completionBlock:(LBCacheOperationBlock __nonnull)completionBlock;

@end
