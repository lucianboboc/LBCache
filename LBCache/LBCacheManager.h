//
//  LBCache.h
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//


#if ! __has_feature(objc_arc)
#error LBCache library is ARC only.
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
#error LBCache library needs iOS 7.0 or later.
#endif

#import <Foundation/Foundation.h>
#import "UIImageView+LBcategory.h"

#define kDaysToKeepCache 3

#define kLBCacheErrorDomain @"LBCacheErrorDomain"

#define kImageNotFoundDescription @"The image was not found at the local path in cache."
#define kCantCreateImageDescription @"The image can't be created from NSData or local path."
#define kNilDownloadURLLocation @"The download URL location is nil."
#define kNilURLStringToHash @"Can't create the hash from the image URL string."
#define kNilLBCacheDicrectory @"LBCacheDirectory is nil."

typedef NS_ENUM(NSUInteger, LBCacheError){
    // the image was not found at local path in cache
    LBCacheErrorImageNotFound,
    // the image can't be created from the NSData object
    LBCacheErrorCantCreateImage,
    // the download url location is nil
    LBCacheErrorNilDownloadLocation,
    // the hash can't be created from the image url string
    LBCacheErrorNilHashFromURLString,
    // the LBCacheDirectory is nil
    LBCacheErrorNilCacheDirectory,
};

@interface LBCacheManager : NSObject

+ (LBCacheManager * __nonnull) sharedInstance;

- (ImageOperation * __nullable) downloadImageFromURLString: (NSString * __nonnull) urlString options: (LBCacheImageOptions) options progressBlock: (ProgressBlock __nullable) progressBlock completionBlock: (LBCacheImageBlock __nonnull) completionBlock;

- (NSString * __nullable) imagePathLocationForURLString: (NSString * __nonnull) key;

- (UIImage * __nullable) imageForURLString: (NSString * __nonnull) urlString;

- (NSURL * __nonnull)applicationCachesDirectory;
- (NSURL * __nonnull) getLBCacheDirectory;

@end
