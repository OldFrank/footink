//
//  MapLocation.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import "MapLocation.h"
#import <MapKit/MapKit.h>


@implementation MapLocation

@synthesize streetAddress;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize coordinate;


#pragma mark -

- (NSString *)title {
    return @"현재 위치!";
}


- (NSString *)subtitle {
    NSMutableString *retVal = [NSMutableString string];
	
	if (zip) 
		[retVal appendString:zip];
	if (zip)
		[retVal appendString:@", "];
	if (state)
        [retVal appendString:state];
	if (state)
        [retVal appendString:@" • "];
	if (city)
        [retVal appendString:city];
	if (city)
        [retVal appendString:@" • "];
	if (streetAddress)
        [retVal appendString:streetAddress]; 
    
    return retVal;
}


#pragma mark -

- (void)dealloc {
    [streetAddress release];
    [city release];
    [state release];
    [zip release];
    [super dealloc];
}


#pragma mark -
#pragma mark NSCoding Methods

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject: [self streetAddress] forKey: @"streetAddress"];
    [encoder encodeObject: [self city] forKey: @"city"];
    [encoder encodeObject: [self state] forKey: @"state"];
    [encoder encodeObject: [self zip] forKey: @"zip"];
}


- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        [self setStreetAddress: [decoder decodeObjectForKey: @"streetAddress"]];
        [self setCity: [decoder decodeObjectForKey: @"city"]];
        [self setState: [decoder decodeObjectForKey: @"state"]];
        [self setZip: [decoder decodeObjectForKey: @"zip"]];
    }
    return self;
}

@end
