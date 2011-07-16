//
//  FindMeViewController.m
//  FindBranche
//
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FindMeViewController.h"
#import "MapLocation.h"
#import "Branche.h"
#import "BrancheAnnotation.h"

// 현재위치로부터의 지도 반경.
#define LIMIT_RADIUS 3000


@implementation FindMeViewController

@synthesize mapView, locationManager, brancheList;

#pragma mark -
#pragma mark 문자열 비교

- (BOOL)matchString:(NSString *)theString withString:(NSString*)withString {
	NSRange range = [theString rangeOfString:withString];
	int length = range.length;
	
	if (length == 0) {
		return NO;
	}
	
	return YES;
}


#pragma mark -
#pragma mark 지점 정보 로드

// 현재 사용자 위치를 기준으로 지정 정보 로드.
- (void)loadData:(CLLocation *)userLocation {
	// PLIST 파일에서 지점 데이터 로드.
	NSString *path = [[NSBundle mainBundle] pathForResource:@"brancheList" ofType:@"plist"];
    NSArray *branches = [NSArray arrayWithContentsOfFile:path];
	
    self.brancheList = [[[NSMutableArray alloc] initWithCapacity:[branches count]] autorelease];
	NSLog(@"Branches count: %d", [branches count]);
	
    NSDictionary *branche;
    for (branche in branches) {
		NSNumber *brancheLatitude = [branche objectForKey:@"latitude"];
		NSNumber *brancheLongitude = [branche objectForKey:@"longitude"];
		
		CLLocation *brancheLocation = [[CLLocation alloc] initWithLatitude:[brancheLatitude doubleValue] longitude:[brancheLongitude doubleValue]];
		
		if ([self calcDistance:userLocation placeLocation:brancheLocation] == YES) {
			Branche *newBranche = [[Branche alloc] init];
			newBranche.name = [branche objectForKey:@"name"];
			newBranche.address = [branche objectForKey:@"address"];
			newBranche.phoneNo = [branche objectForKey:@"phoneNo"];
			newBranche.latitude = [branche objectForKey:@"latitude"];
			newBranche.longitude = [branche objectForKey:@"longitude"];
			
			[self.brancheList addObject:newBranche];
			[newBranche release];	
		}
		
		[brancheLocation release];
    }
}


// 현재위치와 지점위치 와의 거리 계산, 단 지도 반경 조건이 추가된다.
- (BOOL)calcDistance:(CLLocation *)userLocation placeLocation:(CLLocation *)location {
	CLLocationDistance distance;
	// 아이폰 OS 3.2 이전.
	//distance = [userLocation getDistanceFrom:location];
	// 아이폰 OS 3.2 부터.
	//distance = [userLocation distanceFromLoaction:location];
    
    distance = [userLocation distanceFromLocation:location];  
	if (distance < LIMIT_RADIUS) {
		NSLog(@"지점위치: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
		NSLog(@"현재위치와의 거리: %f", distance);
		return YES;
	}
	
	return NO;
}


// 지점 어노테이션 추가.
- (void)onAddBranche {
	int brancheCount = [brancheList count];
	NSLog(@"반경 %dm, 지점 수: %d", LIMIT_RADIUS, brancheCount);

    for (int i = 0; i < brancheCount; i++) {
		Branche *branche = [self.brancheList objectAtIndex:i];
		
		// 현대증권 본사의 경우 지점명에 "지점" 추가 안함.
		NSString *brancheName;
		if ([self matchString:branche.name withString:@"본사"] == YES) {
			brancheName = branche.name;
		}
		else {
			brancheName = [branche.name stringByAppendingFormat:@"지점"];
		}

		
		CLLocationCoordinate2D position = {[branche.latitude doubleValue], [branche.longitude doubleValue]};
		BrancheAnnotation *mark = [BrancheAnnotation createAnnotation:position];
		mark.title = brancheName;
		mark.subtitle = branche.phoneNo;
		
		[mapView addAnnotation:mark];
	}
}


#pragma mark -
#pragma mark 현재위치 콜아웃

- (void)openCallout:(id<MKAnnotation>)annotation {
    [mapView selectAnnotation:annotation animated:YES];
}


#pragma mark -
#pragma mark 로케이션매니저 델리게이트

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"코어 로케이션 위치 요청.");
	
    if ([newLocation.timestamp timeIntervalSince1970] < [NSDate timeIntervalSinceReferenceDate] - 60) {
        return;
	}
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, LIMIT_RADIUS, LIMIT_RADIUS); 
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
	
    manager.delegate = nil;
    [manager stopUpdatingLocation];
    [manager autorelease];
    
	MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
    geocoder.delegate = self;
    [geocoder start];
	
	// 현재 위치(지도 반경)에 따른 지점 데이터 로드.
	NSLog(@"현재위치: %f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	[self loadData:newLocation];
	
	// 주변 지점 추가.
	[self onAddBranche];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"코어 로케이션 위치 정보 에러.");
	
    NSString *errorType = (error.code == kCLErrorDenied) ? 
    NSLocalizedString(@"Access Denied", @"Access Denied") : 
    NSLocalizedString(@"Unknown Error", @"Unknown Error");
    
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"위치정보 찾기 실패!"
                          message:errorType 
                          delegate:self 
                          cancelButtonTitle:@"확인" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    [manager release];
}


