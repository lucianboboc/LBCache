//
//  UIImageView+LBcategory.h
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageOperation.h"

typedef void(^LBCacheImageBlock)(UIImage *image, NSError *error);

typedef NS_ENUM(NSUInteger,LBCacheImageOptions){
    
    // default option will search first into the cache, if the image is not found will download from the web.
    LBCacheImageOptionsDefault,
    
    // web option will download the image using from the web, if there is no internet connection or it fails, it will load the image from the cache if it was saved before.
    LBCacheImageOptionsReloadFromWebOrCache,
    
    // cache option will search only into the cache
    LBCacheImageOptionsLoadOnlyFromCache
};

@class ImageOperation;
@interface UIImageView (LBcategory)

- (void) setImageWithURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage;

- (void) setImageWithURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option;

- (void) setImageWithURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option completionBlock: (LBCacheImageBlock) completionBlock;

- (void) setImageWithURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option progressBlock: (ProgressBlock) progressBlock completionBlock: (LBCacheImageBlock) completionBlock;

- (UIImage *) imageForURLString: (NSString *) urlString;

- (void) cancelDownload;

@end
