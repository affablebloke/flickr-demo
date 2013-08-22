//
//  NSDictionary+URLQueryString.m
//  FlickrDemo
//
//  Created by Daniel Johnston on 3/14/13.
//
//

#import "NSDictionary+URLQueryString.h"
#import "NSString+URLEncoding.h"

@implementation NSDictionary (URLQueryString)

-(NSString *)urlQueryString {
    NSMutableArray *components = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        //Very hacky, quick and dirty
        NSString *encodedKey = [[NSString stringWithFormat:@"%@",key] urlEscapeString];
        NSString *encodedValue = [[NSString stringWithFormat:@"%@",value] urlEscapeString];
        
        NSString *component = [NSString stringWithFormat: @"%@=%@",encodedKey, encodedValue];
        [components addObject: component];
    }
    return [NSString stringWithFormat:@"?%@",[components componentsJoinedByString: @"&"]];
}

@end
