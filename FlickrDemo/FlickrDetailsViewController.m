//
//  DJFlickrDetailsViewController.m
//  FlickrDemo
//
//  Created by Daniel Johnston on 3/14/13.
//
//

#import "FlickrDetailsViewController.h"
#import "MKAnnotationView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface FlickrDetailsViewController ()
-(void)dismissViewController;
@end

@implementation FlickrDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[UIImage imageNamed:@"closeButton.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navBar.topItem.leftBarButtonItem = closeButton;
    
   
    
    NSString *photoUrl = [self.json valueForKey:@"url_z"];
    NSString *title = [self.json valueForKey:@"title"];
    NSString *ownername = [self.json valueForKey:@"ownername"];
    NSString *fullTitle = [NSString stringWithFormat:@"%@ - %@",ownername, title];
    NSString *description = [[self.json valueForKey:@"description"] valueForKey:@"_content"];
    
    self.navBar.topItem.title = fullTitle;
    self.descriptionLabel.text = description;
    
    __weak FlickrDetailsViewController *ref = self;
    [self.image setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"flickrPlaceHolder450x450.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [MBProgressHUD hideAllHUDsForView:ref.view animated:YES];
            
            [UIView animateWithDuration:0.10f animations:^{
                CGFloat width = image.size.width;
                CGFloat height = image.size.height;
                ref.imageWidthConstraint.constant = width;
                ref.imageHeightConstraint.constant = height;
                [ref.image layoutIfNeeded];
            } completion:nil];
        });
        
        
        if(SDImageCacheTypeNone == cacheType){
            [UIView transitionWithView:ref.image
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                ref.image.image = image;
                            } completion:nil];
        }
        
    }];
    
    
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    
    [self.gestureRecognizer setNumberOfTapsRequired:1];
    self.gestureRecognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view.window addGestureRecognizer:self.gestureRecognizer];
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        if(![self.view.window.gestureRecognizers containsObject:self.gestureRecognizer])
        {
            self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
            
            [self.gestureRecognizer setNumberOfTapsRequired:1];
            self.gestureRecognizer.cancelsTouchesInView = NO; 
            [self.view.window addGestureRecognizer:self.gestureRecognizer];
        }
    }
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil];
                
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            [self dismissViewController];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navBar.topItem.title = @"";
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = NO;
    
    self.image.image = [UIImage imageNamed:@"flickrPlaceHolder450x450.jpg"];
    
    CGFloat width = self.image.image.size.width;
    CGFloat height = self.image.image.size.height;
    self.imageWidthConstraint.constant = width;
    self.imageHeightConstraint.constant = height;
    [self.image layoutIfNeeded];

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.scrollView.subviews)
        contentRect = CGRectUnion(contentRect, view.frame);
    CGSize size = contentRect.size;
    self.scrollView.contentSize = CGSizeMake(0, size.height);
    
}

-(void)dismissViewController{
    // Remove the recognizer first so it's view.window is valid.
    [self.view.window removeGestureRecognizer:self.gestureRecognizer];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
