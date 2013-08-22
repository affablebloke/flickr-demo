//
//  Cell.m
//  
//
//  Created by Daniel Johnston on 3/14/13.
//

#import <QuartzCore/QuartzCore.h>
#import "FlickrCell.h"


@implementation FlickrCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.layer.shouldRasterize = YES;
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //self.layer.borderColor = [UIColor grayColor].CGColor;
    //[self.layer setBorderWidth:1.0f];
    //[self.layer setCornerRadius:7.5f];
    [self.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [self.layer setShadowRadius:3.0];
    [self.layer setShadowOpacity:0.65];
    [self.layer setMasksToBounds:NO];
    
    
    self.layer.shouldRasterize = YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
       
    }
    self.layer.shouldRasterize = YES;
    return self;
}

@end
