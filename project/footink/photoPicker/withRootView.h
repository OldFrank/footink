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
#import "Badges.h"
#import "EGOImageView.h"

@class Badges;
@class EGOImageView;
@interface withRootView : UIViewController <UINavigationControllerDelegate,CLLocationManagerDelegate,UIScrollViewDelegate,HttpWrapperDelegate>{

    UIView *frontView;
	UIView *hideView;
    UIView *newTabBar;
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
    NSTimer *currentTime;
    
    UILabel *yearLabel;
    UILabel *monthLabel;
    UILabel *timeLabel;
    
    NSMutableArray *jsonArray;
    NSMutableArray *jsonNearArray;
    UIImageView *gimageView;
    HttpWrapper *progressbar;
    
   EGOImageView *recentImageView;
    Badges *nearBadge;
    BOOL CLCHK;
    
    UIScrollView *nowScroll;
    UIScrollView *recentGroup;
    
    int nowScrollImageCount;
}

@property (nonatomic, retain) UIScrollView *recentGroup;
@property (nonatomic, retain) UIScrollView *nowScroll;
@property (nonatomic, retain) UIView *frontView;
@property (nonatomic, retain) UIView *hideView;
@property (nonatomic, retain) UIView *newTabBar;
@property (nonatomic, retain) UIButton *toggleButton;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIButton *cameraButton;
@property (nonatomic, retain) UILabel *yearLabel;
@property (nonatomic, retain) UILabel *monthLabel;
@property (nonatomic, retain) UILabel *timeLabel;

@property (nonatomic, retain) UIImageView *gimageView;


@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *newUserLocation;
@property (nonatomic, retain) CATextLayer *nearCountlabel;
@property (nonatomic, retain) NSMutableArray *jsonArray;
@property (nonatomic, retain) NSMutableArray *jsonNearArray;

-(void)swipedScreen:(UISwipeGestureRecognizer *)recognizer;
-(IBAction)moveToUpAndDown;
-(void)readyCAAni;
-(void)backAct;
-(void)initSview;
-(BOOL)nearAsync;
-(void)onCamera;
-(void)removeView;

-(void)withTabBar;
-(void)hideTabBar;
-(void)withGroupTabBar;
-(void)networkError;
- (int)checkNetwork;
-(void)rectImages;
-(void)groupPush:(id)sender;
- (void)nowPhotoScroll;

@end