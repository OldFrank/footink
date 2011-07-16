//
//  MapAnnotation.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 22..
//  Copyright 2011 ag. All rights reserved.
//

#import "MapAnnotation.h"


@implementation MapAnnotation


@synthesize coordinate     = _coordinate;
@synthesize annotationType = _annotationType;
@synthesize userData       = _userData;
@synthesize url            = _url;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate 
		  annotationType:(MapAnnotationType) annotationType
				   title:(NSString*)title
{
	self = [super init];
	_coordinate = coordinate;
	_title      = [title retain];
	_annotationType = annotationType;
	
	return self;
}

- (NSString *)title
{
	return _title;
}

- (NSString *)subtitle
{
	NSString* subtitle = nil;
	
	if(_annotationType == MapAnnotationTypeStart || 
       _annotationType == MapAnnotationTypeEnd)
	{
		subtitle = [NSString stringWithFormat:@"%lf, %lf", _coordinate.latitude, _coordinate.longitude];
	}
	
	return subtitle;
}

-(void) dealloc
{
	[_title    release];
	[_userData release];
	[_url      release];
	
	[super dealloc];
}

@end
