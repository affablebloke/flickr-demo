//
//  DJAppDelegate.h
//  FlickrDemo
//
//  Created by Daniel Johnston on 3/14/13.
//

#import <UIKit/UIKit.h>
#import "DJFlickrDataProvider.h"

@interface DJAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(strong, nonatomic) DJFlickrDataProvider *flickrDataProvider;

@end
