//
//  DJUICollectionViewController.h
//  FlickrDemo
//
//  Created by Daniel Johnston on 3/14/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UICollectionViewWaterfallLayout.h"
#import "DJFlickrDataProvider.h"

@interface FlickrUICollectionViewController : UICollectionViewController <UICollectionViewDelegateWaterfallLayout, UITableViewDelegate>{
    int             _totalPages;
    int             _page;
    BOOL            _isLoadingNextPage;
    NSDictionary    *_params;
}


@property (strong) UIButton *topButton;
@property (strong) UIPopoverController *menuPopover;
@property (strong) CLLocationManager *locationManager;
@property (strong) DJFlickrDataProvider *flickrDataProvider;
@property (strong) NSMutableArray *dataSource;

@end
