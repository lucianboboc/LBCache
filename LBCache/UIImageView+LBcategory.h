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

- (void) setImageWithURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage;

- (void) setImageWithURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option;

- (void) setImageWithURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option completionBlock: (LBCacheImageBlock) completionBlock;

- (void) setImageWithURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option progressBlock: (ProgressBlock) progressBlock completionBlock: (LBCacheImageBlock) completionBlock;

- (UIImage *) imageForURLString: (NSString *) urlString;

- (void) cancelDownload;

@end
