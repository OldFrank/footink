//
//  ScrollPhoto.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 15..
//  Copyright 2011 ag. All rights reserved.
//
#import "PhotoRoot.h"
#import "photoDetailView.h"
#import "photoDetailCellView.h"
#import "JSON.h"
#import "UIImageView+AsyncAndCache.h"
#include <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@implementation photoDetailView

@synthesize itemID;
@synthesize jsonItem;

const CGFloat kScrollObjHeight	= 80.0;
const CGFloat kScrollObjWidth	= 80.0;
const CGFloat bkScrollObjHeight = 300.0;
const CGFloat bkScrollObjWidth	= 300.0;
const NSUInteger kNumImages		= 5;
const CGFloat dSectionHeaderHeight = 26.0;

- (id) init{
    self=[super init];
    if(self!=nil){
        self.title=@"DetailView";
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleBordered target:self action:@selector(Back)];
        //self.navigationItem.rightBarButtonItem = plusButton;
        self.navigationItem.leftBarButtonItem = backButton;
        [backButton release];
       // self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleBordered target:self action:@selector(Back)] autorelease];
        
    }
    return self;
}
-(void)Back{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setID:(NSInteger)val {
    NSLog(@"setID");
	self.itemID = (NSInteger *)val;
}
- (BOOL)connectedToNetwork  {
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return 0;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}


-(void)jsonLoad
{
    if ([self connectedToNetwork]) {
    
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://footink.com/user/gv?idx=%i", self.itemID, nil]];
        
        NSString *jsonLData = [[NSString alloc] initWithContentsOfURL:jsonURL];
        
        if (jsonLData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Webservice Down" message:@"The webservice you are accessing is down. Please try again later."  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];	
            [alert release];
        }
        else {
            // converting the json data into an array
            //NSLog(@"%@",jsonLData);
            self.jsonItem = [jsonLData JSONValue]; 
            
            NSLog(@"%@",self.jsonItem);
        }
     
        [jsonLData release];
    }
}

-(void)viewDidLoad{
    NSLog(@"photo viewWillAppear");
    self.jsonItem = nil;
    //BOOL navBarState = [self.navigationController isNavigationBarHidden];

    if ([self connectedToNetwork]) {
        //yes we're connected
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"네트워크 오류" message:@"네트워크가 연결되지 않았습니다."  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];	
        [alert release];
    }

	[_refreshHeaderView refreshLastUpdatedDate];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
 
    
    [self jsonLoad];
    [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"numberOfRowsInSection");
	return [self.jsonItem count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");

	static NSString *CellID = @"MyIdentifier";
    photoDetailCellView *cell = (photoDetailCellView *)[tableView dequeueReusableCellWithIdentifier:CellID];
	
	if (cell == nil) {
		cell = [[[photoDetailCellView alloc] initWithFrame:CGRectZero reuseIdentifier:CellID] autorelease];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *itemAtIndex = (NSDictionary *)[self.jsonItem objectAtIndex:indexPath.row];
    NSLog(@"row %d",indexPath.row);
    [cell setData:itemAtIndex];

    return cell;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
    title = [[[self.jsonItem objectAtIndex:section] valueForKey:@"date"]objectAtIndex:0];
    
	return title;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section] != nil) {
        return SectionHeaderHeight;
    }
    else {
        return 0;
    }
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 NSLog(@"didSelectRowAtIndexPath");
 //photolist *cell = (photolist *)[tableView cellForRowAtIndexPath:indexPath];
 photoDetailView *controller = [[photoDetailView alloc] init];
 
 //[controller setID:[cell getID]];
 
 [self.navigationController pushViewController:controller animated:YES];
 }*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"table height");
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 380;
    }
    return 380;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    NSLog(@"reloadTableViewDataSource");
    //[self jsonLoad];
    //[self.tableView reloadData];
	//_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
    
	//_reloading = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	//[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	//[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	//[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
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
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
}
- (void)viewDidDisappear:(BOOL)animated {
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
	_refreshHeaderView=nil;
    
}
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}
- (void)dealloc
{	
    [self.jsonItem release];
	[super dealloc];
}



@end
