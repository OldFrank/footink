//
//  SpotListViewController.m
//  photoPicker
//
//  Created by yongsik on 11. 6. 27..
//  Copyright 2011 ag. All rights reserved.
//
#import "SpotListViewController.h"
#import "SearchListCellView.h"
#import "Branche.h"
#import "MapViewController.h"
#import "JSON.h"
#import "GlobalStn.h"
#include <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "PopAlertView.h"
#import "Reachability.h"
#import "SpotInkletSubmit.h"
#import "SpotSubmitView.h"

#define _GOOGLE_PLACE_KEY @"AIzaSyBvuPWVSDqJv5e3fd37mw2-diiWBAv00v4"

@implementation SpotListViewController
const CGFloat pLaceRadius= 1000;
@synthesize brancheList, searchKeyword,jsonArray,locationManager,newUserLocation,curGeoLabel;
@synthesize spotTable;

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
#pragma mark Initialization
- (id) init{
    self=[super init];
    if(self!=nil){
        
        self.title = @"Spot";
        
    }
    return self;
}
#pragma mark -
#pragma mark View lifecycle

- (void) viewDidLoad{
    [super viewDidLoad];
    
    self.spotTable = [[[UITableView alloc] initWithFrame:CGRectMake(0, 50.0, 320, 320)] autorelease];
    self.spotTable.delegate = self;
    self.spotTable.dataSource = self;
    self.spotTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.spotTable];
    
    NSLog(@"viewDidLoad");
    //self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    UIImageView *logoimage=[[UIImageView alloc]initWithFrame:CGRectMake(0,0,85,22)] ;
    [logoimage setImage:[UIImage imageNamed:@"footink_logo.png"]];
    [self.navigationController.navigationBar.topItem setTitleView:logoimage];

     self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(inklet)] autorelease];
    
    [self loadingIndicator];
    
    pageNumber=1;
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
    [overlayView setBackgroundColor:[UIColor colorWithRed:108.0/255.0f green:108.0/255.0f blue:108.0/255.0f alpha:1.0]];
    [self.navigationController.navigationBar addSubview:overlayView]; // navBar is your UINavigationBar instance
    [overlayView release];
    
    NSMutableArray *mAr = [NSMutableArray arrayWithCapacity: 5];
    [mAr addObject:@"Food"];
    [mAr addObject:@"Bar"];
    [mAr addObject:@"Cafe"];
    [mAr addObject:@"Club"];
    [mAr addObject:@"Museum"];
    
    SlidingTabView *tabs = [[SlidingTabView alloc] initWithTabCount:5  withText:mAr delegate:self];
    
    UIView *sview=[[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 60.0)] autorelease];
    sview.tag=350;
    [sview addSubview:tabs];
    
    self.curGeoLabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0, 35.0, 320.0, 13.0)];
    self.curGeoLabel.text=@"";
    self.curGeoLabel.backgroundColor=[UIColor orangeColor];
    self.curGeoLabel.textColor=[UIColor whiteColor];
    self.curGeoLabel.textAlignment=UITextAlignmentCenter;
    [self.curGeoLabel setFont:[UIFont fontWithName:@"verdana" size:8.f]];
    [sview addSubview:self.curGeoLabel];
    
    [self.view addSubview:sview];
    
    //UIView *emptyview=[[[UIView alloc] initWithFrame:CGRectMake(0.0, 60.0, 320.0, 35.0)] autorelease];
    //[self.navigationController.view addSubview:emptyview];
    
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    //BOOL navBarState = [self.navigationController isNavigationBarHidden];
    //[self.navigationController setNavigationBarHidden:!navBarState animated:YES];
    
    /* UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Food", @"Bar",@"Cafe",@"Club",@"Museum",@"Art", nil]];
     [segmentControl addTarget:self action:@selector(onSegChange:) forControlEvents:UIControlEventValueChanged];
     
     //segmentControl.selectedSegmentIndex = 0.0; //시작 선택된버튼
     segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
     segmentControl.tintColor = [UIColor darkGrayColor]; //버튼 색
     segmentControl.backgroundColor = [UIColor clearColor]; //배경색
     
     selectedSegment = [segmentControl selectedSegmentIndex];
     self.navigationItem.titleView = segmentControl;
     
     [segmentControl release];
     */
    //fSearch = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
    //fSearch.delegate = self;
    //[self.view addSubview:fSearch];
    
    if (_refreshHeaderView == nil) {
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.spotTable.bounds.size.height, self.view.frame.size.width, self.spotTable.bounds.size.height)];
        view.delegate = self;
        [self.spotTable addSubview:view];
        _refreshHeaderView = view;
        [view release];
        
    }else{
        
    }
    
    
    timer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(OnTimer:) userInfo:@"food" repeats:NO]retain];
}
-(void)inklet{
    SpotSubmitView *controller=[[SpotSubmitView alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
    [SpotSubmitView release];

}
- (int)checkNetwork{
    // 네트워크의 상태를 체크.
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    int status= 0;
    
    // 상태에 맞는 메세지
    switch (netStatus)
    {
        case NotReachable:
        {
            status = 0; //연결실패
            break;
        }
        case ReachableViaWWAN:
        {
            status = 1; //GRPS/3G
            break;
        }
        case ReachableViaWiFi:
        {
            status= 2; //wifi
            break;
        }
    }
    return status;
}
-(void)networkError{
    [self stopIndicator];
    UIView *errorMsg=[[UIView alloc] initWithFrame:CGRectMake(50.0, 50.0, 220.0, 80.0)];
    errorMsg.backgroundColor=[UIColor whiteColor];
    errorMsg.tag=400;
    
    UILabel *msgLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 190, 30.0)];
    msgLabel.text=@"인터넷이 연결되지 않았습니다.";
    msgLabel.textAlignment=UITextAlignmentCenter;
    msgLabel.textColor=[UIColor grayColor];
    msgLabel.font=[UIFont fontWithName:@"appleGothic" size:11.0f];
    msgLabel.backgroundColor=[UIColor clearColor];
    [errorMsg addSubview:msgLabel];
    
    UIButton *retryBtn=[[UIButton alloc] initWithFrame:CGRectMake(30.0,30.0,100.0,30.0)];
    [retryBtn addTarget:nil action:@selector(jsonLoad:) forControlEvents:UIControlEventTouchUpInside];
    [retryBtn setTitle:@"재시도" forState:UIControlStateNormal]; 
    [retryBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [errorMsg addSubview:retryBtn];
    [self.spotTable addSubview:errorMsg];
    [errorMsg release];
    [retryBtn release];
}
- (void)loadingIndicator{
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(35.0, 35.0, 30.0, 30.0)];
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicatorView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleBottomMargin);
    
    indicatorView.hidesWhenStopped = TRUE ;
    
    
    UIView *loadingBack=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)]; 
    loadingBack.backgroundColor=[UIColor darkGrayColor];
    loadingBack.tag = 300;
    [self.spotTable addSubview:loadingBack];
    [loadingBack addSubview:indicatorView];
    [indicatorView startAnimating];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animation:finished:context:)];
    [loadingBack setCenter:CGPointMake(160,160)];
    [UIView commitAnimations];
}
-(void)stopIndicator{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self.spotTable viewWithTag:300] removeFromSuperview];
}
-(void)ToggleIndicator{
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:100];
    if (toggleShowing) 
        [activityIndicator stopAnimating]; 
    else 
        [activityIndicator startAnimating];
    
    toggleShowing = !toggleShowing;
}

