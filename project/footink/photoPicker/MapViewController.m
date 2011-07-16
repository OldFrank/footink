//
//  MapViewController.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import "MapViewController.h"
#import "SpotListViewController.h"
#import "JSON.h"


@implementation MapViewController

@synthesize mapView, brancheNameLabel, addressLabel, phoneNoLabel,locationManager,jsonDetailArray,reference;


#pragma mark -
#pragma mark 전화걸기

- (IBAction)sendCall:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"전화번호" 
						  message:self.phoneNoLabel.text 
						  delegate:self 
						  cancelButtonTitle:@"취소" 
						  otherButtonTitles:@"통화", nil]; 
	[alert show]; 
	[alert release];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		NSLog(@"AlertView button index: %d", buttonIndex);
		
		NSString *phoneURL = @"tel:%@";
		phoneURL = [NSString stringWithFormat:phoneURL, self.phoneNoLabel.text];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
		[phoneURL release];
	}
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"위치찾기";
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    
    self.mapView = [[[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200.0)] autorelease];
	[self.view addSubview:self.mapView];
    
	[self.mapView setDelegate:self];
    
    self.mapView.mapType = MKMapTypeStandard;
	[self.mapView setShowsUserLocation:YES];
    [self.mapView.userLocation setTitle:@"Here I am"];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	    
    timer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(jsonDetailParse) userInfo:NO repeats:NO]retain];
}
-(void)jsonDetailParse{
    NSURL *jsonDetailURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://footink.com/user/spotDetail?refr=%@",reference, nil]];
    NSString *jsonDetailData = [[NSString alloc] initWithContentsOfURL:jsonDetailURL];
    
    NSDictionary *spotDetail=(NSDictionary *)[jsonDetailData JSONValue];
    
    Branche *newBranche = [[Branche alloc] init];
    newBranche.name = [spotDetail objectForKey:@"name"];
    newBranche.address = [spotDetail objectForKey:@"address"];
    newBranche.phoneNo = [spotDetail objectForKey:@"phone"];
    newBranche.latitude = [spotDetail objectForKey:@"latitude"];
    newBranche.longitude = [spotDetail objectForKey:@"longitude"];
    
    self.brancheNameLabel.text=newBranche.name;
    self.addressLabel.text=newBranche.address;
    self.phoneNoLabel.text=newBranche.phoneNo;
     
    CLLocationCoordinate2D mapCenter;
	mapCenter.latitude = [newBranche.latitude doubleValue];
	mapCenter.longitude = [newBranche.longitude doubleValue];
	
	//NSLog(@"%@ 좌표: %f, %f", self.branche.name, mapCenter.latitude, mapCenter.longitude);
    
    
    
	MKCoordinateSpan mapSpan;
	mapSpan.latitudeDelta = 0.005;
	mapSpan.longitudeDelta = 0.005;
	
	MKCoordinateRegion mapRegion;
	mapRegion.center = mapCenter;
	mapRegion.span = mapSpan;
	
    
	self.mapView.region = mapRegion;
	[self.mapView addAnnotation:newBranche];
    [self.jsonDetailArray addObject:spotDetail];
    

    
    //NSLog(@"name %@",self.jsonDetailArray);
}
-(void)viewWillDisappear:(BOOL)animated{

}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
//위치 정보 가져오기가 실패한 경우 실행되는 메소드
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location update Failed");
    //에러 처리
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{ 
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1000, 1000);
    [self.mapView setRegion:viewRegion animated:YES];
    
    NSLog(@"newlocation %@",newLocation);
    [locationManager stopUpdatingLocation];
    
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void)dealloc {
    [jsonDetailArray release];
    [locationManager release];
	[brancheNameLabel release];
	[addressLabel release];
	[phoneNoLabel release];
    [super dealloc];
}


@end
