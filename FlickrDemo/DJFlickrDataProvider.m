//
//  DJFlickrDataProvider.m
//  FlickrDemo
//
//  Created by Daniel Johnston on 3/14/13.
//
//


#import "DJFlickrDataProvider.h"
#import "DeferredAPI.h"
#import "Deferred.h"
#import "Promise.h"
#import "NSDictionary+URLQueryString.h"

@interface DJFlickrDataProvider ()

@end


@implementation DJFlickrDataProvider


-(id)initWithAssetLoader:(DJAssetLoader *)assetLoader flickrApiKey:(NSString*)flickrApiKey{
    if (self = [super init])
    {
        self.assetLoader = assetLoader;
        self.flickrApiKey = flickrApiKey;
        self.flickrApiUrl = @"http://www.flickr.com/services/rest/";
    }
    return self;
}


-(Promise *)flickrRequestWithMethod:(NSString *)method params:(NSDictionary *)params{
    __block Deferred *dfd = [DeferredAPI deferred];
    __block Promise *promise = [dfd promise];
    
    NSDictionary *baseParams = [NSDictionary dictionaryWithObjectsAndKeys:self.flickrApiKey,@"api_key", @"json", @"format", method, @"method", @"1", @"nojsoncallback", nil];
    
    NSMutableDictionary *mergedParams = [baseParams mutableCopy];
    if(params != nil)
        [mergedParams addEntriesFromDictionary:params];
    
    NSString *flickrFullUrl = [NSString stringWithFormat:@"%@%@",self.flickrApiUrl,[mergedParams urlQueryString]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:flickrFullUrl]];
    
    Promise *webAssetPromise = [self.assetLoader loadWebAsset:request];
    
    [webAssetPromise doneWithData:^(id data) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if(error){
            [dfd rejectWith:error];
        }else if([[json valueForKey:@"stat"] compare:@"fail" options:NSCaseInsensitiveSearch] == NSOrderedSame){
            [dfd rejectWith:json];
        }else{
            [dfd resolveWith:json];
        }
    }];
    
    [webAssetPromise failWithData:^(id data) {
        [dfd rejectWith:data];
    }];
    
    return promise;
}


+(NSURL *)flickrPhotoSourceUrlWithFarmId:(NSString *)farmId serverId:(NSString *)serverId photoId:(NSString *)photoId secret:(NSString *)secret{
    
    return [DJFlickrDataProvider flickrPhotoSourceUrlWithFarmId:farmId serverId:serverId photoId:photoId secret:secret size:nil];
}

+(NSURL *)flickrPhotoSourceUrlWithFarmId:(NSString *)farmId serverId:(NSString *)serverId photoId:(NSString *)photoId secret:(NSString *)secret size:(NSString *)size{
    
    NSString *finalSize = size;
    if(finalSize == nil)
        finalSize = kLargeSquare150x150;
    
    NSAssert(farmId != nil, @"farm id secret cannot be nil!");
    NSAssert(serverId != nil, @"server id secret cannot be nil!");
    NSAssert(secret != nil, @"secret id  cannot be nil!");
    NSAssert(photoId != nil, @"photo id  cannot be nil!");
    
    NSString *photoSource = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg",farmId, serverId, photoId, secret, finalSize];
    return [NSURL URLWithString:photoSource];
}

@end
