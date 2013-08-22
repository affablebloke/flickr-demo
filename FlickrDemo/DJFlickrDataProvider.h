//
//  DJFlickrDataProvider.h
//  FlickrDemo
//
//  Created by Daniel Johnston on 3/14/13.
//
//

#import <Foundation/Foundation.h>
#import "DJAssetLoader.h"

@protocol DJFlickrDataProviderDelegate <NSObject>
@optional

@end

#pragma mark flickr size suffixes
#define kSmallSquare75x75 @"s"
#define kLargeSquare150x150 @"q"
#define kThumbnail100OnLongestSide @"t"
#define kSmall240OnLongestSide @"m"
#define kSmall320OnLongestSide @"n"
#define kMedium640OnLongestSide @"z"


@interface DJFlickrDataProvider : NSObject

@property (strong, nonatomic) DJAssetLoader *assetLoader;
@property (copy, nonatomic) NSString *flickrApiKey;
@property (copy, nonatomic) NSString *flickrApiUrl;

-(id)initWithAssetLoader:(DJAssetLoader *)assetLoader flickrApiKey:(NSString *)flickrApiKey;

/*
 http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
 or
 http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
 or
 http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{o-secret}_o.(jpg|gif|png)
*/

+(NSURL *)flickrPhotoSourceUrlWithFarmId:(NSString *)farmId serverId:(NSString *)serverId photoId:(NSString *)imageId secret:(NSString *)secret;
+(NSURL *)flickrPhotoSourceUrlWithFarmId:(NSString *)farmId serverId:(NSString *)serverId photoId:(NSString *)imageId secret:(NSString *)secret size:(NSString *)size;
-(Promise *)flickrRequestWithMethod:(NSString *)method params:(NSDictionary *)params;

@end
