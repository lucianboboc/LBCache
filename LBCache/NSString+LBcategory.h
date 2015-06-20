//
//  NSString+LBcategory.h
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LBcategory)

typedef NS_ENUM(NSUInteger, HashType){
    HashTypeMD5,
    HashTypeSHA1,
    HashTypeSHA256
};

- (NSString* __nullable) lbHashMD5;
- (NSString* __nullable) lbHashSHA1;
- (NSString* __nullable) lbHashSHA256;
- (NSString* __nullable) lbHashWithType: (HashType) hashType;

@end
