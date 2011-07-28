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
#import "HttpWrapper.h"

@class EGOImageView;
@interface withRootView : UIViewController <UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,UIScrollViewDelegate,HttpWrapperDelegate>{

    UIView *frontView;
	UIView *hideView;
    UIView *newTabBar;
	UIButton *toggleButton;
    UIButton *backButton;
    UIButton *cameraButton;
    UITableView *recentGroup;

	BOOL isUp;	
    CALayer *pulseLayer_;
    EGOImageView *profileView;
    NSTimer *timer;
    CLLocationManager *locationManager;
    CLLocation *newUserLocation;
    CATextLayer *nearCountlabel;
    NSTimer *currentTime;
    
    UILabel *yearLabel;
    UILabel *monthLabel;
    UILabel *timeLabel;
    
    NSMutableArray *jsonArray;
    UIImageView *gimageView;
    HttpWrapper *progressbar;
    
    
    BOOL CLCHK;
}


@property (nonatomic, retain) UIView *frontView;
@property (nonatomic, retain) UIView *hideView;
@property (nonatomic, retain) UIView *newTabBar;
@property (nonatomic, retain) UIButton *toggleButton;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIButton *cameraButton;
@property (nonatomic, retain) UILabel *yearLabel;
@property (nonatomic, retain) UILabel *monthLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UITableView *recentGroup;

@property (nonatomic, retain) UIImageView *gimageView;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *newUserLocation;
@property (nonatomic, retain) CATextLayer *nearCountlabel;
@property (nonatomic, retain) NSMutableArray *jsonArray;

- (void)swipedScreen:(UISwipeGestureRecognizer *)recognizer;
- (IBAction)moveToUpAndDown;
- (void)readyCAAni;
- (void)backAct;
-(void)initSview;
-(void)nearAsync;
-(void)onCamera;
-(void)removeView;
-(void)groupPush;


@end