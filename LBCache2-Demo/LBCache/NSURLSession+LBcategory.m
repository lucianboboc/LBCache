//
//  NSURLSession+LBcategory.m
//  test
//
//  Created by Lucian Boboc on 19/11/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "NSURLSession+LBcategory.h"
#import "LBCache.h"

@implementation NSURLSession (LBcategory)


+ (NSURLSessionDataTask *) dataTaskWithImageURLString: (NSString *) urlString completionBlock: (ImageAndDataCompletionBlock) completionBlock
{
    if(!urlString)
    {
        NSError *error = [NSError errorWithDomain: @"LBErrorDomain" code: 1 userInfo: @{NSLocalizedDescriptionKey: @"Invalid URL."}];
        if(completionBlock)
            completionBlock(nil,nil,nil,error);
        return nil;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: urlString] cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: kTimeoutInteral];
    [request setAllHTTPHeaderFields: @{@"Accept":@"image/*"}];
    [request setHTTPMethod: @"GET"];
    [request setTimeoutInterval: kTimeoutInteral];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
        NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
        if(error != nil)
        {
            if(completionBlock)
            {
#if DEBUG
                NSLog(@"REQUEST URL %@ \nERROR: %@", urlString, error.localizedDescription);
#endif
                completionBlock(nil,nil,theResponse,error);
            }
        }
        else
        {
            if(completionBlock)
            {
                NSInteger statusCode = theResponse.statusCode;
                if(statusCode < 400)
                {
                    UIImage *image = [UIImage imageWithData: data];
                    if(!image)
                    {
                        NSError *error = [NSError errorWithDomain: @"LBErrorDomain" code: 0 userInfo: @{NSLocalizedDescriptionKey: @"The image can't be created from NSData."}];
                        completionBlock(nil,nil,theResponse,error);
                    }
                    else
                        completionBlock(image,data,theResponse,nil);
                }
                else
                {
                    NSError *error = [NSError errorWithDomain: NSURLErrorDomain code: statusCode userInfo: nil];
                    completionBlock(nil,nil,theResponse,error);
                }
            }
        }
    }];
    
    [task resume];
    return task;
}


















+ (NSURLSessionDataTask *) dataTaskWithURLString: (NSString *) urlString stringHTTPBody: (NSString *) stringBody method: (NSString *) method completionBlock: (JSONObjectAndDataCompletionBlock) completionBlock
{
    if(!urlString || !method)
    {
        NSError *error = [NSError errorWithDomain: @"LBErrorDomain" code: 1 userInfo: @{NSLocalizedDescriptionKey: @"Invalid method argument(s)."}];
        if(completionBlock)
            completionBlock(nil,nil,nil,error);
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setAllHTTPHeaderFields: @{@"Accept":@"application/json"}];
    [request setHTTPMethod: method];
    [request setTimeoutInterval: kTimeoutInteral];
    
    if(stringBody)
        [request setHTTPBody: [stringBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
        NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
        
        if(error != nil)
        {
            if(completionBlock)
            {
#if DEBUG
                NSLog(@"REQUEST URL %@ \nERROR: %@", urlString, error.localizedDescription);
#endif
                completionBlock(nil,data,theResponse,error);
            }
        }
        else
        {
            if(completionBlock)
            {
                NSInteger statusCode = theResponse.statusCode;
                if(statusCode < 400)
                {
                    id object = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers | NSJSONReadingAllowFragments error:&error];
                    if(error != nil)
                    {
#if DEBUG
                        NSLog(@"REQUEST URL %@ \nJSON ERROR: %@", urlString, error.localizedDescription);
#endif
                        completionBlock(nil,data,theResponse,error);
                    }
                    else
                    {
#if DEBUG
                        NSLog(@"REQUEST URL %@ \nJSON RESPONSE: %@", urlString, object);
#endif
                        completionBlock(object,data,theResponse,nil);
                    }
                }
                else
                {
                    NSError *error = [NSError errorWithDomain: NSURLErrorDomain code: statusCode userInfo: nil];
                    completionBlock(nil,nil,theResponse,error);
                }
            }
        }
        
    }];
     
     [task resume];
     return task;
}




















+ (NSURLSessionDataTask *) dataTaskWithURLString: (NSString *) urlString objectHTTPBody: (id) object method: (NSString *) method completionBlock: (JSONObjectAndDataCompletionBlock) completionBlock
{
    if(!urlString || !object || !method)
    {
        NSError *error = [NSError errorWithDomain: @"LBErrorDomain" code: 1 userInfo: @{NSLocalizedDescriptionKey: @"Invalid method argument(s)."}];
        if(completionBlock)
            completionBlock(nil,nil,nil,error);
        return nil;
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: object options: 0 error: &error];
    if(error)
    {
        if(completionBlock)
            completionBlock(nil,nil,nil,error);
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setAllHTTPHeaderFields: @{@"Accept":@"application/json"}];
    [request setHTTPMethod: method];
    [request setTimeoutInterval: kTimeoutInteral];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue: [NSString stringWithFormat: @"%u",[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
        NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
        
        if(error != nil)
        {
            if(completionBlock)
            {
#if DEBUG
                NSLog(@"REQUEST URL %@ \nERROR: %@", urlString, error.localizedDescription);
#endif
                completionBlock(nil,nil,theResponse,error);
            }
        }
        else
        {
            if(completionBlock)
            {
                NSInteger statusCode = theResponse.statusCode;
                if(statusCode < 400)
                {
                    id object = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers | NSJSONReadingAllowFragments error:&error];
                    if(error != nil)
                    {
#if DEBUG
                        NSLog(@"REQUEST URL %@ \nJSON ERROR: %@", urlString, error.localizedDescription);
#endif
                        completionBlock(nil,data,theResponse,error);
                    }
                    else
                    {
#if DEBUG
                        NSLog(@"REQUEST URL %@ \nJSON RESPONSE: %@", urlString, object);
#endif
                        completionBlock(object,data,theResponse,nil);
                    }
                }
                else
                {
                    NSError *error = [NSError errorWithDomain: NSURLErrorDomain code: statusCode userInfo: nil];
                    completionBlock(nil,nil,theResponse,error);
                }
            }
        }
        
    }];
    
    [task resume];
    return task;
}


@end
