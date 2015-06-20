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

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
#error LBCache library needs iOS 8.0 or later.
#endif

#import <Foundation/Foundation.h>
#import "UIImageView+LBcategory.h"

/// kDaysToKeepCache is the days duration the images will be kepped in cache.
#define kDaysToKeepCache 3

/// kLBCacheErrorDomain will provide error descriptions
#define kLBCacheErrorDomain @"LBCacheErrorDomain"

/// kImageNotFoundDescription is the error description for the LBCacheErrorImageNotFound error type.
#define kImageNotFoundDescription @"The image was not found at the local path in cache."
/// kCantCreateImageDescription is the error description for the LBCacheErrorCantCreateImage error type.
#define kCantCreateImageDescription @"The image can't be created from NSData or local path."
/// kNilDownloadURLLocation is the error description for the LBCacheErrorNilDownloadLocation error type.
#define kNilDownloadURLLocation @"The download URL location is nil."
/// kNilURLStringToHash is the error description for the LBCacheErrorNilHashFromURLString error type.
#define kNilURLStringToHash @"Can't create the hash from the image URL string."
/// kNilLBCacheDicrectory is the error description for the LBCacheErrorNilCacheDirectory error type.
#define kNilLBCacheDicrectory @"LBCacheDirectory is nil."

/// LBCacheError enum is used to describe scecific errors that could happen.
typedef NS_ENUM(NSUInteger, LBCacheError){
    // ImageNotFound is returned when the image was not found at local path in cache.
    LBCacheErrorImageNotFound,
    // CantCreateImage is returned when the image can't be created from the NSData object.
    LBCacheErrorCantCreateImage,
    // NilDownloadLocation is returned when the download url location is nil.
    LBCacheErrorNilDownloadLocation,
    // NilHashFromURLString is returned when the hash can't be created from the image url string.
    LBCacheErrorNilHashFromURLString,
    // NilCacheDirectory is returned when the LBCacheDirectory is nil.
    LBCacheErrorNilCacheDirectory,
};

/// LBCacheDownloadImageStartedNotification is a notification sent when an image download has started.
static NSString * __nonnull LBCacheDownloadImageStartedNotification = @"LBCacheDownloadImageStartedNotification";
/// LBCacheDownloadImageStoppedNotification is a notification sent when an image download has finished.
static NSString * __nonnull LBCacheDownloadImageStoppedNotification = @"LBCacheDownloadImageStoppedNotification";


/// LBCacheManager class is used to download the image from the server or load it from disk. It also offers access to the path location on disk where the an image is cached, the image from memory cache, the caches directory location and the images cache directory location.
@interface LBCacheManager : NSObject


/// LBCacheManager class method sharedInstance returns a singleton.
+ (LBCacheManager * __nonnull) sharedInstance;


/// The method will create an ImageOperation which will return the image from memory cache if found, otherwise an operation will be created to download the image from the server, load it from disk.
///
/// @param urlString is an NSString with the url string where the image is located.
/// @param options is an enum, `LBCacheImageOptions` option, which is used to decide how the image is loaded, from cache or web.
/// @param progressBlock is an ProgressBlock callback which is used to pass the percent for the ImageOperation.
/// @param completionBlock is an LBCacheOperationBlock callback which is used as a completion block for the ImageOperation.
/// @returns The ImageOperation object.
- (ImageOperation * __nullable) downloadImageFromURLString: (NSString * __nullable) urlString options: (LBCacheImageOptions) options progressBlock: (ProgressBlock __nullable) progressBlock completionBlock: (LBCacheImageBlock __nonnull) completionBlock;


- (NSString * __nullable) imagePathLocationForURLString: (NSString * __nullable) key;

- (UIImage * __nullable) imageForURLString: (NSString * __nullable) urlString;

- (NSURL * __nonnull)applicationCachesDirectory;
- (NSURL * __nonnull) getLBCacheDirectory;

@end
