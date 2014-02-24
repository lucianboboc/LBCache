//
//  NSURLConnection+LBcategory.m
//  Created by Lucian Boboc on 1/27/13.
//

#import "NSURLConnection+LBcategory.h"

@implementation NSURLConnection (LBcategory)

+ (NSOperationQueue *) sharedQueue
{
    static NSOperationQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount: kMaxConcurrentOperations];
    });
    return queue;
}




+ (void) sendSynchronousImageRequestUsingURLString: (NSString *) urlString completionBlock: (ImageCompletionBlock) completionBlock
{
    if(!urlString)
    {
        NSError *error = [NSError errorWithDomain: @"LBErrorDomain" code: 1 userInfo: @{NSLocalizedDescriptionKey: @"Invalid URL."}];
        if(completionBlock)
            completionBlock(nil,nil,nil,error);
        return;
    }

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: urlString] cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: kTimeoutInteral];
    [request setAllHTTPHeaderFields: @{@"Accept":@"image/*"}];
    [request setHTTPMethod: @"GET"];
    [request setTimeoutInterval: kTimeoutInteral];

    [request setHTTPShouldUsePipelining: YES];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];

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
            completionBlock(nil,nil,nil,error);
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
#if DEBUG
                    NSLog(@"REQUEST URL %@ statusCode: %ld", urlString, (long)theResponse.statusCode);
#endif
                    completionBlock(nil,nil,nil,error);
                }
                else
                    completionBlock(image,data,theResponse,nil);
            }
            else
            {
                NSError *error = [NSError errorWithDomain: NSURLErrorDomain code: statusCode userInfo: nil];
#if DEBUG
                NSLog(@"REQUEST URL %@ statusCode: %ld", urlString, (long)theResponse.statusCode);
#endif
                completionBlock(nil,nil,nil,error);
            }
        }
    }
}


+ (void) sendAsynchronousImageRequestUsingURLString: (NSString *) urlString completionBlock: (ImageCompletionBlock) completionBlock
{
    if(!urlString)
    {
        NSError *error = [NSError errorWithDomain: @"LBErrorDomain" code: 1 userInfo: @{NSLocalizedDescriptionKey: @"Invalid URL."}];
        if(completionBlock)
            completionBlock(nil,nil,nil,error);
        return;
    }

    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
    [request setAllHTTPHeaderFields: @{@"Accept":@"image/*"}];
    [request setHTTPMethod: @"GET"];
    [request setTimeoutInterval: kTimeoutInteral];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSURLConnection sendAsynchronousRequest: request queue: [NSURLConnection sharedQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){

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
                completionBlock(nil,nil,nil,error);
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
#if DEBUG
                        NSLog(@"REQUEST URL %@ statusCode: %ld", urlString, (long)theResponse.statusCode);
#endif
                        completionBlock(nil,nil,nil,error);
                    }
                    else
                        completionBlock(image,data,theResponse,nil);
                }
                else
                {
                    NSError *error = [NSError errorWithDomain: NSURLErrorDomain code: statusCode userInfo: nil];
#if DEBUG
                    NSLog(@"REQUEST URL %@ statusCode: %ld", urlString, (long)theResponse.statusCode);
#endif
                    completionBlock(nil,nil,nil,error);
                }
            }
        }
    }];
}





+ (void) sendAsynchronousRequestUsingURLString: (NSString *) urlString stringHTTPBody: (NSString *) stringBody method: (NSString *) method completionBlock: (JSONObjectCompletionBlock) completionBlock
{

    if(!urlString || !method)
    {
        NSError *error = [NSError errorWithDomain: @"LBErrorDomain" code: 1 userInfo: @{NSLocalizedDescriptionKey: @"Invalid method argument(s)."}];
        if(completionBlock)
            completionBlock(nil,nil,error);
        return;
    }

    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setAllHTTPHeaderFields: @{@"Accept":@"application/json"}];
    [request setHTTPMethod: method];
    [request setTimeoutInterval: kTimeoutInteral];

    if(stringBody)
        [request setHTTPBody: [stringBody dataUsingEncoding:NSUTF8StringEncoding]];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSURLConnection sendAsynchronousRequest: request queue: [NSURLConnection sharedQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){

        dispatch_async(dispatch_get_main_queue(), ^{

            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            if(error != nil)
            {
                if(completionBlock)
                {
#if DEBUG
                    NSLog(@"REQUEST URL %@ \nERROR: %@", urlString, error.localizedDescription);
#endif
                    completionBlock(nil,nil,error);
                }
            }
            else
            {
                if(completionBlock)
                {
                    NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;

                    NSError *jsonError = nil;
                    id object = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers | NSJSONReadingAllowFragments error: &jsonError];
                    if(jsonError != nil)
                    {
#if DEBUG
                        NSLog(@"REQUEST URL %@ \nJSON ERROR: %@", urlString, jsonError.localizedDescription);
                        NSLog(@"REQUEST URL %@ statusCode: %ld \nSTRING: %@", urlString, (long)theResponse.statusCode, [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding]);
#endif
                        completionBlock(nil,nil,jsonError);
                    }
                    else
                    {
#if DEBUG
                        NSLog(@"REQUEST URL %@ \nJSON RESPONSE: %@", urlString, object);
#endif
                        completionBlock(object,theResponse,nil);
                    }
                }
            }
        });
    }];
}


+ (void) sendAsynchronousRequestUsingURLString: (NSString *) urlString objectHTTPBody: (id) object method: (NSString *) method completionBlock: (JSONObjectCompletionBlock) completionBlock
{
    if(!urlString || !object || !method)
    {
        NSError *error = [NSError errorWithDomain: @"LBErrorDomain" code: 1 userInfo: @{NSLocalizedDescriptionKey: @"Invalid method argument(s)."}];
        if(completionBlock)
            completionBlock(nil,nil,error);
        return;
    }

    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: object options: 0 error: &error];
    if(error)
    {
        if(completionBlock)
            completionBlock(nil,nil,error);
        return;
    }

    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setAllHTTPHeaderFields: @{@"Accept":@"application/json"}];
    [request setHTTPMethod: method];
    [request setTimeoutInterval: kTimeoutInteral];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue: [NSString stringWithFormat: @"%lu",(unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSURLConnection sendAsynchronousRequest: request queue: [NSURLConnection sharedQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){

        dispatch_async(dispatch_get_main_queue(), ^{

            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            if(error != nil)
            {
                if(completionBlock)
                {
#if DEBUG
                    NSLog(@"REQUEST URL %@ \nERROR: %@", urlString, error.localizedDescription);
#endif
                    completionBlock(nil,nil,error);
                }
            }
            else
            {
                if(completionBlock)
                {
                    NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;

                    NSError *jsonError = nil;
                    id object = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers | NSJSONReadingAllowFragments error: &jsonError];
                    if(jsonError != nil)
                    {
#if DEBUG
                        NSLog(@"REQUEST URL %@ \nJSON ERROR: %@", urlString, jsonError.localizedDescription);
                        NSLog(@"REQUEST URL %@ statusCode: %ld \nSTRING: %@", urlString, (long)theResponse.statusCode, [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding]);
#endif
                        completionBlock(nil,nil,jsonError);
                    }
                    else
                    {
#if DEBUG
                        NSLog(@"REQUEST URL %@ \nJSON RESPONSE: %@", urlString, object);
#endif
                        completionBlock(object,theResponse,nil);
                    }
                }
            }
        });
    }];
}

@end