- (void)showAlert:(NSString *)msg{
	UIImage *backgroundImage = [UIImage imageNamed:@"alertBack.png"];
	alert = [[PopAlertView alloc] initWithImage:backgroundImage text:NSLocalizedString(msg, nil)];
	[alert show];
	// dismiss alert after 4 seconds
	//[self performSelector:@selector(hideAlert) withObject:nil afterDelay:4.0];
}

- (void) hideAlert {
	[alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[alertView release];
}
- (void)OnTimer:(NSTimer *)stimer
{
    [self jsonLoad:[stimer userInfo]];
    [self.spotTable reloadData];
}

- (BOOL)jsonLoad:(NSString *)types{
    NSLog(@"start parsing %@",types);
    
    if([self checkNetwork]==0){ 
        [self networkError];
        return FALSE;
    }else{
        [[self.spotTable viewWithTag:400] removeFromSuperview];
    }
        if(types==nil)
            types=@"food";
        
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager startUpdatingLocation];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager setDelegate:self];
        CLLocation* location = [self.locationManager location];
        CLLocationCoordinate2D coordinate = [location coordinate];
        
        NSLog(@"%f",coordinate.latitude);
        MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
        geocoder.delegate = self;
        [geocoder start];
        
        self.newUserLocation=location;
        
        NSURLRequest *request = [[[NSURLRequest alloc] init] autorelease];
        
        [request initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://footink.com/user/spotList?lat=%f&lng=%f&radius=%f&types=%@",coordinate.latitude,coordinate.longitude,pLaceRadius,types, nil]]];
        
        //NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSURLResponse *response;
        NSHTTPURLResponse *httpResponse;
        NSError *error;
        
        id stringReply;
        
        NSData *datareply=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];   
        
        
        stringReply = (NSString *)[[NSString alloc] initWithData:datareply encoding:NSUTF8StringEncoding];
        
        // Some debug code, etc.
        // NSLog(@"reply from server: %@", stringReply);
        httpResponse = (NSHTTPURLResponse *)response;
        int statusCode = [httpResponse statusCode];  
        //NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]); 
        //NSLog(@"HTTP Status code: %d", statusCode);
        
        if(statusCode==200) {
            self.jsonArray=[stringReply JSONValue];
            
            if(self.jsonArray==nil)
                NSLog(@"parsing error");
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
            [self.jsonArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            [sortDescriptor release];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [[self.spotTable viewWithTag:300] removeFromSuperview];
            
        }else{
            NSLog(@"http error %d",statusCode);
            
            
        }
    return TRUE;
}
- (void)selTimer:(NSString *)type{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    timer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(OnTimer:) userInfo:type repeats:NO]retain];
}

