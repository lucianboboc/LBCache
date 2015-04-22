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

- (NSString*) lbHashMD5;
- (NSString*) lbHashSHA1;
- (NSString*) lbHashSHA256;
- (NSString*) lbHashWithType: (HashType) hashType;

@end
