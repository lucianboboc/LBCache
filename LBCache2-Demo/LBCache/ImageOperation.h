//
//  ImageOperation.h
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+LBcategory.h"

#define kDefaultHashType HashTypeSHA1

typedef void(^LBCacheOperationBlock)(UIImage *image, NSError *error);
// the ProgressBlock parameter is the percent
typedef void(^ProgressBlock)(NSUInteger percent);

@interface ImageOperation : NSOperation

- (id) initWithURLString: (NSString *) urlString progressBlock: (ProgressBlock) progressBlock completionBlock: (LBCacheOperationBlock) completionBlock;

@end
