//
//  tripMapRouteViewController.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import "tripMapRouteViewController.h"
#import "RouteAnnotation.h"

@interface RouteViewInternal : UIView
{
	// route view which added this as a subview. 
	tripMapRouteViewController* _routeView;
}
@property (nonatomic, retain) tripMapRouteViewController* routeView;
@end

@implementation RouteViewInternal
@synthesize routeView = _routeView;

-(void) drawRect:(CGRect) rect
{
	RouteAnnotation* routeAnnotation = (RouteAnnotation*)self.routeView.annotation;
	
	// only draw our lines if we're not int he moddie of a transition and we 
	// acutally have some points to draw. 
	if(!self.hidden && nil != routeAnnotation.points && routeAnnotation.points.count > 0)
	{
		CGContextRef context = UIGraphicsGetCurrentContext(); 
		
		if(nil == routeAnnotation.lineColor)
			routeAnnotation.lineColor = [UIColor blueColor]; // setting the property instead of the member variable will automatically reatin it.
		
		CGContextSetStrokeColorWithColor(context, routeAnnotation.lineColor.CGColor);
		CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
		
		// Draw them with a 2.0 stroke width so they are a bit more visible.
		CGContextSetLineWidth(context, 2.0);
		
		for(int idx = 0; idx < routeAnnotation.points.count; idx++)
		{
			CLLocation* location = [routeAnnotation.points objectAtIndex:idx];
			CGPoint point = [self.routeView.mapView convertCoordinate:location.coordinate toPointToView:self];
			
			NSLog(@"Point: %lf, %lf", point.x, point.y);
			
			if(idx == 0)
			{
				// move to the first point
				CGContextMoveToPoint(context, point.x, point.y);
			}
			else
			{
				CGContextAddLineToPoint(context, point.x, point.y);
			}
		}
		
		CGContextStrokePath(context);
		
		
		// debug. Draw the line around our view. 
		/*
         CGContextMoveToPoint(context, 0, 0);
         CGContextAddLineToPoint(context, 0, self.frame.size.height);
         CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
         CGContextAddLineToPoint(context, self.frame.size.width, 0);
         CGContextAddLineToPoint(context, 0, 0);
         CGContextStrokePath(context);
         */
	}
	
    
}

-(id) init
{
	self = [super init];
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = NO;
	
	return self;
}

-(void) dealloc
{
	self.routeView = nil;
	
	[super dealloc];
}
@end


@implementation tripMapRouteViewController
@synthesize mapView = _mapView;

- (id)initWithFrame:(CGRect)frame {
    NSLog(@"route initWithFrame");
    if (self == [super initWithFrame:frame]) {
        
		self.backgroundColor = [UIColor clearColor];
        
		// do not clip the bounds. We need the CSRouteViewInternal to be able to render the route, regardless of where the
		// actual annotation view is displayed. 
		self.clipsToBounds = NO;
		
		// create the internal route view that does the rendering of the route. 
		_internalRouteView = [[RouteViewInternal alloc] init];
		_internalRouteView.routeView = self;
		
		[self addSubview:_internalRouteView];
    }
    return self;
}

-(void) setMapView:(MKMapView*) mapView
{
    NSLog(@"setMapView");
	[_mapView release];
	_mapView = [mapView retain];
	
	[self regionChanged];
}
-(void) regionChanged
{
	NSLog(@"Region Changed");
	
	// move the internal route view. 
	CGPoint origin = CGPointMake(0, 0);
	origin = [_mapView convertPoint:origin toView:self];
	
	_internalRouteView.frame = CGRectMake(origin.x, origin.y, _mapView.frame.size.width, _mapView.frame.size.height);
	[_internalRouteView setNeedsDisplay];
	
}

- (void)dealloc 
{
	[_mapView release];
	[_internalRouteView release];
	
    [super dealloc];
}


@end

