//
//  ImageOperation.h
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+LBcategory.h"

#define kDefaultHashType HashTypeSHA1
#define kTimeoutInteral 30
#define kMaxConcurrentOperations 2

typedef void(^LBCacheOperationBlock)( UIImage * __nullable image, NSError * __nullable error);
// the ProgressBlock parameter is the percent
typedef void(^ProgressBlock)(NSUInteger percent);

typedef void(^LBCacheImageBlock)(UIImage  * __nullable image, NSError  * __nullable error);

typedef NS_ENUM(NSUInteger,LBCacheImageOptions){
    
    // default option will search first into the cache, if the image is not found will download from the web.
    LBCacheImageOptionsDefault,
    
    // reload option will always download the image from the web even if it is already cached.
    LBCacheImageOptionsReloadFromWeb,
    
    // cache option will search only into the cache
    LBCacheImageOptionsLoadOnlyFromCache
};


@interface ImageOperation : NSOperation

- (id __nonnull) initWithURLString:(NSString * __nonnull)urlString options:(LBCacheImageOptions)options progressBlock:(ProgressBlock __nullable)progressBlock completionBlock:(LBCacheOperationBlock __nonnull)completionBlock;

@end