#pragma mark -
#pragma mark 얼럿뷰 델리케이트

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
}


#pragma mark -
#pragma mark 지오코더 델리게이트

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"좌표-주소 변환 실패!"
                          message:@"지오코더가 좌표를 인식하는데 실패했습니다."
                          delegate:self 
                          cancelButtonTitle:@"확인" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    geocoder.delegate = nil;
    [geocoder autorelease];
	
	// 주소 검색 실패 시 현재 위치 표시.
	mapView.showsUserLocation = YES;
}


- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
    MapLocation *annotation = [[MapLocation alloc] init];
    annotation.streetAddress = placemark.thoroughfare;
    annotation.city = placemark.locality;
    annotation.state = placemark.administrativeArea;
    annotation.zip = placemark.postalCode;
    annotation.coordinate = geocoder.coordinate;
    
    [mapView addAnnotation:annotation];
    
    [annotation release];
    
    geocoder.delegate = nil;
    [geocoder autorelease];
}


#pragma mark -
#pragma mark 맵뷰 델리게이트

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *placemarkIdentifier = @"Map Location Identifier";
    if ([annotation isKindOfClass:[MapLocation class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:placemarkIdentifier];
        if (annotationView == nil)  {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:placemarkIdentifier];
        }            
        else {
            annotationView.annotation = annotation;
		}
        
        annotationView.enabled = YES;
        annotationView.animatesDrop = YES;
        annotationView.pinColor = MKPinAnnotationColorPurple;
        annotationView.canShowCallout = YES;
        [self performSelector:@selector(openCallout:) withObject:annotation afterDelay:0.5];
        
        return annotationView;
    }
	else if ([annotation isKindOfClass:[BrancheAnnotation class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:placemarkIdentifier];
        if (annotationView == nil)  {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:placemarkIdentifier];
        }            
        else {
            annotationView.annotation = annotation;
		}
        
        annotationView.enabled = YES;
        annotationView.animatesDrop = YES;
        //annotationView.canShowCallout = YES;
        //[self performSelector:@selector(openCallout:) withObject:annotation afterDelay:1];
		
		// 콜아웃 뷰
		annotationView.canShowCallout = YES;
		annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    }
	
    return nil;
}


- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"지도 로딩 에러"
                          message:[error localizedDescription] 
                          delegate:nil 
                          cancelButtonTitle:@"확인" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	// 전화 걸기.
	if ([view.annotation respondsToSelector:@selector(subtitle)]) {
		NSString *phoneNo = [NSString stringWithFormat:@"tel:%@",view.annotation.subtitle]; 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNo]];
	}

}


#pragma mark -
#pragma mark Initialization

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"주변 검색";
	
	// 로케이션매니저 생성.
	self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// 위치 찾기 시작.
    [self.locationManager startUpdatingLocation];
	
	// 지도 타입 설정.
	mapView.mapType = MKMapTypeStandard;
	
	// 지도 지역 초기화.
	MKCoordinateRegion mapRegion;
	mapRegion.center.latitude = 36.430122;
	mapRegion.center.longitude = 128.056641;
	mapRegion.span.latitudeDelta = 3;
	mapRegion.span.longitudeDelta = 4;
	[mapView setRegion:mapRegion animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


//- (void) viewWillDisappear:(BOOL)animated {
//	[super viewWillDisappear:animated];
//	
//	NSLog(@"Shutting down Core Location");
//	[self.locationManager stopUpdatingLocation];
//	self.locationManager = nil;
//}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
	self.mapView = nil;
}


- (void)dealloc {
	[mapView release];
	[locationManager release];
	[brancheList release];
    [super dealloc];
}


@end
