//
//  withRootView.m
//  photoPicker
//
//  Created by yongsik on 11. 7. 13..
//  Copyright 2011 ag. All rights reserved.
//

#import "withRootView.h"
#import "withAddView.h"
#import "GlobalStn.h"
#import "withRootCell.h"
#import "withCircle.h"
#import "EGOImageView.h"
#import "photoPickerViewController.h"
#import "Badges.h"
#import "withViewcontroller.h"
#import "ProfileViewController.h"

#define MOVE_CENTER_Y 150
#define NEARBY_URL @"http://footink.com/user/nearby"
#define NEARBY_GROUP_URL @"http://footink.com/user/t"

@implementation withRootView

bool vchk=NO;


@synthesize frontView;
@synthesize hideView;
@synthesize toggleButton;
@synthesize backButton;
@synthesize cameraButton;

@synthesize locationManager;
@synthesize newUserLocation;
@synthesize nearCountlabel;


@synthesize recentGroup;
@synthesize jsonArray;
@synthesize gimageView;
@synthesize yearLabel;
@synthesize monthLabel;
@synthesize timeLabel;
@synthesize newTabBar;

- (id) init{
    self=[super init];
    if(self!=nil){
        self.title=@"With";
       
    }
    return self;
}
- (void)viewDidLoad {
     NSLog(@"viewDidLoad");
    [super viewDidLoad];

    profileView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
    profileView.frame = CGRectMake(2.0, 2.0, 40.0, 40.0);
    profileView.imageURL = [NSURL URLWithString:[[GlobalStn sharedSingleton] uprofile]];
    
    UIButton *pButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pButton.frame = CGRectMake(0, 0, profileView.frame.size.width, profileView.frame.size.height);
    [pButton setImage:profileView.image forState:UIControlStateNormal];
    [pButton addTarget:self action:@selector(goProfile) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:pButton] autorelease];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    CLCHK=NO;
    isUp = NO;
}
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"Root viewwillappear");
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES; 
    if([[GlobalStn sharedSingleton] camPosition]==1){//with상에서 카메라 촬영시
       // self.tabBarController.tabBar.hidden = YES; 
         NSLog(@"after taken pic");
        [[GlobalStn sharedSingleton] setCamPosition:0];
        withViewcontroller *cont=[[withViewcontroller alloc] init];
        //cont.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:cont animated:NO];
    }else{
        self.frontView=[[UIView alloc] initWithFrame:CGRectMake(0.0, - MOVE_CENTER_Y / 2, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        self.frontView.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:self.frontView];   
    
        self.hideView=[[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - MOVE_CENTER_Y / 2, 320.0, 200.0)];
        //self.hideView.backgroundColor=[UIColor orangeColor];
        self.hideView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ver_line.png"]];
        [self.view addSubview:self.hideView];
    
        [self initSview];
        [self readyCAAni];
    }
}
-(void)initSview{
    vchk=YES;
       
    yearLabel=[[UILabel alloc] initWithFrame:CGRectMake(200.0, 45.0, 110.0, 80.0)];
    yearLabel.text=@"";
    yearLabel.textAlignment=UITextAlignmentRight;
    yearLabel.textColor=[UIColor grayColor];
    yearLabel.backgroundColor=[UIColor clearColor];
    yearLabel.font=[UIFont fontWithName:@"Helvetica" size:16];
    [self.frontView addSubview:yearLabel];
    
    monthLabel=[[UILabel alloc] initWithFrame:CGRectMake(200.0, 65.0, 110.0, 80.0)];
    monthLabel.text=@"";
    monthLabel.textAlignment=UITextAlignmentRight;
    monthLabel.textColor=[UIColor grayColor];
    monthLabel.backgroundColor=[UIColor clearColor];
    monthLabel.font=[UIFont fontWithName:@"Helvetica" size:27];
    [self.frontView addSubview:monthLabel];
    
    timeLabel=[[UILabel alloc] initWithFrame:CGRectMake(200.0, 95.0, 110.0, 70.0)];
    timeLabel.text=@"";
    timeLabel.textColor=[UIColor grayColor];
    timeLabel.backgroundColor=[UIColor clearColor];
    timeLabel.textAlignment=UITextAlignmentRight;
    timeLabel.font=[UIFont fontWithName:@"Helvetica" size:20];
    [self.frontView addSubview:timeLabel];

    backButton=[[UIButton alloc] initWithFrame:CGRectMake(10.0, 440.0, 40.0, 30.0)];
    UIImage *simg = [UIImage imageNamed:@"btn_back.png"];
    [backButton setImage:simg forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAct) forControlEvents:UIControlEventTouchUpInside];
    [simg release];
    [self.frontView addSubview:backButton];
    
    isUp = YES;
    toggleButton=[[UIButton alloc] initWithFrame:CGRectMake(270.0, 430.0, 30.0, 40.0)];
    UIImage *cimg = [UIImage imageNamed:@"btn_down.png"];
    [toggleButton setImage:cimg forState:UIControlStateNormal];
    [toggleButton addTarget:self action:@selector(moveToUpAndDown) forControlEvents:UIControlEventTouchUpInside];
    [cimg release];
    [self.frontView addSubview:toggleButton];
    
    Badges *nearBadge = [Badges customBadgeWithString:@"2" 
                                         withStringColor:[UIColor whiteColor] 
                                          withInsetColor:[UIColor redColor] 
                                          withBadgeFrame:YES 
                                     withBadgeFrameColor:[UIColor whiteColor] 
                                               withScale:1.0
                                             withShining:YES];
    
    [nearBadge setFrame:CGRectMake(toggleButton.frame.size.width/2-nearBadge.frame.size.width/2+nearBadge.frame.size.width/2, 20, nearBadge.frame.size.width, nearBadge.frame.size.height)];
    
    [toggleButton addSubview:nearBadge];
       
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10.0, 2.0, 300.0, 40.0)];
    titleLabel.text=@"현재 위치에 다른 사진";
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.font=[UIFont fontWithName:@"appleGothic" size:10];
    titleLabel.shadowOffset = CGSizeMake(-1, -1);
    [self.hideView addSubview:titleLabel];
    [titleLabel release];
    
    UIButton *sbutton = [[UIButton alloc]init];
    sbutton.frame =CGRectMake(10.0, 35.0, 60, 60);
    [sbutton setImage:[UIImage imageNamed:@"Icon.png"] forState:UIControlStateNormal];
    [sbutton addTarget:self action:@selector(groupPush) forControlEvents:UIControlEventTouchUpInside];
    [self.hideView addSubview:sbutton];
    
	UISwipeGestureRecognizer *recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)] autorelease];
	recognizer.numberOfTouchesRequired = 1;
    recognizer.direction = (UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown);
	[self.frontView addGestureRecognizer:recognizer];
     
   currentTime=[[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(todayDateTime) userInfo:nil repeats:YES]retain];
        
    timer = [[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(nearAsync) userInfo:nil repeats:YES]retain];
}
-(void)onCamera{
    NSLog(@"camera");
    [self removeView];
    [[GlobalStn sharedSingleton] setCamPosition:1];
    self.tabBarController.tabBar.hidden = NO; 
    self.tabBarController.selectedIndex = 2;
}
- (void)backAct{
    
    [self removeView];
    self.tabBarController.tabBar.hidden = NO; 
    self.tabBarController.selectedIndex = 0;
    
}
-(void)removeView{
    vchk=NO;
    if(timer != nil){
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    
    if(currentTime != nil){
        [currentTime invalidate];
        [currentTime release];
        currentTime = nil;
    }
    [frontView removeFromSuperview];
    [hideView removeFromSuperview];
    [[self.tabBarController.view viewWithTag:3000] removeFromSuperview];

    /*[frontView release];
     frontView = nil;
     [hideView release];
     hideView = nil;
     [newTabBar release];
     newTabBar = nil;*/
    
}

-(void)goProfile{
   /* withViewcontroller *cont=[[withViewcontroller alloc] init];
    self.tabBarController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:cont animated:YES];//popToViewController:cont animated:YES];
    [cont release];*/
}
-(void)groupPush{
    withViewcontroller *cont=[[withViewcontroller alloc] init];
    self.tabBarController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:cont animated:YES];//popToViewController:cont animated:YES];
    [cont release];
}
-(void)todayDateTime{
    NSDate *currentDate=[NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyyMMddHH:mm:ss"];
    //timezone설정
    //NSTimeZone *usTimeZone = [NSTimeZone timeZoneWithName:@"US/Pacific"];
    //NSTimeZone *usTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];

    NSTimeZone *usTimeZone = [NSTimeZone timeZoneWithName:@"Asia/Seoul"];
    [dateFormatter setTimeZone:usTimeZone];
  
    yearLabel.text=[NSString stringWithFormat:@"%@",[[dateFormatter stringFromDate:currentDate] substringToIndex:4]];
    monthLabel.text=[NSString stringWithFormat:@"%@.%@",[[[dateFormatter stringFromDate:currentDate] substringFromIndex:4] substringToIndex:2],
                     [[[dateFormatter stringFromDate:currentDate] substringFromIndex:6] substringToIndex:2]];
    timeLabel.text=[NSString stringWithFormat:@"%@",[[dateFormatter stringFromDate:currentDate] substringFromIndex:8]];
}
-(void)recentSpotGroup{
    NSDictionary *dic;
    dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"나다", @"name", @"이메일이다.", @"email", nil];
    NSMutableArray *valueData=[NSMutableArray array];
    [valueData addObject:dic];
    
    CGRect frame=CGRectMake(90.0, 100.0, 200.0, 20.0);
    
    progressbar=[[HttpWrapper alloc] requestUrl:NEARBY_GROUP_URL values:valueData progressBarFrame:(CGRect)frame image:NO loc:NO delegate:self];
    [self.hideView addSubview:progressbar];
    
    
    recentGroup=[[UITableView alloc] initWithFrame:CGRectMake(0.0, 10.0, 320.0,300)];
    recentGroup.delegate=self;
    [self.hideView addSubview:recentGroup];
    
   
}
//httpwrapper
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFinishWithData:(NSData *)fileData{
    
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}
- (void)httpBarUpdated:(HttpWrapper *)httpProgBar{
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   
	
        return 10;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
   
        title = [[self.jsonArray objectAtIndex:section] valueForKey:@"date"];
    
	return title;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section] != nil) {
        return 30;
    } else {
        return 0;
    }
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
        if (indexPath.section == 0 && indexPath.row == 0) {
            return 80;
        }
        return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //tableView.style = UITableViewStylePlain;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor whiteColor];

        static NSString *CellID = @"CalendarIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if(cell == nil) {
            cell =  [[[UITableViewCell alloc] 
                      initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID] autorelease];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSDictionary *itemAtIndex = (NSDictionary *)[self.jsonArray objectAtIndex:indexPath.section];
        NSArray *uniq=[itemAtIndex valueForKey:@"idx"];

            NSUInteger i;
           
   
            for (i = 1; i <= (int)[[GlobalStn sharedSingleton] celltot]; i++)
            {
                int a=i - 1;
                NSString *tempidx=[NSString stringWithFormat:@"%@",[uniq objectAtIndex:a]];
                int idx=[tempidx intValue];
                
                gimageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_80.png"]];
                
                CGRect rect = gimageView.frame;
                rect.size.height = 50;
                rect.size.width = 50;
                gimageView.frame = rect;
                [gimageView setUserInteractionEnabled:YES];
                gimageView.tag = idx;
                
                UIButton *button = [[UIButton alloc]init];
                
                button.frame = rect;
                button.tag = idx;
                [button setImage:[UIImage imageNamed:@"blank_80.png"] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(detailPush:) forControlEvents:UIControlEventTouchUpInside];
                
                [gimageView addSubview:button];
                
                [button release];
                
                [cell addSubview:gimageView];
            }
            //빈이미지 넣기
            if((int)[[GlobalStn sharedSingleton] celltot] < 5){
                NSUInteger x;
                NSUInteger imgemt;
                imgemt=5 - (int)[[GlobalStn sharedSingleton] celltot];
                
                for (x = imgemt; x <= 5; x++)
                {
                    gimageView.image = [UIImage imageNamed:@"blank_80.png"];
                    
                    CGRect rect = gimageView.frame;
                    rect.size.height = 50;
                    rect.size.width = 50;
                    gimageView.frame = rect;
                    
                    [cell addSubview:gimageView];
                }
            }
            //[self setData:itemAtIndex sect:indexPath.section];
        //[self layoutScrollImages];
        return cell;
}
-(void)nearAsync{
    if(CLCHK==NO){
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager startUpdatingLocation];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager setDelegate:self];
        
        CLCHK=YES;
    }
    CLLocation* location = [self.locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    self.newUserLocation=location;
    
    NSLog(@"%f",coordinate.latitude);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:NEARBY_URL] 
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [NSString stringWithString:@"-----------14737809831466499882746641449"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //post append
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"lat\"\r\n\r\n%f",coordinate.latitude] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"lng\"\r\n\r\n%f",coordinate.longitude] dataUsingEncoding:NSUTF8StringEncoding] ];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    [request setHTTPBody:body];
    
    NSURLResponse *kresponse;
    NSHTTPURLResponse *httpResponse;
    NSError *error;
    
    id stringReply;
    
    NSData *datareply=[NSURLConnection sendSynchronousRequest:request returningResponse:&kresponse error:&error];
    stringReply = (NSString *)[[NSString alloc] initWithData:datareply encoding:NSUTF8StringEncoding];
    
    httpResponse = (NSHTTPURLResponse *)kresponse;
    int statusCode = [httpResponse statusCode];  
    //NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]); 
    NSLog(@"HTTP Status code: %d", statusCode);
    
    if(statusCode==200) {
        NSLog(@"nearbychk %@",stringReply);
        [self.nearCountlabel setString:stringReply];

    }else{
        NSLog(@"http 오류.");
    }
}
- (void)readyCAAni{
    CALayer *orbit1 = [CALayer layer];
	orbit1.bounds = CGRectMake(0, 100, 200, 200);
    //orbit1.shadowOffset = CGSizeMake(0, 3);
    //orbit1.shadowRadius = 5.0;
    //orbit1.shadowColor = [UIColor blackColor].CGColor;
    //orbit1.shadowOpacity = 0.8;
	orbit1.position = self.view.center;
	orbit1.cornerRadius = 0;
	orbit1.borderColor = [UIColor grayColor].CGColor;
	orbit1.borderWidth = 0;
	orbit1.opacity=1.0;
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = orbit1.bounds;
    imageLayer.cornerRadius = 0.0;
    imageLayer.contents = (id) [UIImage imageNamed:@"circle.png"].CGImage;
    imageLayer.masksToBounds = YES;
    [orbit1 addSublayer:imageLayer];
    
	CALayer *over = [CALayer layer];
	over.frame = CGRectMake(8.5, 8.5, 183, 183);
    //over.position = CGPointMake(160, 240);
    over.cornerRadius = 0.0;
    over.contents = (id) [UIImage imageNamed:@"circle_over.png"].CGImage;
    over.masksToBounds = YES;
	[imageLayer addSublayer:over];
	
	CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	anim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	anim1.fromValue = [NSNumber numberWithFloat:0];
	anim1.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
	anim1.repeatCount = HUGE_VALF;
	anim1.duration = 2.0;
	[over addAnimation:anim1 forKey:@"transform"];
    
	[frontView.layer addSublayer:orbit1];

    CALayer *CountLayer = [CALayer layer];
	CountLayer.bounds = CGRectMake(0, 0, 80, 80);
    CountLayer.backgroundColor = [UIColor grayColor].CGColor;
	CountLayer.position = self.view.center;
	CountLayer.cornerRadius = 40;
	CountLayer.borderColor = [UIColor grayColor].CGColor;
	CountLayer.borderWidth = 0;
	CountLayer.opacity=1.0;
    [frontView.layer addSublayer:CountLayer];

    self.nearCountlabel = [[CATextLayer alloc] init];
    [self.nearCountlabel setFont:@"Helvetica-Bold"];
    [self.nearCountlabel setFontSize:40];  
    [self.nearCountlabel setFrame:CGRectMake(15.0, 22.0,50.0, 50.0)];
    [self.nearCountlabel setString:@"0"];
    [self.nearCountlabel setAlignmentMode:kCAAlignmentCenter];
    [self.nearCountlabel setForegroundColor:[[UIColor whiteColor] CGColor]];
    [CountLayer addSublayer:self.nearCountlabel];
   
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
	NSLog(@"현재위치: %f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"코어 로케이션 위치 정보 에러.");
	
    NSString *errorType = (error.code == kCLErrorDenied) ? 
    NSLocalizedString(@"Access Denied", @"Access Denied") : 
    NSLocalizedString(@"Unknown Error", @"Unknown Error");
    
    NSLog(@"%@",errorType);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload {
	isUp = NO;
}
- (void)dealloc {
    NSLog(@"dealloc");
    if(timer != nil){
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    if(currentTime != nil){
        [currentTime invalidate];
        [currentTime release];
        currentTime = nil;
    }
    
    [locationManager release];
    [newUserLocation release];
    [nearCountlabel release];
    [jsonArray release];
    jsonArray=nil;
    
    [frontView release];
    frontView = nil;
    [hideView release];
    hideView = nil;
    [newTabBar release];
    newTabBar = nil;

    [nearCountlabel release];
    [cameraButton release];
    [backButton release];
    [locationManager release];
    [newUserLocation release];
	[toggleButton release];
    [timeLabel release];
    [yearLabel release];
    [monthLabel release];
    [gimageView release];
    [super dealloc];
}
#pragma mark - 커스텀 메서드

- (void)swipedScreen:(UISwipeGestureRecognizer*)recognizer {
	[self moveToUpAndDown];
}


- (IBAction)moveToUpAndDown {
	UIImage *image;
	float moveCenterY;
    float hideCenterY;
	
	if (isUp) {
		moveCenterY = self.frontView.center.y - MOVE_CENTER_Y;
        hideCenterY = self.hideView.center.y - MOVE_CENTER_Y;
		image = [UIImage imageNamed:@"btn_down.png"];
		isUp = NO;
	}
	else {
		moveCenterY = self.frontView.center.y + MOVE_CENTER_Y;
        hideCenterY = self.hideView.center.y + MOVE_CENTER_Y;
		image = [UIImage imageNamed:@"btn_up.png"];
		isUp = YES;
	}
	
	// Pre iOS 4
    //[UIView beginAnimations:nil context:nil];
    //    [UIView setAnimationDuration:1.0];
    //    [UIView setAnimationDelay:0.2];
    //    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    //    self.frontView.center = CGPointMake(self.frontView.center.x, moveCenterY);
    //	[self.toggleButton setImage:image forState:UIControlStateNormal];
    //    [UIView commitAnimations]; 
    
	// iOS4+: Blocks 사용.
    [UIView animateWithDuration:0.7
						  delay:0.1
						options:UIViewAnimationCurveEaseOut
					 animations:^{
						 self.frontView.center = CGPointMake(self.frontView.center.x, moveCenterY);
                         self.hideView.center = CGPointMake(self.hideView.center.x, hideCenterY);
						 [self.toggleButton setImage:image forState:UIControlStateNormal];
                         
                        
					 } 
					 completion:^(BOOL finished){
						 NSLog(@"Done!");
                     

					 }];
  
}

@end
