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
    
    // web option will download the image using the NSURLRequestReloadIgnoringCacheData policy
    LBCacheImageOptionsLoadOnlyFromWebIgnoreCache,
    
    // cache option will search only into the cache
    LBCacheImageOptionsLoadOnlyFromCache
};


@interface UIImageView (LBcategory)

- (void) setImageURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage;

- (void) setImageURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option;

- (void) setImageURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option completionBlock: (LBCacheImageBlock) completionBlock;

- (UIImage *) imageForURLString: (NSString *) urlString;

- (void) cancelDownload;

@end
