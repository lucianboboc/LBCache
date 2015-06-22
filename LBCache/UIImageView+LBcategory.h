//
//  UIImageView+LBcategory.h
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageOperation.h"

@interface UIImageView (LBcategory)


/// The method will start the image download and image will be set after download is complete.
///
/// @param urlString is an NSString with the url string where the image is located.
/// @param placeholderImage is a UIImage with the image that will be used as a placeholder until the image was downloaded.
- (void) setImageWithURLString: (NSString * __nullable) urlString placeholderImage: (UIImage * __nullable) placeholderImage;


/// The method will start the image download and image will be set after download is complete.
///
/// @param urlString is an NSString with the url string where the image is located.
/// @param placeholderImage is a UIImage with the image that will be used as a placeholder until the image was downloaded.
/// @param options is an enum, `LBCacheImageOptions` option, which is used to decide how the image is loaded, from cache or web.
- (void) setImageWithURLString: (NSString * __nullable) urlString placeholderImage: (UIImage * __nullable) placeholderImage options: (LBCacheImageOptions) option;


/// The method will start the image download and also return it in the completion block if download was successfull.
///
/// @param urlString is an NSString with the url string where the image is located.
/// @param placeholderImage is a UIImage with the image that will be used as a placeholder until the image was downloaded.
/// @param options is an enum, `LBCacheImageOptions` option, which is used to decide how the image is loaded, from cache or web.
/// @param completionBlock is an LBCacheOperationBlock callback which is used as a completion block for the ImageOperation.
- (void) setImageWithURLString: (NSString * __nullable) urlString placeholderImage: (UIImage * __nullable) placeholderImage options: (LBCacheImageOptions) option completionBlock: (LBCacheImageBlock __nullable) completionBlock;



/// The method will start the image download and also return it in the completion block if download was successfull. It also offer a progress callback option.
///
/// @param urlString is an NSString with the url string where the image is located.
/// @param placeholderImage is a UIImage with the image that will be used as a placeholder until the image was downloaded.
/// @param options is an enum, `LBCacheImageOptions` option, which is used to decide how the image is loaded, from cache or web.
/// @param progressBlock is an ProgressBlock callback which is used to pass the percent for the ImageOperation.
/// @param completionBlock is an LBCacheOperationBlock callback which is used as a completion block for the ImageOperation.
- (void) setImageWithURLString: (NSString * __nullable) urlString placeholderImage: (UIImage * __nullable) placeholderImage options: (LBCacheImageOptions) option progressBlock: (ProgressBlock __nullable) progressBlock completionBlock: (LBCacheImageBlock __nullable) completionBlock;


/// The method will return the image object from the cache, memory or from the disk.
///
/// @param urlString is an NSString with the url string where the image is located.
/// @returns The UIImage object if it's found in memory or on the disk.
- (UIImage * __nullable) imageForURLString: (NSString * __nullable) urlString;


/// The method will cancel the download of the image.
- (void) cancelDownload;


@end
