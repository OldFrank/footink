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
#import "photoPickerViewController.h"
#import "withGroupController.h"
#import "ProfileViewController.h"
#import "Reachability.h"
#import "JSON.h"
#define MOVE_CENTER_Y 150
#define NEARBY_URL @"http://footink.com/user/nearby"
#define NEARBY_USER_URL @"http://footink.com/user/nearby/user"

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

@synthesize recentGroup,nowScroll;
@synthesize jsonArray;
@synthesize gimageView;
@synthesize yearLabel;
@synthesize monthLabel;
@synthesize timeLabel;
@synthesize newTabBar;
@synthesize jsonNearArray;

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
        
        withGroupController *cont=[[withGroupController alloc] init];
        //cont.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:cont animated:NO];
    }else{
        self.frontView=[[UIView alloc] initWithFrame:CGRectMake(0.0, -20.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        self.frontView.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:self.frontView];   
    
        self.hideView=[[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - (MOVE_CENTER_Y - 45), 320.0, 200.0)];
        //self.hideView.backgroundColor=[UIColor orangeColor];
        self.hideView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ver_line.png"]];
        [self.view addSubview:self.hideView];
    
     
        [self withTabBar];
        
        [self initSview];
        [self readyCAAni];
    }
}

-(void)initSview{
    vchk=YES;
    nowScrollImageCount=0;
    isUp = YES;

    timeLabel=[[UILabel alloc] initWithFrame:CGRectMake(200.0, 0.0, 110.0, 70.0)];
    timeLabel.text=@"";
    timeLabel.textColor=[UIColor grayColor];
    timeLabel.backgroundColor=[UIColor clearColor];
    timeLabel.textAlignment=UITextAlignmentRight;
    timeLabel.font=[UIFont fontWithName:@"Helvetica" size:20];
    [self.frontView addSubview:timeLabel];

    nowScroll=[[UIScrollView alloc] initWithFrame:CGRectMake(10.0, 60.0, 300.0, 50.0)];
    
    [nowScroll setBackgroundColor:[UIColor clearColor]];
    [nowScroll setCanCancelContentTouches:NO];
    
    nowScroll.showsVerticalScrollIndicator=NO;
    nowScroll.showsHorizontalScrollIndicator=NO;
    nowScroll.alwaysBounceVertical=NO;             
    nowScroll.alwaysBounceHorizontal=YES;         
    nowScroll.pagingEnabled=NO;
    nowScroll.delegate=self;
    
    [self.frontView addSubview:nowScroll];
    

    toggleButton=[[UIButton alloc] initWithFrame:CGRectMake(270.0, 340.0, 30.0, 40.0)];
    UIImage *cimg = [UIImage imageNamed:@"btn_down.png"];
    [toggleButton setImage:cimg forState:UIControlStateNormal];
    [toggleButton addTarget:self action:@selector(moveToUpAndDown) forControlEvents:UIControlEventTouchUpInside];
    [cimg release];
    [self.frontView addSubview:toggleButton];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10.0, 2.0, 300.0, 40.0)];
    titleLabel.text=@"현재 위치를 다녀간 사용자";
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.font=[UIFont fontWithName:@"appleGothic" size:10];
    titleLabel.shadowOffset = CGSizeMake(-1, -1);
    [self.hideView addSubview:titleLabel];
    [titleLabel release];

	UISwipeGestureRecognizer *recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)] autorelease];
	recognizer.numberOfTouchesRequired = 1;
    recognizer.direction = (UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown);
	[self.frontView addGestureRecognizer:recognizer];
     
    currentTime=[[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(todayDateTime) userInfo:nil repeats:YES]retain];
        
    timer = [[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(nearAsync) userInfo:nil repeats:YES]retain];
    [self performSelector:@selector(nearAsync) withObject:nil afterDelay:0.1f];
    [self performSelector:@selector(recentSpotGroup) withObject:nil afterDelay:0.5f];
}
- (int)checkNetwork{
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    int status= 0;
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
    //[self stopIndicator];
    UIView *errorMsg=[[UIView alloc] initWithFrame:CGRectMake(0.0, 10.0, 220.0, 70.0)];
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
    [retryBtn addTarget:nil action:@selector(jsonLoad) forControlEvents:UIControlEventTouchUpInside];
    [retryBtn setTitle:@"재시도" forState:UIControlStateNormal]; 
    [retryBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [errorMsg addSubview:retryBtn];
    [self.frontView addSubview:errorMsg];
    [errorMsg release];
    [retryBtn release];
}

-(void)onCamera{
    NSLog(@"camera");
    [self hideTabBar];
    [self removeView];
    [[GlobalStn sharedSingleton] setCamPosition:1];
    //self.tabBarController.tabBar.hidden = NO; 
    
    //photoPickerViewController *pick=[[photoPickerViewController alloc] init];
    //[self.navigationController pushViewController:pick animated:YES];
    self.tabBarController.selectedIndex = 2;
}
- (void)backAct{
    [self hideTabBar];
    [self removeView];
    self.tabBarController.tabBar.hidden = NO; 
    self.tabBarController.selectedIndex = 0;
}
- (void)backPopAct{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)withGroupTabBar{
    newTabBar=[[UIView alloc] initWithFrame:CGRectMake(0.0, 430.0, 320.0, 50.0)];
    newTabBar.backgroundColor=[UIColor whiteColor];
    newTabBar.tag=3000;
    [self.tabBarController.view addSubview:newTabBar]; 
    
    cameraButton=[[UIButton alloc] initWithFrame:CGRectMake(140.0, 0.0, 40.0, 40.0)];
    UIImage *img = [UIImage imageNamed:@"btn_swipe.png"];
    [cameraButton setImage:img forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(onCamera) forControlEvents:UIControlEventTouchUpInside];
    [img release];
    [newTabBar addSubview:cameraButton];
    
    /*backButton=[[UIButton alloc] initWithFrame:CGRectMake(10.0, 10.0, 40.0, 30.0)];
    UIImage *simg = [UIImage imageNamed:@"btn_back.png"];
    [backButton setImage:simg forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backPopAct) forControlEvents:UIControlEventTouchUpInside];
    [simg release];
    [newTabBar addSubview:backButton];
     */
}
-(void)withTabBar{
    [self hideTabBar];
    newTabBar=[[UIView alloc] initWithFrame:CGRectMake(0.0, 430.0, 320.0, 50.0)];
    newTabBar.backgroundColor=[UIColor whiteColor];
    newTabBar.tag=3000;
    [self.tabBarController.view addSubview:newTabBar]; 
    
    cameraButton=[[UIButton alloc] initWithFrame:CGRectMake(140.0, 0.0, 40.0, 40.0)];
    UIImage *img = [UIImage imageNamed:@"btn_swipe.png"];
    [cameraButton setImage:img forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(onCamera) forControlEvents:UIControlEventTouchUpInside];
    [img release];
    [newTabBar addSubview:cameraButton];
    
    backButton=[[UIButton alloc] initWithFrame:CGRectMake(10.0, 10.0, 40.0, 30.0)];
    UIImage *simg = [UIImage imageNamed:@"btn_back.png"];
    [backButton setImage:simg forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAct) forControlEvents:UIControlEventTouchUpInside];
    [simg release];
    [newTabBar addSubview:backButton];
}
-(void)hideTabBar{
    //[[self.tabBarController.view viewWithTag:3000] removeFromSuperview];
    for(UIView *subview in [self.tabBarController.view subviews]){
        if(subview.tag==3000){
           [subview removeFromSuperview];
        }
    }
}
-(void)removeView{
    vchk=NO;
  
    [frontView removeFromSuperview];
    [hideView removeFromSuperview];
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
-(void)groupPush:(id)sender{
    withGroupController *cont=[[withGroupController alloc] init];
    
    //self.tabBarController.hidesBottomBarWhenPushed=YES;
    cont.uidx=[sender tag];
    NSLog(@"%d",[sender tag]);
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
    
    timeLabel.text=[NSString stringWithFormat:@"%@",[[dateFormatter stringFromDate:currentDate] substringFromIndex:8]];
}
-(void)recentSpotGroup{
    NSDictionary *dic;
    dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"나다", @"name", @"이메일이다.", @"email", nil];
    NSMutableArray *valueData=[NSMutableArray array];
    [valueData addObject:dic];
    
    CGRect frame=CGRectMake(220.0, 10.0, 80.0, 20.0);
    
    progressbar=[[HttpWrapper alloc] requestUrl:NEARBY_USER_URL values:valueData progressBarFrame:(CGRect)frame image:nil loc:nil delegate:self];
    [self.hideView addSubview:progressbar];
}
-(void)rectImages{
    recentGroup=[[UIScrollView alloc] initWithFrame:CGRectMake(10.0,30.0, 320.0, 100.0)];
    recentGroup.backgroundColor=[UIColor clearColor];
    recentGroup.pagingEnabled = YES;
    recentGroup.contentSize = CGSizeMake(recentGroup.frame.size.width, recentGroup.frame.size.height);
    recentGroup.showsHorizontalScrollIndicator = NO;
    recentGroup.showsVerticalScrollIndicator = NO;
    recentGroup.scrollsToTop = NO;
    recentGroup.delegate = self;
	
    [self.hideView addSubview:recentGroup];
    int jsonCnt=[self.jsonArray count];
    if(jsonCnt > 0){
        nearBadge = [Badges customBadgeWithString:[NSString stringWithFormat:@"%d",jsonCnt]];
    /*Badges *nearBadge = [Badges customBadgeWithString:[NSString stringWithFormat:@"%d",jsonCnt] 
                                      withStringColor:[UIColor whiteColor] 
                                       withInsetColor:[UIColor redColor] 
                                       withBadgeFrame:YES 
                                  withBadgeFrameColor:[UIColor whiteColor] 
                                            withScale:1.0
                                          withShining:YES];*/
    
        [nearBadge setFrame:CGRectMake(toggleButton.frame.size.width/2-nearBadge.frame.size.width/2+nearBadge.frame.size.width/2, 20, nearBadge.frame.size.width, nearBadge.frame.size.height)];
        [toggleButton addSubview:nearBadge];
    }
    
    float h=0;
    float pos=0;
    int sn=0;
    int cn=1;
    int gap=10;
    
    for(int x=0;x<jsonCnt;x++){
        recentImageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
        recentImageView.frame = CGRectMake(pos, h, 50.0, 50.0);
        [recentImageView setUserInteractionEnabled:YES];
        [recentGroup addSubview:recentImageView];

        recentImageView.imageURL = [NSURL URLWithString:[[self.jsonArray objectAtIndex:x] objectForKey:@"userIcon"]];
        
        UIButton *sbutton = [[UIButton alloc]init];
        sbutton.frame =CGRectMake(0.0, 0.0, recentImageView.frame.size.width, recentImageView.frame.size.height);
        sbutton.tag=[[[self.jsonArray objectAtIndex:x] objectForKey:@"uidx"] intValue];
        [sbutton setImage:[UIImage imageNamed:@"blank_80.png"] forState:UIControlStateNormal];
        [sbutton addTarget:self action:@selector(groupPush:) forControlEvents:UIControlEventTouchUpInside];
        [recentImageView addSubview:sbutton];
        [sbutton release];
        
        sn = x + 1;
        if(sn%5==0){
            pos=0;
            h=(50.0 + gap) * cn;
            cn++;
        }else{
            pos=(50.0 + gap) * (sn%5);
        }
    }
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFinishWithData:(NSData *)fileData{
    id stringReply;
    stringReply = (NSString *)[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    self.jsonArray=[stringReply JSONValue];
    [self rectImages];
    progressbar.hidden=YES;
    NSLog(@"---- %@",stringReply);
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}
- (void)httpBarUpdated:(HttpWrapper *)httpProgBar{
    
}
-(BOOL)nearAsync{
    if([self checkNetwork]==0){
        [self networkError];
        return FALSE;
    }else{
        
    }
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

    if(statusCode==200) {
        
        self.jsonNearArray=[stringReply JSONValue];
        NSLog(@"nearbychk %d",[self.jsonNearArray count]);
        NSLog(@"%@",self.jsonNearArray);
        [self.nearCountlabel setString:[NSString stringWithFormat:@"%d",[self.jsonNearArray count]]];
        
        
        if(nowScrollImageCount!=[self.jsonNearArray count]){
            NSLog(@"update");
            [self nowPhotoScroll];
        }
        nowScrollImageCount=[self.jsonNearArray count];
    }else{
        NSLog(@"http 오류.");
    }
    return TRUE;
}
- (void)nowPhotoScroll{
    int jsonCnt=[self.jsonNearArray count];

    for(UIImageView *subview in [nowScroll subviews]){
        //if(subview.tag==4000){
            [subview removeFromSuperview];
        //}
    }
    
    float h=0;
    float pos=0;
    
    for(int x=0;x<jsonCnt;x++){
        recentImageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
        recentImageView.frame = CGRectMake(pos, h, 50.0, 50.0);
        recentImageView.tag=[[[self.jsonNearArray objectAtIndex:x] objectForKey:@"pidx"] intValue];
        [recentImageView setUserInteractionEnabled:YES];
        [nowScroll addSubview:recentImageView];
        
        UIButton *sbutton = [[UIButton alloc]init];
        sbutton.frame =CGRectMake(0.0, 0.0, recentImageView.frame.size.width, recentImageView.frame.size.height);
        sbutton.tag=[[[self.jsonNearArray objectAtIndex:x] objectForKey:@"uidx"] intValue];
        [sbutton setImage:[UIImage imageNamed:@"blank_80.png"] forState:UIControlStateNormal];
        [sbutton addTarget:self action:@selector(groupPush:) forControlEvents:UIControlEventTouchUpInside];
        [recentImageView addSubview:sbutton];
        [sbutton release];
        
        recentImageView.imageURL = [NSURL URLWithString:[[self.jsonNearArray objectAtIndex:x] objectForKey:@"userIcon"]];
    }
    
        UIImageView *view = nil;
        NSArray *subviews = [nowScroll subviews];
        
        CGFloat curXLoc = 0;
        CGFloat imgcnt =jsonCnt;
        
        for (view in subviews)
        {
            if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
            {
                CGRect frame = view.frame;
                frame.origin = CGPointMake(curXLoc, 0);
                view.frame = frame;
                
                curXLoc += 50 + 12;
            }
        }
        NSUInteger timg;
        if(imgcnt < 5){
            timg = 5;
        }else{
            timg = imgcnt;
        }
        
        [nowScroll setContentSize:CGSizeMake(( timg * 50 + (12 * timg)), [nowScroll bounds].size.height)];
   
   
}
- (void)readyCAAni{
    CALayer *orbit1 = [CALayer layer];
	orbit1.bounds = CGRectMake(100, 200, 200, 200);
    //orbit1.shadowOffset = CGSizeMake(0, 3);
    //orbit1.shadowRadius = 5.0;
    //orbit1.shadowColor = [UIColor blackColor].CGColor;
    //orbit1.shadowOpacity = 0.8;
	orbit1.position = frontView.center;
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
	CountLayer.position = frontView.center;
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
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [timer invalidate];
    timer = nil;
    
    [currentTime invalidate];
    [currentTime release];
    currentTime = nil;

}
- (void)viewDidUnload {
	isUp = NO;
}
- (void)dealloc {
    NSLog(@"dealloc");
  
    
    [locationManager release];
    [newUserLocation release];
    [nearCountlabel release];
    [jsonArray release];
    jsonArray=nil;
    [nowScroll release];
    [frontView release];
    frontView = nil;
    [hideView release];
    hideView = nil;
    [newTabBar release];
    newTabBar = nil;
    
    [recentImageView release];
    recentImageView=nil;
    
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
