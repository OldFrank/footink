//
//  tripMapRouteViewController.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class RouteViewInternal;
@interface tripMapRouteViewController : MKAnnotationView 
{
	MKMapView* _mapView;
	
	RouteViewInternal* _internalRouteView;
}
-(void) regionChanged;


@property (nonatomic, retain) MKMapView* mapView;


@end
