//
//  ImageOperation.h
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LBCacheOperationBlock)(UIImage *image, NSData *imageData, NSError *error);

@interface ImageOperation : NSOperation

- (id) initWithURLString: (NSString *) urlString completionBlock: (LBCacheOperationBlock) completionBlock;

@end
