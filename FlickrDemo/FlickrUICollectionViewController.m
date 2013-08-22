//
//  DJUICollectionViewController.m
//  FlickrDemo
//
//  Created by Daniel Johnston on 3/14/13.
//
//

#import <CoreLocation/CoreLocation.h>
#import "FlickrUICollectionViewController.h"
#import "MBProgressHUD.h"
#import "DJAppDelegate.h"
#import "FlickrCell.h"
#import "MKAnnotationView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "Promise.h"
#import "UICollectionViewWaterfallLayout.h"
#import "FlickrDetailsViewController.h"
#import "DJSettingsMenuViewViewController.h"

NSString *kDetailedViewControllerID = @"DetailView";    // view controller storyboard id
NSString *kCellID = @"flickrCell";
#define CELL_WIDTH 180

@interface FlickrUICollectionViewController ()
-(void)nextPage;
-(void)reloadData;
-(void)popupTagsMenu:(id)sender;
-(NSString *)deviceLocation;
@end

@implementation FlickrUICollectionViewController


-(void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    // allows you to create a new customized button
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallLogo.png"]];
    
    self.topButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    self.topButton.frame = CGRectMake(0, 0, 200, 30);
    [self.topButton setTitle:@" All Images" forState:UIControlStateNormal];
    [self.topButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [self.topButton addTarget:self action:@selector(popupTagsMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *changeButton = [[UIBarButtonItem alloc] initWithCustomView:self.topButton];
    
    self.navigationItem.leftBarButtonItem = changeButton;
    //calculate layout
    UICollectionViewWaterfallLayout *layout = [[UICollectionViewWaterfallLayout alloc] init];
    layout.itemWidth = CELL_WIDTH;
    layout.columnCount = self.collectionView.frame.size.width / CELL_WIDTH;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.delegate = self;
    [self.collectionView setCollectionViewLayout:layout];
}

-(void)loadView{
    [super loadView];
    
    _totalPages = 99;
    _isLoadingNextPage = NO;
    _page = 0;
    _params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", _page], @"page",
               @"wedding",@"tags", @"title, owner_name, description, url_t, url_q, url_z", @"extras", nil];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone; 
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; 
    [self.locationManager startUpdatingLocation];
    self.dataSource = [NSMutableArray arrayWithCapacity:500];
    
    DJAppDelegate *delegate = (DJAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.flickrDataProvider = delegate.flickrDataProvider;
    
    [self nextPage];
    
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)view{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    if(self.dataSource){
        return [self.dataSource count];
    }else{
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    FlickrCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    NSDictionary *json = [self.dataSource objectAtIndex:indexPath.row];
    
    NSString *title = [json valueForKey:@"title"];
    NSString *owner = [json valueForKey:@"ownername"];
    
    cell.titleLabel.text = title;
    cell.ownerLabel.text = owner;
    
    [cell.image setImage:nil];
    
    __weak FlickrCell *refCell = cell;
    NSString *photoUrl = [json valueForKey:@"url_q"];
    [cell.image setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"flickrPlaceHolder150x150.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
        if(SDImageCacheTypeNone == cacheType){
            [UIView transitionWithView:refCell.image
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                refCell.image.image = image;
                            } completion:nil];
        }
        
    }];
    
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewWaterfallLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *json = [self.dataSource objectAtIndex:indexPath.row];
    int sizeLabel1Font = 15;
    int sizeLabel2Font = 12;
    
    int padding = 15;
    int maxWidthOfLabel = 160;
    
    NSString *strLabel1 = [json valueForKey:@"title"];
    NSString *strLabel2 = [json valueForKey:@"ownername"];
    
    CGSize sizeLabel1 = [strLabel1 sizeWithFont:[UIFont systemFontOfSize:sizeLabel1Font] constrainedToSize:CGSizeMake(maxWidthOfLabel, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize sizeLabel2 = [strLabel2 sizeWithFont:[UIFont systemFontOfSize:sizeLabel2Font] constrainedToSize:CGSizeMake(maxWidthOfLabel, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    CGSize sizeOfImage = CGSizeMake(160, 160);
    
    //return sizeLabel1.height+sizeLabel2.height+sizeOfImage.height+2*padding;
    CGFloat height = sizeLabel1.height + sizeLabel2.height + sizeOfImage.height + 2 * padding;
    return height;
}

// the user tapped a collection item, load and set the image on the detail view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        NSDictionary *json = [self.dataSource objectAtIndex:selectedIndexPath.row];
        FlickrDetailsViewController *detailViewController = [segue destinationViewController];
        detailViewController.json = json;
    }
}

-(void)nextPage{
    
    _page ++;
    if(_page > _totalPages)
        return;
    
    NSMutableDictionary *mergedParams = [_params mutableCopy];
    NSDictionary *pageParam = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", _page], @"page", nil];
    [mergedParams addEntriesFromDictionary:pageParam];
    
    _isLoadingNextPage = YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = NO;
    
    
    Promise *flickrPromise = [self.flickrDataProvider flickrRequestWithMethod:@"flickr.photos.search" params:mergedParams];
    
    [flickrPromise doneWithData:^(id data) {
        _isLoadingNextPage = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *photos = [[data valueForKey:@"photos"] valueForKey:@"photo"];
            _totalPages = [[[data valueForKey:@"photos"] valueForKey:@"pages"] intValue];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if([photos count] == 0){
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"Couldn't locate any Flickr photos!";
                hud.margin = 10.f;
                hud.yOffset = 150.f;
                hud.removeFromSuperViewOnHide = YES;
                
                [hud hide:YES afterDelay:5];

            }
            
            [self.dataSource addObjectsFromArray:photos];
            [self reloadData];
            if(_page == 1){
                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.collectionView scrollToItemAtIndexPath:scrollIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            }
        });
    }];
    
    [flickrPromise failWithData:^(id data) {
        _isLoadingNextPage = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString stringWithFormat:@"Failed loading photos from Flickr for page #%d",_page];
            hud.margin = 10.f;
            hud.yOffset = 150.f;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:5];
            
        });
        
    }];
}