/*- (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 
 [self.tableView reloadData];
 
 }
 */


/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    //self.tableView.frame=CGRectMake(0.0, 80.0, 320.0, 320.0);
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ((pageNumber * kPageUnit) < self.jsonArray.count)
    {
        return (pageNumber * kPageUnit) + 1;
    }else {
        return self.jsonArray.count;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if ((pageNumber * kPageUnit) < self.jsonArray.count)
    {
        if (indexPath.row != (pageNumber * kPageUnit)) {
            
        }else{
            
            UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"LoadMoreResultsCell"];
            if (cell == nil) {
                
                cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
                //cell.backgroundColor=[UIColor grayColor];
            }
            cell.contentView.backgroundColor=[UIColor grayColor];
            UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(50.0, 10.0, 200.0, 20.0)] autorelease];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font=[UIFont fontWithName:@"Verdana" size:20];
            titleLabel.textAlignment=UITextAlignmentCenter;
            titleLabel.font=[UIFont boldSystemFontOfSize:20];
            titleLabel.text=@"Load More"; 
            [cell.contentView addSubview:titleLabel]; 
            
            
            return cell;
        }
    }
    
    static NSString *CellIdentifier = @"Cell";
    SearchListCellView *cell = (SearchListCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SearchListCellView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;      
    }
    
    
    NSDictionary *itemAtIndex = (NSDictionary *)[self.jsonArray objectAtIndex:indexPath.row];
    [cell setData:itemAtIndex];
    
    if(self.jsonArray==nil){
        NSLog(@"json data empty");
    }else{
        
        NSNumber *Latitude = [[self.jsonArray objectAtIndex:indexPath.row] objectForKey:@"lat"];
        NSNumber *Longitude = [[self.jsonArray objectAtIndex:indexPath.row] objectForKey:@"lng"];
        
        CLLocation *spotLocation = [[CLLocation alloc] initWithLatitude:[Latitude doubleValue] longitude:[Longitude doubleValue]];
        
        NSString *fdist=[NSString stringWithFormat:@"%.2f m",[self calcDistance:self.newUserLocation placeLocation:spotLocation]];
        cell.distanceLabel.text = fdist;
        
    }
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((pageNumber * kPageUnit) < self.jsonArray.count)
        
    {
        
        if (indexPath.row != (pageNumber * kPageUnit)) {
            
            NSString *reff=[[self.jsonArray objectAtIndex:indexPath.row] objectForKey:@"reference"];
            

            
            //NSLog(@"%@ %@",[spotDetail objectForKey:@"latitude"],[spotDetail objectForKey:@"longitude"]);
            
            MapViewController *mapViewController = [[MapViewController alloc] init];
            mapViewController.reference = reff;
            [self.navigationController pushViewController:mapViewController animated:YES];
            [mapViewController release];
            
        }else{
            
            pageNumber++;
            
            [tableView reloadData];
            
        }
        
    }else{
        NSString *reff=[[self.jsonArray objectAtIndex:indexPath.row] objectForKey:@"reference"];
        

        
        MapViewController *mapViewController = [[MapViewController alloc] init];
        mapViewController.reference = reff;
        [self.navigationController pushViewController:mapViewController animated:YES];
        [mapViewController release];
    }
    
    
}

- (void)startTheBackgroundJob {  
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
    // wait for 3 seconds before starting the thread, you don't have to do that. This is just an example how to stop the NSThread for some time  
    [NSThread sleepForTimeInterval:1];  
    [self performSelectorOnMainThread:@selector(makeMyProgressBarMoving) withObject:nil waitUntilDone:NO];  
    [pool release];  
    
}  
- (void)makeMyProgressBarMoving {  
    
    //float actual = [self.progressBar progress];  
    //NSLog(@"%f",actual);
    //threadValueLabel.text = [NSString stringWithFormat:@"%.2f", actual];  
    //if (actual < 1) {  
    //   self.progressBar.progress = actual + 0.01;  
    //    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(makeMyProgressBarMoving) userInfo:nil repeats:NO];  
    //    
    // }  
    // else upload.hidden = NO;  
    
}

