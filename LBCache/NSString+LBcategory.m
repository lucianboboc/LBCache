//
//  NSString+LBcategory.m
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "NSString+LBcategory.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (LBcategory)

- (NSString*) lbHashMD5
{
    return [self lbHashWithType: HashTypeMD5];
}

- (NSString*) lbHashSHA1
{
    return [self lbHashWithType: HashTypeSHA1];
}

- (NSString*) lbHashSHA256
{
    return [self lbHashWithType: HashTypeSHA256];
}

- (NSString*) lbHashWithType: (HashType) hashType
{
    if(!self)
        return nil;
    
    const char *str = [self UTF8String];
    NSInteger bufferSize;

    switch (hashType) {
        case HashTypeMD5:
            bufferSize = CC_MD5_DIGEST_LENGTH;
            break;
        case HashTypeSHA1:
            bufferSize = CC_SHA1_DIGEST_LENGTH;
            break;
        case HashTypeSHA256:
            bufferSize = CC_SHA256_DIGEST_LENGTH;
            break;
        default:
            return nil;
            break;
    }
    
    unsigned char buffer[bufferSize];
    
    switch (hashType) {
        case HashTypeMD5:
            CC_MD5(str, (CC_LONG)strlen(str), buffer);
            break;
        case HashTypeSHA1:
            CC_SHA1(str, (CC_LONG)strlen(str), buffer);
            break;
        case HashTypeSHA256:
            CC_SHA256(str, (CC_LONG)strlen(str), buffer);
            break;
        default:
            return nil;
            break;
    }    
    
    NSMutableString *hashString = [[NSMutableString alloc] initWithCapacity: bufferSize * 2];
    for(int i = 0; i < bufferSize; i++){
        [hashString appendFormat:@"%02x",buffer[i]];
    }
    
    return hashString;
}


@end
