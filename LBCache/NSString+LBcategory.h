//
//  NSString+LBcategory.h
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (LBcategory)


/// HashType enum is used as an option used for the hash type.
typedef NS_ENUM(NSUInteger, HashType){
    /// MD5 option will create the hash using the CC_MD5 function.
    HashTypeMD5,
    /// SHA1 option will create the hash using the CC_SHA1 function.
    HashTypeSHA1,
    /// SHA256 option will create the hash using the CC_SHA256 function.
    HashTypeSHA256
};


/// The method will return an MD5 hash string.
///
/// @returns The NSString hash object.
- (NSString* __nullable) lbHashMD5;


/// The method will return an SHA1 hash string.
///
/// @returns The NSString hash object.
- (NSString* __nullable) lbHashSHA1;


/// The method will return an SHA256 hash string.
///
/// @returns The NSString hash object.
- (NSString* __nullable) lbHashSHA256;


/// The method will return a hash string, the type of the hash is determined by the param.
///
/// @param hashType is an HashType enum and it will determine the type of the hash.
/// @returns The NSString hash object.
- (NSString* __nullable) lbHashWithType: (HashType) hashType;


@end
