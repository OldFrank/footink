//
//  BrancheAnnotation.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import "BrancheAnnotation.h"


@implementation BrancheAnnotation

@synthesize coordinate, title, subtitle;

- (void) dealloc {
	[title release];
	[subtitle release];
	[super dealloc];
}

+ (BrancheAnnotation *)createAnnotation:(CLLocationCoordinate2D)theCoordinate {
	BrancheAnnotation *brancheAnnotation = [BrancheAnnotation alloc];
	brancheAnnotation.coordinate = theCoordinate;
	return [brancheAnnotation autorelease];
}


@end
