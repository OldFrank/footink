//
//  FindMeViewController.h
//  FindBranche
//
//  Created by 
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FindMeViewController : UIViewController <CLLocationManagerDelegate, MKReverseGeocoderDelegate, MKMapViewDelegate> {
	MKMapView *mapView;
	CLLocationManager *locationManager;
	NSMutableArray *brancheList;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *brancheList;

- (BOOL)matchString:(NSString *)theString withString:(NSString*)withString;
- (void)loadData:(CLLocation *)userLocation;
- (BOOL)calcDistance:(CLLocation *)userLocation placeLocation:(CLLocation *)location;
- (void)onAddBranche;

@end
