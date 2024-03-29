//
//  RouteAnnotation.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 21..
//  Copyright 2011 ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// annotation that is used to tell the map about a route. 
@interface RouteAnnotation : NSObject <MKAnnotation>
{
	// points that make up the route. 
	NSMutableArray* _points; 
	
	// computed span of the route
	MKCoordinateSpan _span;
	
	// computed center of the route. 
	CLLocationCoordinate2D _center;	
	
	// color of the line that will be rendered. 
	UIColor* _lineColor;
	
	// id of the route we can use for indexing. 
	NSString* _routeID;
}

// initialize with an array of points representing the route. 
-(id) initWithPoints:(NSArray*) points;

@property (readonly) MKCoordinateRegion region;
@property (nonatomic, retain) UIColor* lineColor;
@property (nonatomic, retain) NSMutableArray* points;
@property (nonatomic, retain) NSString* routeID;

@end