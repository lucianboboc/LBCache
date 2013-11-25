//
//  NSData+LBcategory.m
//  LBCache-Demo
//
//  Created by Lucian Boboc on 7/8/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "NSData+LBcategory.h"
#import <CommonCrypto/CommonCrypto.h>
#import <Security/SecRandom.h>

@implementation NSData (LBcategory)

#pragma mark - encryption



- (NSData*)encryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv {
    
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    size_t dataMoved;
    // output will always be the input size + one aditional block size based on the encryption algorithm.    
    NSMutableData *encryptedData = [NSMutableData dataWithLength: self.length + kCCBlockSizeAES128];
    
    CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding,
                                     keyData.bytes,
                                     keyData.length,
                                     iv.bytes,
                                     self.bytes,
                                     self.length,
                                     encryptedData.mutableBytes,
                                     encryptedData.length,
                                     &dataMoved);
    
    if (status == kCCSuccess) {
        encryptedData.length = dataMoved;
        return encryptedData;
    }
    
    return nil;
    
}

- (NSData*)decryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv {
    
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    size_t dataMoved;
    // output will always be the input size + one aditional block size based on the encryption algorithm.
    NSMutableData *decryptedData = [NSMutableData dataWithLength: self.length + kCCBlockSizeAES128];
    
    CCCryptorStatus result = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding,
                                     keyData.bytes,
                                     keyData.length,
                                     iv.bytes,
                                     self.bytes,
                                     self.length,
                                     decryptedData.mutableBytes,
                                     decryptedData.length,
                                     &dataMoved);
    
    if (result == kCCSuccess) {
        decryptedData.length = dataMoved;
        return decryptedData;
    }
    
    return nil;
    
}
















#pragma mark - initialization vector



+ (NSData*)initializationVectorOfLength:(size_t)length {

    if (length == 0) {
        length = kCCBlockSizeAES128;
    }
    
    NSMutableData *iv = [NSMutableData dataWithLength: length];
    
    int ivResult = SecRandomCopyBytes(kSecRandomDefault,
                                      length,
                                      iv.mutableBytes);
    
    if (ivResult == noErr) {
        return iv;
    }
    
    return nil;
}

+ (NSData *) defaultInitializationVector
{
    return [NSData initializationVectorOfLength: kCCBlockSizeAES128];
}





















#pragma mark - hash methods

- (NSString*) lbHashMD5
{
    return [self lbHashWithType: DataHashTypeMD5];
}

- (NSString*) lbHashSHA1
{
    return [self lbHashWithType: DataHashTypeSHA1];
}

- (NSString*) lbHashSHA256
{
    return [self lbHashWithType: DataHashTypeSHA256];
}

- (NSString*) lbHashWithType: (DataHashType) hashType
{
    if(!self)
        return nil;
    
    const char *str = [self bytes];
    if(!str)
        return nil;
    
    NSInteger bufferSize;
    
    switch (hashType) {
        case DataHashTypeMD5:
            bufferSize = CC_MD5_DIGEST_LENGTH;
            break;
        case DataHashTypeSHA1:
            bufferSize = CC_SHA1_DIGEST_LENGTH;
            break;
        case DataHashTypeSHA256:
            bufferSize = CC_SHA256_DIGEST_LENGTH;
            break;
        default:
            return nil;
            break;
    }
    
    unsigned char buffer[bufferSize];
    
    switch (hashType) {
        case DataHashTypeMD5:
            CC_MD5(str, strlen(str), buffer);
            break;
        case DataHashTypeSHA1:
            CC_SHA1(str, strlen(str), buffer);
            break;
        case DataHashTypeSHA256:
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











@end
