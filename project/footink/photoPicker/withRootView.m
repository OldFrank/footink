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


#define MOVE_CENTER_Y 150
#define NEARBY_URL @"http://footink.com/user/nearby"

@implementation withRootView

bool vchk=NO;

@synthesize header;
@synthesize frontView;
@synthesize hideView;
@synthesize toggleButton;
@synthesize backButton;
@synthesize cameraButton;

@synthesize locationManager;
@synthesize newUserLocation;
@synthesize nearCountlabel;


- (id) init{
    self=[super init];
    if(self!=nil){
        self.title=@"Friends";
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.tabBarController.tabBar.hidden = YES; 
    vchk=YES;
    [self initSview];
    [self nearAsync];
}
-(void)viewWillAppear:(BOOL)animated{
    //[super viewWillAppear:<#animated#>];
    NSLog(@"viewWill");
    
    if(vchk==NO){
       [self initSview];
    }
}
-(void)initSview{
    
    vchk=YES;
    
    self.frontView=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 500.0)];
    self.frontView.backgroundColor=[UIColor whiteColor];
    [self.tabBarController.view addSubview:self.frontView];
    
    self.hideView=[[UIView alloc] initWithFrame:CGRectMake(0.0, 480.0, 320.0, 200.0)];
    //self.hideView.backgroundColor=[UIColor orangeColor];
    self.hideView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ver_line.png"]];
    [self.tabBarController.view addSubview:self.hideView];
    
   
    
    header=[[UIView alloc] initWithFrame:CGRectMake(0.0, 20.0, 320.0, 50.0)];
    header.backgroundColor=[UIColor grayColor];
    [self.tabBarController.view addSubview:header];
    
    profileView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
    profileView.frame = CGRectMake(2.0, 2.0, 40.0, 40.0);
    [profileView setUserInteractionEnabled:YES];
    [header addSubview:profileView];
    
    
    toggleButton=[[UIButton alloc] initWithFrame:CGRectMake(140.0, 430.0, 50.0, 50.0)];
    UIImage *img = [UIImage imageNamed:@"btn_swipe.png"];
    [toggleButton setImage:img forState:UIControlStateNormal];
    [toggleButton addTarget:self action:@selector(moveToUpAndDown) forControlEvents:UIControlEventTouchUpInside];
    [img release];
    [self.frontView addSubview:toggleButton];
	
    
    backButton=[[UIButton alloc] initWithFrame:CGRectMake(10.0, 440.0, 40.0, 30.0)];
    UIImage *simg = [UIImage imageNamed:@"btn_back.png"];
    [backButton setImage:simg forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAct) forControlEvents:UIControlEventTouchUpInside];
    [simg release];
    [self.frontView addSubview:backButton];
    
    cameraButton=[[UIButton alloc] initWithFrame:CGRectMake(140.0, 10.0, 50.0, 50.0)];
    
    UIImage *cimg = [UIImage imageNamed:@"btn_camera.png"];
    [cameraButton setImage:cimg forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(onCamera) forControlEvents:UIControlEventTouchUpInside];
    [cimg release];
    [self.hideView addSubview:cameraButton];
    
    [self readyCAAni];
    
	isUp = YES;
    
	UISwipeGestureRecognizer *recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)] autorelease];
	
	recognizer.numberOfTouchesRequired = 1;
	
    recognizer.direction = (UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown);
	[self.frontView addGestureRecognizer:recognizer];
    
    profileView.imageURL = [NSURL URLWithString:[[GlobalStn sharedSingleton] uprofile]];
    NSLog(@"%@",[[GlobalStn sharedSingleton] uprofile]);
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingLocation];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDelegate:self];
    
    //MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
    //geocoder.delegate = self;
    //[geocoder start];
   
        
    timer = [[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(nearAsync) userInfo:nil repeats:YES]retain];
}

