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

- (void) setImageWithURLString: (NSString * __nullable) urlString placeholderImage: (UIImage * __nullable) placeholderImage;

- (void) setImageWithURLString: (NSString * __nullable) urlString placeholderImage: (UIImage * __nullable) placeholderImage options: (LBCacheImageOptions) option;

- (void) setImageWithURLString: (NSString * __nullable) urlString placeholderImage: (UIImage * __nullable) placeholderImage options: (LBCacheImageOptions) option completionBlock: (LBCacheImageBlock __nullable) completionBlock;

- (void) setImageWithURLString: (NSString * __nullable) urlString placeholderImage: (UIImage * __nullable) placeholderImage options: (LBCacheImageOptions) option progressBlock: (ProgressBlock __nullable) progressBlock completionBlock: (LBCacheImageBlock __nullable) completionBlock;

- (UIImage * __nullable) imageForURLString: (NSString * __nullable) urlString;

- (void) cancelDownload;

@end
