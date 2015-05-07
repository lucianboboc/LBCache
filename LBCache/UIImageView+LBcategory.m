//
//  UIImageView+LBcategory.m
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "UIImageView+LBcategory.h"
#import "LBCacheManager.h"
#import <objc/runtime.h>

static char operationKey;

@implementation UIImageView (LBcategory)

- (void) setImageWithURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage
{
    [self setImageWithURLString:urlString placeholderImage:placeholderImage options: LBCacheImageOptionsDefault progressBlock: nil completionBlock: nil];
}

- (void) setImageWithURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option
{
    [self setImageWithURLString:urlString placeholderImage:placeholderImage options:option progressBlock: nil completionBlock:nil];
}


- (void) setImageWithURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option completionBlock: (LBCacheImageBlock) completionBlock
{
    [self setImageWithURLString:urlString placeholderImage:placeholderImage options: option progressBlock: nil completionBlock: completionBlock];
}

- (void) setImageWithURLString: (NSString *) urlString placeholderImage: (UIImage *) placeholderImage options: (LBCacheImageOptions) option progressBlock: (ProgressBlock) progressBlock completionBlock: (LBCacheImageBlock) completionBlock
{
    if(placeholderImage)
        self.image = placeholderImage;
    
    if(!urlString)
        return;
    
    [self cancelDownload];
    
    __weak UIImageView *weakSelf = self;
    ImageOperation *imageOperation = [[LBCacheManager sharedInstance] downloadImageFromURLString:urlString options: option progressBlock:^(NSUInteger percent){
        if(progressBlock)
            progressBlock(percent);
    } completionBlock:^(UIImage *image ,NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error)
                NSLog(@"Error: %@", error.localizedDescription);
            if(image)
            {
                __strong UIImageView *strongSelf = weakSelf;
                strongSelf.image = image;
                [strongSelf setNeedsLayout];
            }
            
            if(completionBlock) {
                completionBlock(image,error);
            }
        });
    }];
    
    objc_setAssociatedObject(self, &operationKey, imageOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}



- (UIImage *) imageForURLString: (NSString *) urlString
{
    return [[LBCacheManager sharedInstance] imageForURLString: urlString];
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
