# LBCache

[![Version](https://img.shields.io/cocoapods/v/LBCache.svg?style=flat)](http://cocoapods.org/pods/LBCache)
[![License](https://img.shields.io/cocoapods/l/LBCache.svg?style=flat)](http://cocoapods.org/pods/LBCache)
[![Platform](https://img.shields.io/cocoapods/p/LBCache.svg?style=flat)](http://cocoapods.org/pods/LBCache)

LBCache is an asynchronous image cache framework for iOS
 
### How to use

# UIImageView+LBCategory.h
- this UIImageView category offer the option to set a URL string of the image location on the server;
- the image is downloaded asynchrnous in the background;
- the image is saved on the disk in the caches directory;

There are 3 options to use:
- <code>LBCacheImageOptionsDefault</code> - default option will search first into the cache, if the image is not found will download from the web.
- <code>LBCacheImageOptionsReloadFromWeb</code> - reload option will always download the image from the web even if it is already cached.
- <code>LBCacheImageOptionsLoadOnlyFromCache</code> - cache option will search only into the cache


```objective-c

  __weak UIImageView *weakImgView = cell.imgView;    
  [cell.imgView setImageWithURLString: self.array[indexPath.row] placeholderImage: nil options: LBCacheImageOptionsDefault progressBlock:^(NSUInteger percent) {
      NSLog(@"percent: %ld",percent);
  } completionBlock:^(UIImage * image, NSError * error) {
      dispatch_async(dispatch_get_main_queue(), ^{
          weakImgView.image = image;
      });
  }];

``` 


# LBCacheManager.h 
This class is used by the UIImageView category for the download but you can use it directly. You can use methods from LBCacheManager to get the UIImage object from the disk or the path location where the image is cached.
- <code>imagePathLocationForURLString:</code> - a string with the local path location of the image saved on disk or nil if the image for the URLString is not found.
- <code>imageForURLString:</code> - same as UIImageView+LBCategory, search the UIImage directly in cache (memory or disk), nil is returned if not found.

```objective-c

  __weak UIImageView *weakImgView = self.imgView;
  [[LBCacheManager sharedInstance] downloadImageFromURLString: self.array[indexPath.row] options: LBCacheImageOptionsDefault progressBlock:^(NSUInteger percent) {
      NSLog(@"percent: %ld",percent);
  } completionBlock:^(UIImage * image, NSError * error) {
      dispatch_async(dispatch_get_main_queue(), ^{
          weakImgView.image = image;
      });
  }];
  
  // you can also get the image from the disk using the urlString.
  UIImage *image = [[LBCacheManager sharedInstance] imageForURLString: urlString];

  // you can get the image path where it is cached.
  NSString *imgPath = [[LBCacheManager sharedInstance] imagePathLocationForURLString:urlString];

```

# NSString+LBCategory.h
You can use this class category to get hash value from a string.
- there are 3 options available, <code>MD5, SHA1 and SHA256</code>

Methods to use:
- <code>lbHashMD5</code> - create an MD5 hash
- <code>lbHashSHA1</code> - create an SHA1 hash
- <code>lbHashSHA256</code> - create an SHA256 hash
- <code>lbHashWithType:</code> - create a hash using the 3 available options


```objective-c

  // you can use lbHashMD5, lbHashSHA1 or lbHashSHA256 method to get the specific hash from a string.
  NSString *hashStr = [urlString lbHashSHA1];
  
  // you can also use the lbHashWithType method and pass an option HashTypeMD5, HashTypeSHA1 or HashTypeSHA256
  NSString *hashStr = [urlString lbHashWithType: HashTypeMD5];

```

###  
 
### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate LBCache into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'LBCache'
```

Then, run the following command:

```bash
$ pod install
``` 
 
 
LICENSE
=======

This content is released under the MIT License https://github.com/lucianboboc/LBCache/blob/master/LICENSE.md
 

Enjoy!
