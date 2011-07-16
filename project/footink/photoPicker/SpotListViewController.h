//
//  SpotListViewController.h
//  photoPicker
//
//  Created by yongsik on 11. 6. 27..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Branche.h"
#import "EGORefreshTableHeaderView.h"
#import "SlidingTabView.h"
#import "UIImageView+AsyncAndCache.h"

#define kPageUnit 10

@interface SpotListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,CLLocationManagerDelegate,EGORefreshTableHeaderDelegate,UINavigationControllerDelegate,SlidingTabViewDelegate,MKReverseGeocoderDelegate>{
	
    UITableView *spotTable;
    NSMutableArray *brancheList;
	NSString *searchKeyword;
    NSMutableArray *jsonArray;
    
    UISearchBar *fSearch;
    int selectedSegment;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    NSURLConnection*			urlConnection;
    long						Total_FileSize;
	long                        CurLength;
    
    CLLocationManager *locationManager;
    
    NSMutableData *returnData;
    NSTimer *timer;
    UIAlertView *alert;
    
    CLLocation *newUserLocation;
    UILabel *curGeoLabel;
    NSUInteger pageNumber;
    BOOL toggleShowing;
    
}
@property (nonatomic, retain) UITableView *spotTable;
@property (nonatomic, retain) NSMutableArray *brancheList;
@property (nonatomic, retain) NSString *searchKeyword;
@property (nonatomic, retain) NSMutableArray *jsonArray;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *newUserLocation;
@property (nonatomic, retain) UILabel *curGeoLabel;


- (BOOL)matchString:(NSString *)theString withString:(NSString*)withString;

- (CGFloat)calcDistance:(CLLocation *)userLocation placeLocation:(CLLocation *)location;

- (void)jsonLoad:(NSString *)types;
- (void)selTimer:(NSString *)type;
- (void)showAlert:(NSString *)msg;
- (int)checkNetwork;
- (void)loadingAlert;
- (void)reloadTableViewDataSource;

- (void)loadingIndicator;


@end

