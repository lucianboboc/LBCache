//
//  NSData+LBcategory.h
//  LBCache-Demo
//
//  Created by Lucian Boboc on 7/8/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (LBcategory)


typedef NS_ENUM(NSUInteger, DataHashType){
    DataHashTypeMD5,
    DataHashTypeSHA1,
    DataHashTypeSHA256
};



// encryption   key should be 16 characters
- (NSData *) encryptedWithAESUsingKey: (NSString*)key andIV:(NSData*)iv;
- (NSData *) decryptedWithAESUsingKey: (NSString*)key andIV:(NSData*)iv;



// encode to base64 when sent over the network because random generated bytes may not be UTF8
+ (NSData *) initializationVectorOfLength: (size_t) iv;  // length 8 or 16
// default iv key is 16 bytes kCCBlockSizeAES128
+ (NSData *) defaultInitializationVector;



// hash
- (NSString*) lbHashMD5;
- (NSString*) lbHashSHA1;
- (NSString*) lbHashSHA256;
- (NSString*) lbHashWithType: (DataHashType) hashType;

@end