-(void)popupTagsMenu:(id)sender{
    
    DJSettingsMenuViewViewController *settingsMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DJSettingsMenuViewViewController"];
    settingsMenuViewController.contentSizeForViewInPopover = CGSizeMake(350, 150);
    settingsMenuViewController.tableView.delegate = self;
    
    self.menuPopover = [[UIPopoverController alloc] initWithContentViewController:settingsMenuViewController];
    UIButton *senderButton = (UIButton *)sender;
    
    [self.menuPopover presentPopoverFromRect:senderButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height && !_isLoadingNextPage) {
        [self nextPage];
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    //[self.collectionView performBatchUpdates:nil completion:nil];
    [self reloadData];
}


-(void)reloadData{
    [self.collectionView reloadData];
    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (NSString *)deviceLocation {
    NSString *theLocation = [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    return theLocation;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        [self.topButton setTitle:@" All Images" forState:UIControlStateNormal];
        _page = 0;
        _params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", _page], @"page",
                   @"wedding",@"tags", @"title, owner_name, description, url_t, url_q, url_z", @"extras", nil];
    }else{
        [self.topButton setTitle:@" Nearby Images" forState:UIControlStateNormal];

        NSString *lat = [NSString stringWithFormat:@"%g",self.locationManager.location.coordinate.latitude];
        NSString *lon = [NSString stringWithFormat:@"%g",self.locationManager.location.coordinate.longitude];
        
        _page = 0;
        _params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", _page], @"page",
                   @"wedding",@"tags", @"title, owner_name, description, url_t, url_q, url_z", @"extras", lat, @"lat", lon, @"lon", nil];
    }
    
    [self.dataSource removeAllObjects];
    [self nextPage];
    [self.menuPopover dismissPopoverAnimated:YES];
}




@end
