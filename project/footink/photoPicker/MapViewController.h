//
//  MapViewController.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Branche.h"


@interface MapViewController : UIViewController <UIAlertViewDelegate,UINavigationControllerDelegate,MKMapViewDelegate,CLLocationManagerDelegate> {
	//Branche *branche;
	MKMapView *mapView;
	UILabel *brancheNameLabel;
	UILabel *addressLabel;
	UILabel *phoneNoLabel;
    NSMutableArray *jsonDetailArray;
    CLLocationManager *locationManager;
    NSString *reference;
    NSTimer *timer;
}

//@property (nonatomic, retain) Branche *branche;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UILabel *brancheNameLabel;
@property (nonatomic, retain) UILabel *addressLabel;
@property (nonatomic, retain) UILabel *phoneNoLabel;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *jsonDetailArray;
@property (nonatomic, copy) NSString *reference;

- (IBAction)sendCall:(id)sender;

@end
