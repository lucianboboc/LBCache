//
//  NSURLSession+LBcategory.h
//  test
//
//  Created by Lucian Boboc on 19/11/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTimeoutInteral 30
#define kMaxConcurrentOperations 2

typedef void (^ImageAndDataCompletionBlock)(UIImage *image, NSData *imageData, NSHTTPURLResponse *response, NSError *error);
typedef void (^JSONObjectAndDataCompletionBlock)(id object, NSData *data, NSHTTPURLResponse *response, NSError *error);

@interface NSURLSession (LBcategory)

+ (NSURLSessionDataTask *) dataTaskWithImageURLString: (NSString *) urlString completionBlock: (ImageAndDataCompletionBlock) completionBlock;

// used to send GET and POST requests using application/x-www-form-urlencoded Content-Type
+ (NSURLSessionDataTask *) dataTaskWithURLString: (NSString *) urlString stringHTTPBody: (NSString *) stringBody method: (NSString *) method completionBlock: (JSONObjectAndDataCompletionBlock) completionBlock;

// used to send POST requests using application/json Content-Type
+ (NSURLSessionDataTask *) dataTaskWithURLString: (NSString *) urlString objectHTTPBody: (id) object method: (NSString *) method completionBlock: (JSONObjectAndDataCompletionBlock) completionBlock;

@end