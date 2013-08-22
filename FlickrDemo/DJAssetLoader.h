//
//  AssetLoader.h
//
//  Created by Daniel Johnston on 3/14/13.
//

#import <Foundation/Foundation.h>
#import "Promise.h"


@interface DJAssetLoader : NSObject{
    __block int                     _currentConnections;
    __block NSMutableArray          *_assetLoadingQueue;
    __block NSMutableArray          *_activeAssetDeferreds;
    NSOperationQueue                *_urlConnectionQueue;
    dispatch_queue_t                _lockQueue;
    dispatch_queue_t                _coreDataQueue;

}

@property __block int maxConcurrentConnections;

+(id)sharedAssetLoader;
-(Promise *)loadWebAsset:(NSMutableURLRequest *)request;
-(void)cancelAllRequests;
-(void)clearCache;
-(void)setupCache:(NSUInteger)diskMB memoryCacheMB:(NSUInteger)memMB;

@end
