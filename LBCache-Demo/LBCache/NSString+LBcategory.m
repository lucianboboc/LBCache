//
//  NSString+LBcategory.m
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "NSString+LBcategory.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NSData+LBcategory.h"

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
            CC_MD5(str, strlen(str), buffer);
            break;
        case HashTypeSHA1:
            CC_SHA1(str, strlen(str), buffer);
            break;
        case HashTypeSHA256:
            CC_SHA256(str, strlen(str), buffer);
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











- (NSString*) lbHashMacWithKey: (NSString *) key
{
    if(!self || !key)
        return nil;
    
    const char *strPtr = [self UTF8String];
    const char *keyPtr = [key UTF8String];
    
    unsigned char buffer[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, keyPtr, kCCKeySizeAES256, strPtr, strlen(strPtr), buffer);
    
    NSMutableString *hashMacString = [[NSMutableString alloc] init];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [hashMacString appendFormat: @"%02x",buffer[i]];
    
    return hashMacString;
}














- (NSString*)encryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv {
    NSData *encrypted = [[self dataUsingEncoding:NSUTF8StringEncoding] encryptedWithAESUsingKey:key andIV:iv];
    NSString *encryptedString = [encrypted base64Encoding];
    
    return encryptedString;
}

- (NSString*)decryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv {
    NSData *decrypted = [[NSData dataWithBase64EncodedString:self] decryptedWithAESUsingKey:key andIV:iv];
    NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    
    return decryptedString;
}


@end
