//
//  withRootView.h
//  photoPicker
//
//  Created by yongsik on 11. 7. 13..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
//#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@class EGOImageView;
@interface withRootView : UIViewController <CLLocationManagerDelegate,UIScrollViewDelegate>{
	UIView *header;
    UIView *frontView;
	UIView *hideView;
	UIButton *toggleButton;
    UIButton *backButton;
    UIButton *cameraButton;
    

	BOOL isUp;	
    CALayer *pulseLayer_;
    EGOImageView *profileView;
    NSTimer *timer;
    CLLocationManager *locationManager;
    CLLocation *newUserLocation;
    CATextLayer *nearCountlabel;
}

@property (nonatomic, retain) UIView *header;
@property (nonatomic, retain) UIView *frontView;
@property (nonatomic, retain) UIView *hideView;
@property (nonatomic, retain) UIButton *toggleButton;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIButton *cameraButton;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *newUserLocation;
@property (nonatomic, retain) CATextLayer *nearCountlabel;

- (void)swipedScreen:(UISwipeGestureRecognizer *)recognizer;
- (IBAction)moveToUpAndDown;
- (void)readyCAAni;
- (void)backAct;
-(void)initSview;
-(void)nearAsync;
-(void)onCamera;
-(void)removeView;

@end