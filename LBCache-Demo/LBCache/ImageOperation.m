//
//  ImageOperation.m
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "ImageOperation.h"
#import "NSURLConnection+LBcategory.h"

@interface ImageOperation ()
@property (strong, nonatomic) NSString *urlString;
@property (copy, nonatomic) LBCacheOperationBlock imageBlock;

@end

@implementation ImageOperation

- (id) initWithURLString: (NSString *) urlString completionBlock: (LBCacheOperationBlock) completionBlock
{
    self = [super init];
    if(self)
    {
        self.urlString = urlString;
        self.imageBlock = completionBlock;
    }
    return self;
}

- (void) main
{
    if(self.isCancelled)
        return;
    __weak ImageOperation *weakSelf = self;
    
    [NSURLConnection sendSynchronousImageRequestUsingURLString: self.urlString completionBlock:^(UIImage *image, NSData *imageData, NSHTTPURLResponse *response, NSError *error) {

        ImageOperation *strongSelf = weakSelf;        
        if(strongSelf.isCancelled)
            return;
        
        if(error)
        {
            if(strongSelf.imageBlock)
                strongSelf.imageBlock(nil,nil,error);
        }
        else	
            strongSelf.imageBlock(image,imageData,nil);
    }];
}


@end
