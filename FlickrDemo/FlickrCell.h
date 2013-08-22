//
//  Cell.h
//  
//
//  Created by Daniel Johnston on 3/14/13.
//

#import <UIKit/UIKit.h>

@interface FlickrCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *ownerLabel;

@end
