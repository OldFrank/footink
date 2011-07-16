//
//  tripMapViewController.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@class DetailsViewController;

@interface tripMapViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate>{
	//MapViewWithLines* _mapView;
	MKMapView* _mapView;
    NSMutableDictionary* _routeView;
	//tripMapRouteViewController* _routeView;
    
    DetailsViewController* _detailsVC;
    NSMutableArray *jsonArray;
    CLLocationManager *locationManager;
}

-(void) showWebViewForURL:(NSURL*) url;

@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray* jsonArray;
@end