-(void)nearAsync{
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
-(void)onCamera{
    NSLog(@"camera");
    [self removeView];
    self.tabBarController.tabBar.hidden = NO; 
    self.tabBarController.selectedIndex = 2;
    //photoPickerViewController *picker=[[photoPickerViewController alloc] init];
    //[self.navigationController pushViewController:picker animated:YES];
    //[picker release];
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
    
    [self.frontView removeFromSuperview];
    [self.hideView removeFromSuperview];
    [self.header removeFromSuperview];
    
    self.frontView = nil;
    self.hideView = nil;
    self.header = nil;
}
- (void)readyCAAni{
    /*
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0, 0, 100, 100);
    maskLayer.backgroundColor = [UIColor grayColor].CGColor;
    maskLayer.contentsGravity = kCAGravityCenter;
    maskLayer.contentsScale = [[UIScreen mainScreen] scale];
    maskLayer.rasterizationScale = [[UIScreen mainScreen] scale];
    //maskLayer.contents = (id)symbolImage.CGImage;
    maskLayer.shouldRasterize = YES;
    maskLayer.opaque = YES;
    
    
     pulseLayer_.backgroundColor = [UIColor grayColor].CGColor;
     pulseLayer_.bounds = CGRectMake(0., 0., 200., 200.);
     pulseLayer_.cornerRadius = 12.;
     //pulseLayer_.mask = maskLayer;
     //pulseLayer_.masksToBounds=YES;
     pulseLayer_.position = self.tabBarController.view.center;
     [pulseLayer_ setNeedsDisplay];
     
     
     
     
     CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
     pulseAnimation.duration = 2.;
     pulseAnimation.fromValue = [NSNumber numberWithFloat:0.35];
     pulseAnimation.toValue = [NSNumber numberWithFloat:1.45];
     
     CABasicAnimation *pulseColorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
     pulseColorAnimation.duration = 1.;
     pulseColorAnimation.fillMode = kCAFillModeForwards;
     pulseColorAnimation.toValue = (id)[UIColor redColor].CGColor;
     
     CABasicAnimation *rotateLayerAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
     rotateLayerAnimation.duration = .5;
     rotateLayerAnimation.beginTime = .5;
     rotateLayerAnimation.fillMode = kCAFillModeBoth;
     rotateLayerAnimation.toValue = [NSNumber numberWithFloat:M_PI];
     
     CAAnimationGroup *group = [CAAnimationGroup animation];
     group.animations = [NSArray arrayWithObjects:pulseAnimation, pulseColorAnimation, rotateLayerAnimation, nil];
     group.duration = 2.;
     group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
     group.autoreverses = YES;
     group.repeatCount = FLT_MAX;
     
     [pulseLayer_ addAnimation:group forKey:nil];
     [self.tabBarController.view.layer addSublayer:pulseLayer_];
     */
    //self.circle = [[withCircle alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
    //self.circle.center = CGPointMake(160, 240);
    //[frontView addSubview:self.circle];
    
    //self.tabBarController.view.layer.backgroundColor = [UIColor orangeColor].CGColor;
    //self.tabBarController.view.layer.cornerRadius = 20.0;
    //self.tabBarController.view.layer.frame = CGRectInset(self.view.layer.frame, 5, 5);
    
    
    
  
    
    CALayer *orbit1 = [CALayer layer];
	orbit1.bounds = CGRectMake(0, 0, 200, 200);
    //orbit1.shadowOffset = CGSizeMake(0, 3);
    //orbit1.shadowRadius = 5.0;
    //orbit1.shadowColor = [UIColor blackColor].CGColor;
    //orbit1.shadowOpacity = 0.8;
	orbit1.position = self.tabBarController.view.center;
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
	CountLayer.position = self.tabBarController.view.center;
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
    [nearCountlabel release];

    [header release];
	[frontView release];
    [cameraButton release];
	[hideView release];
    [locationManager release];
    [newUserLocation release];
	[toggleButton release];
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
		image = [UIImage imageNamed:@"btn_swipeDown.png"];
		isUp = NO;
	}
	else {
		moveCenterY = self.frontView.center.y + MOVE_CENTER_Y;
        hideCenterY = self.hideView.center.y + MOVE_CENTER_Y;
		image = [UIImage imageNamed:@"btn_swipe.png"];
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
