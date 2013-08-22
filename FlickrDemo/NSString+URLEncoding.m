//
//  NSString+URLEncoding.m
//  FlickrDemo
//
//  Created by Daniel Johnston on 3/14/13.
//
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

-(NSString *)urlEscapeString{
    
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)self;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}
@end
