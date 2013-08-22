//
//  DJFlickrDetailsViewController.h
//  FlickrDemo
//
//  Created by Daniel Johnston on 3/14/13.
//
//

#import <UIKit/UIKit.h>

@interface FlickrDetailsViewController : UIViewController


@property (copy) NSDictionary *json;
@property (strong, nonatomic) UITapGestureRecognizer *gestureRecognizer;

@property (weak) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (weak) IBOutlet UILabel *descriptionLabel;
@property (weak) IBOutlet UINavigationBar *navBar;
@property (weak) IBOutlet NSLayoutConstraint *imageWidthConstraint;
@property (weak) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@end
