//
//  tripMapViewController.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "tripMapViewController.h"
#import "tripMapRouteViewController.h"
#import "JSON.h"
#import "RouteAnnotation.h"
#import "MapAnnotation.h"
#import "ImageAnnotation.h"
#import "DetailsViewController.h"

@implementation tripMapViewController

@synthesize mapView   = _mapView;
@synthesize jsonArray,locationManager;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (id) init{
    self=[super init];
    if(self!=nil){
        self.title=@"Map";
        
        //UIImage* anImage = [UIImage imageNamed:@"MyViewControllerImage.png"];
        //UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:anImage tag:0];
        //self.tabBarItem = theItem;
        //[theItem release];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// dictionary to keep track of route views that get generated. 
	_routeView = [[NSMutableDictionary alloc] init];
	//
	// load the points from our local resource
	//
    NSURL *csvURL = [NSURL URLWithString:@"http://footink.com/user/csv"];
    
    NSString *csvData = [[NSString alloc] initWithContentsOfURL:csvURL];
    NSLog(@"-----Load--json");
    self.jsonArray = [csvData JSONValue]; 
    
    
    NSMutableArray* points = [[NSMutableArray alloc] initWithCapacity:self.jsonArray.count];
    NSLog(@"points %i",self.jsonArray.count);


        // converting the json data into an array
        //NSLog(@"%@",jsonLData);
        
        //NSString* filePath = [[NSBundle mainBundle] pathForResource:@"route" ofType:@"csv"];
        //NSString* fileContents = [NSString stringWithContentsOfFile:filePath];
        //NSArray* pointStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //NSArray* pointStrings = [csvData componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        
                      
        for(int idx = 0; idx < self.jsonArray.count; idx++)
        {
            NSDictionary *latLonArr = (NSDictionary *)[self.jsonArray objectAtIndex:idx];

            NSLog(@"%@",[self.jsonArray objectAtIndex:idx]);
            NSLog(@"%@",[latLonArr objectForKey:@"lat"]);
            CLLocationDegrees latitude  = [[latLonArr objectForKey:@"lat"] doubleValue];
            CLLocationDegrees longitude = [[latLonArr objectForKey:@"lon"] doubleValue];
            
            CLLocation* currentLocation = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
                 [points addObject:currentLocation];
        }
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:_mapView];
    
	[_mapView setDelegate:self];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
 
    

    
    [_mapView setShowsUserLocation:YES];
        //[csvData release];
       
    
    
    // CREATE THE ANNOTATIONS AND ADD THEM TO THE MAP
	
	// first create the route annotation, so it does not draw on top of the other annotations. 
	RouteAnnotation* routeAnnotation = [[[RouteAnnotation alloc] initWithPoints:points] autorelease];
	[_mapView addAnnotation:routeAnnotation];
    
	
	// create the rest of the annotations
	MapAnnotation* annotation = nil;
	
	// create the start annotation and add it to the array
	annotation = [[[MapAnnotation alloc] initWithCoordinate:[[points objectAtIndex:0] coordinate]
											   annotationType:MapAnnotationTypeStart
														title:@"End Point"] autorelease];
	[_mapView addAnnotation:annotation];
	

	// create the end annotation and add it to the array
	annotation = [[[MapAnnotation alloc] initWithCoordinate:[[points objectAtIndex:points.count - 1] coordinate]
											   annotationType:MapAnnotationTypeEnd
														title:@"Start Point"] autorelease];
	[_mapView addAnnotation:annotation];
	
	
	// create the image annotation
	//annotation = [[[MapAnnotation alloc] initWithCoordinate:[[points objectAtIndex:points.count / 2] coordinate]
	//										   annotationType:MapAnnotationTypeImage
	//													title:@"Cleveland Circle"] autorelease];
	//[annotation setUserData:@"cc.jpg"];
	//[annotation setUrl:[NSURL URLWithString:@"http://en.m.wikipedia.org/wiki/Cleveland_Circle"]];
	
	//[_mapView addAnnotation:annotation];
   
	
	
	// center and size the map view on the region computed by our route annotation. 
	[_mapView setRegion:routeAnnotation.region];
    [points release];
}
//위치 정보 가져오기가 실패한 경우 실행되는 메소드
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location update Failed");
    //에러 처리
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{ 
  
    //MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2500, 2500);
    //[_mapView setRegion:viewRegion animated:YES];
    [locationManager stopUpdatingLocation];
    
    
}
#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	// turn off the view of the route as the map is chaning regions. This prevents
	// the line from being displayed at an incorrect positoin on the map during the
	// transition. 
    NSLog(@"region allkeys%@",[_routeView allKeys]);
	for(NSObject* key in [_routeView allKeys])
	{
		tripMapRouteViewController* routeV = [_routeView objectForKey:key];
		routeV.hidden = YES;
	}
	
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	// re-enable and re-poosition the route display. 
	for(NSObject* key in [_routeView allKeys])
	{
		tripMapRouteViewController* routeV = [_routeView objectForKey:key];
		routeV.hidden = NO;
		[routeV regionChanged];
	}
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView* annotationView = nil;
	
    
	if([annotation isKindOfClass:[MapAnnotation class]])
	{
		// determine the type of annotation, and produce the correct type of annotation view for it.
		MapAnnotation* csAnnotation = (MapAnnotation*)annotation;
		if(csAnnotation.annotationType == MapAnnotationTypeStart || 
		   csAnnotation.annotationType == MapAnnotationTypeEnd)
		{
			NSString* identifier = @"Pin";
			MKPinAnnotationView* pin = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
			
			if(nil == pin)
			{
				pin = [[[MKPinAnnotationView alloc] initWithAnnotation:csAnnotation reuseIdentifier:identifier] autorelease];
			}
			
			[pin setPinColor:(csAnnotation.annotationType == MapAnnotationTypeEnd) ? MKPinAnnotationColorRed : MKPinAnnotationColorGreen];
			
            pin.animatesDrop=YES;
            pin.canShowCallout = YES;
            pin.calloutOffset = CGPointMake(-5, 5);
            
			annotationView = pin;
		}
		else if(csAnnotation.annotationType == MapAnnotationTypeImage)
		{
			NSString* identifier = @"Image";
			
			ImageAnnotation* imageAnnotationView = (ImageAnnotation*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
			if(nil == imageAnnotationView)
			{
				imageAnnotationView = [[[ImageAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];	
				imageAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			}
			
			annotationView = imageAnnotationView;
		}
		
		[annotationView setEnabled:YES];
		[annotationView setCanShowCallout:YES];
        
	}
	
	else if([annotation isKindOfClass:[RouteAnnotation class]])
	{
		RouteAnnotation* routeAnnotation = (RouteAnnotation*) annotation;
		
		annotationView = [_routeView objectForKey:routeAnnotation.routeID];
		
		if(nil == annotationView)
		{
			tripMapRouteViewController* routeV = [[[tripMapRouteViewController alloc] initWithFrame:CGRectMake(0, 0, _mapView.frame.size.width, _mapView.frame.size.height)] autorelease];
            
			routeV.annotation = routeAnnotation;
			routeV.mapView = _mapView;
			
			[_routeView setObject:routeV forKey:routeAnnotation.routeID];
			
			annotationView = routeV;
		}
	}
	
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	NSLog(@"calloutAccessoryControlTapped");
    
	ImageAnnotation* imageAnnotationView = (ImageAnnotation*) view;
	MapAnnotation* annotation = (MapAnnotation*)[imageAnnotationView annotation];
    
	if(annotation.url != nil)
	{
		if(nil == _detailsVC)	
			_detailsVC = [[DetailsViewController alloc] init];
		
		_detailsVC.url = annotation.url;
        
        [self.navigationController pushViewController:_detailsVC animated:YES];
        
		//[self.view addSubview:_detailsVC.view];
  
	}
}


-(void) showWebViewForURL:(NSURL*) url
{
	DetailsViewController* webViewController = [[DetailsViewController alloc] initWithNibName:@"DetailsViewController" bundle:nil];
	[webViewController setUrl:url];
	
	[self presentModalViewController:webViewController animated:YES];
	//[webViewController autorelease];
}



- (void)viewDidUnload {
	self.mapView   = nil;
}


- (void)dealloc {	
    [_mapView release];
	//[_detailsVC release];
	[_routeView release];
    [super dealloc];
}

@end
