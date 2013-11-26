//
//  UIImageView+LBcategory.m
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "UIImageView+LBcategory.h"
#import "LBCache.h"
#import <objc/runtime.h>

static char operationKey;

@implementation UIImageView (LBcategory)

- (void) setImageURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage
{
    [self setImageURLString:urlString placeholderImage:placeholderImage options: LBCacheImageOptionsDefault completionBlock: nil];
}

- (void) setImageURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option
{
    [self setImageURLString:urlString placeholderImage:placeholderImage options:option completionBlock:nil];
}


- (void) setImageURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option completionBlock: (LBCacheImageBlock) completionBlock
{
    if(placeholderImage)
        self.image = placeholderImage;
    
    if(!urlString)
        return;
    
    [self cancelDownload];
    
    __weak UIImageView *weakSelf = self;
    ImageOperation *imageOperation = [[LBCache sharedInstance] downloadImageFromURLString:urlString options: option completionBlock:^(UIImage *image ,NSError *error) {
    
        if(error)
            NSLog(@"Error: %@", error.localizedDescription);
        if(image)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong UIImageView *strongSelf = weakSelf;
                strongSelf.image = image;
                [strongSelf setNeedsLayout];
            });
        }
        
        if(completionBlock)
            completionBlock(image,error);
    }];
    
    objc_setAssociatedObject(self, &operationKey, imageOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}



- (UIImage *) imageForURLString: (NSString *) urlString
{
    return [[LBCache sharedInstance] imageForURLString: urlString];
}


- (void) cancelDownload
{
    ImageOperation *imageOperation = objc_getAssociatedObject(self, &operationKey);
    if(imageOperation)
    {
       [imageOperation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}


@end
