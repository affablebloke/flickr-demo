//
//  FlickrDemoTests.m
//  FlickrDemoTests
//
//  Created by Daniel Johnston on 3/14/13.
//  Copyright (c) 2013 HubWorks. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "FlickrDemoTests.h"
#import "DJFlickrDataProvider.h"
#import "Promise.h"

@implementation FlickrDemoTests

- (void)setUp
{
    [super setUp];
    
    self.flickrApiKey = @"621ebb706633e31319fc903146157a60";
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testFlickrTagsGetHotList
{
    __block BOOL hasCalledBack = NO;
    
    DJAssetLoader *sharedAssetLoader = [DJAssetLoader sharedAssetLoader];
    DJFlickrDataProvider *flickrDataProvider = [[DJFlickrDataProvider alloc] initWithAssetLoader:sharedAssetLoader flickrApiKey:self.flickrApiKey];
    
    Promise *flickrPromise = [flickrDataProvider flickrRequestWithMethod:@"flickr.tags.getHotList" params:nil];
    
    [flickrPromise doneWithData:^(id data) {
        hasCalledBack = YES;
    }];
    
    [flickrPromise failWithData:^(id data) {
        STFail(@"Flickr call failed flickr.tags.getHotList!");
        hasCalledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    if (!hasCalledBack)
    {
        STFail(@"Timeout Occurred!!");
    }
    
}


- (void)testFlickrPhotoSearch
{
    __block BOOL hasCalledBack = NO;
    
    DJAssetLoader *sharedAssetLoader = [DJAssetLoader sharedAssetLoader];
    DJFlickrDataProvider *flickrDataProvider = [[DJFlickrDataProvider alloc] initWithAssetLoader:sharedAssetLoader flickrApiKey:self.flickrApiKey];
   
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"page", @"wedding",
                            @"tags", @"title, owner_name, description, url_t, url_q, url_z", @"extras", nil];
    
    Promise *flickrPromise = [flickrDataProvider flickrRequestWithMethod:@"flickr.photos.search" params:params];
    
    [flickrPromise doneWithData:^(id data) {
        hasCalledBack = YES;
    }];
    
    [flickrPromise failWithData:^(id data) {
        STFail(@"Flickr call failed flickr.tags.getHotList!");
        hasCalledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    if (!hasCalledBack)
    {
        STFail(@"Timeout Occurred!!");
    }
    
}


- (void)testFlickrPhotoSourceConversion
{
    /*
     http://farm1.staticflickr.com/2/1418878_1e92283336_m.jpg
     
     farm-id: 1
     server-id: 2
     photo-id: 1418878
     secret: 1e92283336
     size: m
     */
    NSURL *url = [DJFlickrDataProvider flickrPhotoSourceUrlWithFarmId:@"1" serverId:@"2" photoId:@"1418878" secret:@"1e92283336" size:@"m"];
    NSString *a1 = [NSString stringWithFormat:@"%@", url];
    STAssertTrue([a1 compare:@"http://farm1.staticflickr.com/2/1418878_1e92283336_m.jpg" options:NSCaseInsensitiveSearch] == NSOrderedSame, @"URL is incorrect!");
}


@end
