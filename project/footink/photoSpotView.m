//
//  photoSpotView.m
//  footink
//
//  Created by yongsik on 11. 7. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "photoSpotView.h"
#import "GlobalStn.h"
#import "HttpWrapper.h"
#import "JSON.h"
#import "photoSendingController.h"

#define PHOTO_SPOT_GET_URL @"http://footink.com/user/photoSpotList"

@implementation photoSpotView
const float PSectionHeaderHeight=30;

@synthesize CategoryView,catList,progressBack,jsonArray,prevCaption;

-(void)viewDidLoad{
 
}
-(void)viewWillAppear:(BOOL)animated{
    self.CategoryView = [[[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height) style:UITableViewStyleGrouped] autorelease];
    self.CategoryView.delegate=self;
    self.CategoryView.dataSource=self;
    [self.view addSubview:self.CategoryView];

    progressBack=[[UIView alloc] initWithFrame:CGRectMake(10, 10, 300.0, 50.0)];
    [self.view addSubview:progressBack];
    [self getSpotList];
}
-(void)getSpotList{
 
    CLLocationManager *cmanager=[[CLLocationManager alloc] init];
    [cmanager setDesiredAccuracy:kCLLocationAccuracyBest];
    [cmanager setDelegate:self];
    
    CLLocation *loc=[cmanager location];
    //CLLocationCoordinate2D coordinate=[loc coordinate];
    [cmanager release];
    
    CGRect progressframe=CGRectMake(10.0, 5.0, 200.0, 20.0);
    NSString *geturl=[NSString stringWithFormat:@"%@",PHOTO_SPOT_GET_URL];
    progressbar=[[HttpWrapper alloc] requestUrl:geturl values:nil progressBarFrame:(CGRect)progressframe image:nil loc:loc delegate:self];
    NSLog(@"---%@",geturl);
    [self.progressBack addSubview:progressbar];
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFinishWithData:(NSData *)fileData{
    id stringReply;
    stringReply = (NSString *)[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    self.jsonArray=[stringReply JSONValue];
    [self.CategoryView reloadData];
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFailWithError:(NSError *)error{
    NSLog(@"error %@",error);
}
- (void)httpBarUpdated:(HttpWrapper *)httpProgBar{
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"스팟 선택";
	return title;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return PSectionHeaderHeight;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 0, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    /*label.textColor = [UIColor colorWithHue:(360/360)
     saturation:1.0
     brightness:0.60
     alpha:1.0];
     */
    label.textColor=[UIColor colorWithWhite: 0.333 alpha: 0.5];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 0.0);
    //label.font = [UIFont boldSystemFontOfSize:14];
    [label setFont:[UIFont fontWithName:@"verdana" size:9.f]];
    
    label.text = sectionTitle;
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [view setBackgroundColor:[UIColor colorWithWhite:1.0 alpha: 0.5]];
    
    [view autorelease];
    [view addSubview:label];
    
    return view;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 40;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"cat %d",[self.jsonArray count]);
    return [self.jsonArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //tableView.style = UITableViewStylePlain;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"catcell"];
    
    if(cell == nil) {
        cell =  [[[UITableViewCell alloc] 
                  initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"catcell"] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    [cell.textLabel setText:[[self.jsonArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
    //cell.textLabel.font=[UIFont fontWithName:@"apple Gothic" size:7.0];
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.font=[UIFont fontWithName:@"apple Gothic" size:7.0];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    photoSendingController *controller=[[photoSendingController alloc] init];

    controller.pushSpotName=[[self.jsonArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    controller.spotLat=[[self.jsonArray objectAtIndex:indexPath.row] objectForKey:@"lat"];
    controller.spotLng=[[self.jsonArray objectAtIndex:indexPath.row] objectForKey:@"lng"];
    controller.pushCaption=prevCaption;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    //transitioning = YES;
    transition.delegate = self;
    
    self.navigationController.navigationBarHidden = NO;
    //cont.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:controller animated:NO];
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [controller release];
}

- (void)dealloc
{
    [progressBack release];
    [catList release];
    [jsonArray release];
    [prevCaption release];
    [catList release],catList=nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
