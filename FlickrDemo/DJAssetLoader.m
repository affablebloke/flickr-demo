//
//  AssetLoader.m
//
//  Created by Daniel Johnston on 3/14/13.
//

#import "DJAssetLoader.h"
#import "AFNetworking.h"
#import "Deferred.h"
#import "Promise.h"


@interface DJAssetLoader()
-(void)loadNextAssetWithDeferred:(Deferred *)dfd operation:(AFHTTPRequestOperation *)operation;
@end

@interface WebAssetPair : NSObject
@property Deferred                  *dfd;
@property AFHTTPRequestOperation    *operation;

+(id)WebAssetPairWithDeferred:(Deferred *)dfd operation:(AFHTTPRequestOperation *)operation;

@end

@implementation WebAssetPair

+(id)WebAssetPairWithDeferred:(Deferred *)dfd operation:(AFHTTPRequestOperation *)operation{
    WebAssetPair *pair = [[WebAssetPair alloc] init];
    pair.dfd = dfd;
    pair.operation = operation;
    return pair;
}

@end

@implementation DJAssetLoader

-(id)init{
    if (self = [super init])
    {
        
        [[NSURLCache sharedURLCache] setDiskCapacity:1024 * 1024 * 1024];
        [[NSURLCache sharedURLCache] setMemoryCapacity:1024 * 1024 * 64];
        _urlConnectionQueue = [[NSOperationQueue alloc] init];
        _lockQueue = dispatch_queue_create("com.zombo.assetloaderlock", NULL);
        _coreDataQueue = dispatch_queue_create("com.zombo.coredata", NULL);
        _activeAssetDeferreds = [NSMutableArray array];
        _assetLoadingQueue = [NSMutableArray array];
        _currentConnections = 0;
        self.maxConcurrentConnections = 30;
        
        // Enable Activity Indicator Spinner
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

-(id)initWithMaxConcurrentConnections:(int)maxConnections{
    if (self = [self init])
    {
        self.maxConcurrentConnections = maxConnections;
    }
    return self;
}

+(id)sharedAssetLoader{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(Promise *)loadWebAsset:(NSMutableURLRequest *)request{
    
    Deferred *dfd = [DeferredAPI deferred];
    Promise *promise = [dfd promise];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __block DJAssetLoader *ref = self;
    
    [promise always:^{
        dispatch_sync(ref->_lockQueue, ^{
            ref->_currentConnections = ref->_currentConnections - 1;
            if([ref->_assetLoadingQueue count] > 0){
                WebAssetPair *pair = [ref->_assetLoadingQueue lastObject];
                if(pair != nil)
                    [self loadNextAssetWithDeferred:pair.dfd operation:pair.operation];
                if([ref->_assetLoadingQueue count] > 0){
                    [ref->_assetLoadingQueue removeLastObject];
                }
            }
        });
    }];
    
    
    if(_currentConnections >= self.maxConcurrentConnections){
        //add to queue
        [_assetLoadingQueue addObject:[WebAssetPair WebAssetPairWithDeferred:dfd operation:operation]];
        return promise;
    }
    
    [self loadNextAssetWithDeferred:dfd operation:operation];
    return promise;
}


-(void)loadNextAssetWithDeferred:(Deferred *)dfd operation:(AFHTTPRequestOperation *)operation{
    [_activeAssetDeferreds addObject:dfd];
    _currentConnections = _currentConnections + 1;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(_coreDataQueue, ^{
            [dfd resolveWith:responseObject];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(_coreDataQueue, ^{
            [dfd rejectWith:error];
        });
    }];
    
    [operation start];
}

-(void)setupCache:(NSUInteger)diskMB memoryCacheMB:(NSUInteger)memMB{
    [[NSURLCache sharedURLCache] setDiskCapacity:1024 * 1024 * diskMB];
    [[NSURLCache sharedURLCache] setMemoryCapacity:1024 * 1024 * memMB];
}

-(void)cancelAllRequests{
    dispatch_sync(_lockQueue, ^{
        for (Deferred *dfd in _activeAssetDeferreds) {
            [dfd detach];
        }
        for (WebAssetPair *pair in _assetLoadingQueue) {
            [pair.dfd detach];
            [pair.operation cancel];
        }
        [_activeAssetDeferreds removeAllObjects];
        [_assetLoadingQueue removeAllObjects];
        [_urlConnectionQueue cancelAllOperations];
        _currentConnections = 0;
    });
}

-(void)clearCache{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


@end