// 현재위치와 지점위치 와의 거리 계산, 단 지도 반경 조건이 추가된다.
- (CGFloat)calcDistance:(CLLocation *)userLocation placeLocation:(CLLocation *)location {
	CLLocationDistance distance;
    
    
    //#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 3130
    //    distance = [userLocation getDistanceFrom:location];
    //#else
    distance = [userLocation distanceFromLocation:location];         
    //#endif
    
    //NSLog(@"spot위치: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
    //NSLog(@"현재위치와의 거리: %f", distance);
    return distance;
    
}

#pragma mark -
#pragma mark 로케이션매니저 델리게이트

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
	self.newUserLocation=nil;
    if ([newLocation.timestamp timeIntervalSince1970] < [NSDate timeIntervalSinceReferenceDate] - 60) {
        return;
	}
    
    manager.delegate = nil;
    [manager stopUpdatingLocation];
    [manager autorelease];
    
	self.newUserLocation=newLocation;
	// 현재 위치(지도 반경)에 따른 지점 데이터 로드.
	//NSLog(@"현재위치: %f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"코어 로케이션 위치 정보 에러.");
	
    NSString *errorType = (error.code == kCLErrorDenied) ? 
    NSLocalizedString(@"Access Denied", @"Access Denied") : 
    NSLocalizedString(@"Unknown Error", @"Unknown Error");
    
    NSLog(@"%@",errorType);
}
#pragma mark -
#pragma mark 지오코더 델리게이트

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
    //NSLog(@"placemark %@",placemark);
    
    NSDictionary *pm=(NSDictionary *)[placemark addressDictionary];
    NSString *address=[NSString stringWithFormat:@"%@ %@ %@ %@ %@",[pm objectForKey:@"ZIP"],[pm objectForKey:@"Country"],[pm objectForKey:@"State"],[pm objectForKey:@"City"],[pm objectForKey:@"Street"]];
    
    self.curGeoLabel.text=address;
    
    //UIView *GeoView=[[[UIView alloc] initWithFrame:CGRectMake(10.0, 150.0, 300.0, 20.0)] autorelease];
    
    //[GeoView addSubview:curGeoLabel];
    
    //[self.navigationController.view addSubview:GeoView];
    
    geocoder.delegate = nil;
    [geocoder autorelease];
}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    /*UIAlertView *alert = [[UIAlertView alloc] 
     initWithTitle:@"좌표-주소 변환 실패!"
     message:@"지오코더가 좌표를 인식하는데 실패했습니다."
     delegate:self 
     cancelButtonTitle:@"확인" 
     otherButtonTitles:nil];
     [alert show];
     [alert release];*/
    NSLog(@"좌표-주소 변환실패");
    geocoder.delegate = nil;
    [geocoder autorelease];
    
}

#pragma mark -
#pragma mark SlidingTabsControl Delegate
- (UILabel*) labelFor:(SlidingTabView*)slidingTabsControl atIndex:(NSUInteger)tabIndex atLabel:(NSString *)ltext;
{
    UILabel* label = [[[UILabel alloc] init] autorelease];
    label.text = ltext;
    
    return label;
}
- (void)touchDownAtTabIndex:(NSUInteger)tabIndex
{
    NSLog(@"%d",tabIndex);
    
    switch (tabIndex) {
        case 0: 
            
            [self selTimer:@"food"];
            
            break;
        case 1: 
           
            [self selTimer:@"bar"];
            
            break;
        case 2: 
            
            [self selTimer:@"cafe"];
            
            break;
        case 3: 
            
            [self selTimer:@"club"];
            
            break;
        case 4: 
            
            [self selTimer:@"museum"];
            
            break;
        case 5: 
            
            [self selTimer:@"art_gallery"];
            
            break;
        default:
            //[self.tableView reloadData];
            break;
    }
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    timer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(OnTimer:) userInfo:@"food" repeats:NO]retain];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
    
	_reloading = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.spotTable];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading;
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	_refreshHeaderView=nil;
    
}

- (void)dealloc {
    [alert release];
    [curGeoLabel release];
    [jsonArray release];

	[brancheList release];
	[searchKeyword release];
    [newUserLocation release];
    [locationManager release];
    
    [super dealloc];
}


@end

