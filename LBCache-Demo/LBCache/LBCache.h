//
//  LBCache.h
//  LBCache
//
//  Created by Lucian Boboc on 6/1/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//


#if ! __has_feature(objc_arc)
#error LBCache library is ARC only.
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
#error LBCache library needs iOS 5.0 or later.
#endif

#import <Foundation/Foundation.h>
#import "UIImageView+LBcategory.h"
#import "NSString+LBcategory.h"

#define kDaysToKeepCache 3
#define kDefaultHashType HashTypeSHA1

@interface LBCache : NSObject

+ (LBCache *) sharedInstance;

- (ImageOperation *) downloadImageFromURLString: (NSString *) urlString options: (LBCacheImageOptions) options completionBlock: (LBCacheImageBlock) completionBlock;

- (NSString *) imagePathLocationForURLString: (NSString *) key;

- (UIImage *) imageForURLString: (NSString *) urlString;

@end
