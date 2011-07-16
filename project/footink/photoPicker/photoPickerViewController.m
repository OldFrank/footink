//
//  photoPickerViewController.m
//  photoPicker
//
//  Created by Yongsik Cho on 11. 4. 11..
//  Copyright 2011 ag. All rights reserved.
//

#import "photoPickerViewController.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "PhotoRoot.h"
#import <CFNetwork/CFNetwork.h>
#import "GlobalStn.h"
#import "Reachability.h"
static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@interface photoPickerViewController () <UIGestureRecognizerDelegate>
@end


@interface photoPickerViewController (InternalMethods)
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)updateButtonStates;
@end

@interface photoPickerViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
@end


@implementation photoPickerViewController

@synthesize imgPicker,imageview,scanModal,scanView,cAlertView;
@synthesize captureManager;
@synthesize scanningLabel;
@synthesize returnData;
@synthesize cameraToggleButton;
@synthesize recordButton;
@synthesize focusModeLabel;
@synthesize videoPreviewView,captureVideoPreviewLayer;

@synthesize ProgressBar;
@synthesize ProgressLabel,_thread,urlConnection;

BOOL gLogging = FALSE;

- (id) init{
    self=[super init];
    if(self!=nil){
        self.title=@"camera";
        //self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"camera" image:nil tag:1] autorelease];
        //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    return self;
}

- (NSString *)stringForFocusMode:(AVCaptureFocusMode)focusMode
{
	NSString *focusString = @"";
	
	switch (focusMode) {
		case AVCaptureFocusModeLocked:
			focusString = @"locked";
			break;
		case AVCaptureFocusModeAutoFocus:
			focusString = @"auto";
			break;
		case AVCaptureFocusModeContinuousAutoFocus:
			focusString = @"continuous";
			break;
	}
	return focusString;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self AVModal];
}

-(void)viewWillAppear:(BOOL)animated
{
    if((int)[[GlobalStn sharedSingleton] pickerChk]==0){ // 초기진입
        [self AVModal];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [[GlobalStn sharedSingleton] setPickerChk:0];
        
    }else{ // close버튼
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[GlobalStn sharedSingleton] setPickerChk:0];
        self.tabBarController.selectedIndex = 0;
    }
}
- (void) viewWillDisappear:(BOOL)animated {
    NSLog(@"removeObserver");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)dealloc
{
    [captureManager release];
    captureManager=nil;
    [imageview release];
    imageview=nil;
    [scanModal release];
    scanModal=nil;
    [imgPicker release], imgPicker=nil;

    [videoPreviewView release];
	[captureVideoPreviewLayer release];
    [scanningLabel release];
    [ProgressBar release], ProgressBar = nil;
    
    [returnData release];
    [_thread release], _thread=nil;

    [super dealloc];
}

#pragma mark - View lifecycle

-(void)print_free_memory{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);        
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");
    
    /* Stats in bytes */ 
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    NSLog(@"used: %u free: %u total: %u", mem_used, mem_free, mem_total);
}
-(void)AVModal
{
    if ([self captureManager] == nil) {
        AvCaptureManager *manager = [[AvCaptureManager alloc] init];
		[self setCaptureManager:manager];
		[manager release];
    }
    [[self captureManager] setDelegate:self];
    
    if ([[self captureManager] setupSession]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] avsession]];
        scanModal = [[UIViewController alloc] init];
        
        CALayer *viewLayer = [scanModal.view layer];
        [viewLayer setMasksToBounds:YES];
        
        CGRect bounds = [scanModal.view bounds];
        [newCaptureVideoPreviewLayer setFrame:bounds];
        
        if ([newCaptureVideoPreviewLayer isOrientationSupported]) {
            [newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
        }
        [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        
        [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
        [newCaptureVideoPreviewLayer release];
        
        UIImageView *overlayImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic.png"]] autorelease];
        [overlayImageView setFrame:CGRectMake(0.0, 0.0, 320, 480)];
        
        [scanModal.view addSubview:overlayImageView];
        
        [self presentModalViewController:scanModal animated:NO];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[[self captureManager] avsession] startRunning];
        });
        
        [self updateButtonStates];
        
        UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [faceButton setImage:[UIImage imageNamed:@"btn_face.png"] forState:UIControlStateNormal];
        [faceButton setFrame:CGRectMake(250, 10, 60, 25)];
        [faceButton addTarget:self action:@selector(toggleCamera:) forControlEvents:UIControlEventTouchUpInside];
        [scanModal.view addSubview:faceButton];
        
        UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [overlayButton setImage:[UIImage imageNamed:@"btn_shot.png"] forState:UIControlStateNormal];
        [overlayButton setFrame:CGRectMake(115, 440, 89, 30)];
        [overlayButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [scanModal.view addSubview:overlayButton];
        
        UIButton *movButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [movButton setImage:[UIImage imageNamed:@"btn_mov.png"] forState:UIControlStateNormal];
        [movButton setFrame:CGRectMake(195, 440, 88, 32)];
        [movButton addTarget:self action:@selector(toggleRecording:) forControlEvents:UIControlEventTouchUpInside];
        [scanModal.view addSubview:movButton];
        
        UIButton *libButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [libButton setImage:[UIImage imageNamed:@"btn_lib.png"] forState:UIControlStateNormal];
        [libButton setFrame:CGRectMake(10, 440, 30, 30)];
        [libButton addTarget:self action:@selector(getPhoto) forControlEvents:UIControlEventTouchUpInside];
        [scanModal.view addSubview:libButton];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateNormal];
        [closeButton setFrame:CGRectMake(280, 440, 31, 30)];
        [closeButton addTarget:self action:@selector(btnClose) forControlEvents:UIControlEventTouchUpInside];
        [scanModal.view addSubview:closeButton];
        
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 120, 30)];
        [self setScanningLabel:tempLabel];
        [tempLabel release];
        
        /*[scanningLabel setBackgroundColor:[UIColor clearColor]];
         [scanningLabel setFont:[UIFont fontWithName:@"Courier" size: 18.0]];
         [scanningLabel setTextColor:[UIColor redColor]]; 
         [scanningLabel setText:@"Saving..."];
         [scanningLabel setHidden:YES];
         [scanModal.view addSubview:scanningLabel];	
         */
        
        /*
         // Create the focus mode UI overlay
         UILabel *newFocusModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
         [newFocusModeLabel setBackgroundColor:[UIColor clearColor]];
         [newFocusModeLabel setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.50]];
         AVCaptureFocusMode initialFocusMode = [[[captureManager videoInput] device] focusMode];
         [newFocusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:initialFocusMode]]];
         
         [scanModal.view addSubview:newFocusModeLabel];
         [self addObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode" options:NSKeyValueObservingOptionNew context:AVCamFocusModeObserverContext];
         [self setFocusModeLabel:newFocusModeLabel];
         [newFocusModeLabel release];
         
         // Add a single tap gesture to focus on the point tapped, then lock focus
         UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
         [singleTap setDelegate:self];
         [singleTap setNumberOfTapsRequired:1];
         [scanModal.view addGestureRecognizer:singleTap];
         
         // Add a double tap gesture to reset the focus mode to continuous auto focus
         UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
         [doubleTap setDelegate:self];
         [doubleTap setNumberOfTapsRequired:2];
         [singleTap requireGestureRecognizerToFail:doubleTap];
         [scanModal.view addGestureRecognizer:doubleTap];
         
         [doubleTap release];
         [singleTap release];
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageToPhotoAlbum) name:kImageCapturedSuccessfully object:nil];
        
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVCamFocusModeObserverContext) {
       
		[focusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:(AVCaptureFocusMode)[[change objectForKey:NSKeyValueChangeNewKey] integerValue]]]];
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Toolbar Actions
- (IBAction)toggleCamera:(id)sender
{
    [[self captureManager] toggleCamera];
    [[self captureManager] continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

- (IBAction)toggleRecording:(id)sender
{
    [[self recordButton] setEnabled:NO];
    if (![[[self captureManager] recorder] isRecording])
        [[self captureManager] startRecording];
    else
        [[self captureManager] stopRecording];
}

-(void)getPhoto {
    self.imgPicker = [[UIImagePickerController alloc] init];
    self.imgPicker.allowsEditing = YES;
    self.imgPicker.delegate = self;
    
    self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [scanModal presentModalViewController:self.imgPicker animated:YES];

}
- (UIImage *)generatePhotoThumbnail:(UIImage *)image withRatio:(float)ratio {

    // 레티나 예외처리
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(ratio,ratio),NO,0.0);
    } else {
        UIGraphicsBeginImageContext(CGSizeMake(ratio,ratio));
    }
    
    CGContextRef newContext = UIGraphicsGetCurrentContext();
    
    switch (image.imageOrientation)
    {
        case UIImageOrientationUp:
            NSLog(@"Up");
            CGContextTranslateCTM(newContext, 0, 0);
            CGContextRotateCTM(newContext,0*(M_PI/180));
        break;
        case UIImageOrientationRight:
            NSLog(@"Right");
            CGContextTranslateCTM(newContext, 300.0, 0);
            CGContextRotateCTM(newContext,90*(M_PI/180));
        break;
        case UIImageOrientationLeft:
            NSLog(@"Left");
            CGContextTranslateCTM(newContext, 300, 0);
            CGContextRotateCTM(newContext,-90*(M_PI/180));
        break;
        case UIImageOrientationDown:
            NSLog(@"Down");
            CGContextTranslateCTM(newContext, 300, 300);
            CGContextRotateCTM(newContext,180*(M_PI/180));
        break;
        default:
            NSLog(@"Default");
        break;
    }
    
    CGRect cropRect;

    CGFloat rat = 0;
    CGSize size = [image size];
    
    int padding = 20;
    int pictureSize = ratio;
    int startCroppingPosition = 100;
    
    if (size.height > size.width) {
        pictureSize = size.width - (2.0 * padding);
        startCroppingPosition = (size.height - pictureSize) / 2.0; 
    } else {
        pictureSize = size.height - (2.0 * padding);
        startCroppingPosition = (size.width - pictureSize) / 2.0;
    }

    if( image.size.width > image.size.height ) {

       rat = (imageview.frame.size.width / image.size.width) * 4;
     } else {

       rat = (imageview.frame.size.width / image.size.height) * 4;
	 }
    
    if (image.size.width == image.size.height) {
        cropRect = CGRectMake(0.0, 0.0, rat*image.size.width, image.size.height);
    } else if (image.size.width > image.size.height) {
        cropRect = CGRectMake(0.0, 0.0, rat*image.size.height, image.size.height);
    } else {
        cropRect = CGRectMake(startCroppingPosition, padding, pictureSize, pictureSize);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef  scale:1.0 orientation:image.imageOrientation];
    CGImageRelease(imageRef);

    NSData *pngData = UIImagePNGRepresentation(cropped);
    UIImage *ThumbNail    = [[UIImage alloc] initWithData:pngData];
  
    [ThumbNail drawInRect:CGRectMake(0.0, 0.0, ratio, ratio)];
    
    UIImage *newImage    = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [ThumbNail release];

    return newImage;
}
//이미지 리사이즈
-(UIImage *)resizeImage:(UIImage *)image width:(float)resizeWidth height:(float)resizeHeight{
    
    UIGraphicsBeginImageContext(CGSizeMake(resizeWidth, resizeHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, resizeHeight);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, resizeWidth, resizeHeight), [image CGImage]);
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


//이미지 마스킹
-(UIImage *)maskingImage:(UIImage *)image maskImage:(NSString *)_maskImage{
    CGImageRef imageRef = [image CGImage];
    CGImageRef maskRef = [[UIImage imageNamed:_maskImage] CGImage];
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef),
                                        NULL, false);
    CGImageRef masked = CGImageCreateWithMask(imageRef, mask);
    CGImageRelease(mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    return maskedImage;
}

- (IBAction)captureStillImage:(id)sender
{
    [[self captureManager] captureStillImage];

    UIView *flashView = [[UIView alloc] initWithFrame:[[self videoPreviewView] frame]];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [[[self view] window] addSubview:flashView];
    
    [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                         [flashView release];
                     }
     ];
}
- (void)scanButtonPressed {

	[[self scanningLabel] setHidden:NO];
    [[self captureManager] captureStillImage];
}
- (void)btnClose{
    [[GlobalStn sharedSingleton] setPickerChk:2];
    [scanModal dismissModalViewControllerAnimated: NO];
    [scanModal release];
    scanModal=nil;
    [captureManager release];
    captureManager=nil;
    
    NSLog(@"c %d",[scanningLabel retainCount]);
   
}
- (void)StillViewAdd
{

    imageview=[[UIImageView alloc] init];
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    [imageview setFrame:CGRectMake(10.0, 10.0, 300.0, 300.0)];
    [imageview setBackgroundColor:[UIColor blueColor]];

    //imageview.image=[self generatePhotoThumbnail:[[self captureManager] stillImage] withRatio:300.0];
    imageview.image=[[self captureManager] stillImage];
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setImage:[UIImage imageNamed:@"scanbutton.png"] forState:UIControlStateNormal];
    [saveButton setFrame:CGRectMake(130, 440, 60, 30)];
    [saveButton addTarget:self action:@selector(uploadImage) forControlEvents:UIControlEventTouchUpInside];
    
    scanView=[[UIViewController alloc] init];
    scanView.view.backgroundColor = [UIColor whiteColor];
    
    [scanView.view addSubview:imageview];
    [scanView.view addSubview:saveButton];
    
    
    UIView *parent = scanModal.view;
    [scanView.view removeFromSuperview];
    [parent addSubview:scanView.view];

    //QuarzCore
    //애니매이션 객체 생성
    CATransition * transit = [CATransition animation];
    [transit setDelegate:self]; 
    //애니매이션 시간 설정
    [transit setDuration:1.0f];
    //애니메이션 알고르짐 선택 
    [transit setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    //[transit setTimingFunction:UIViewAnimationCurveEaseInOut];
    //애니메이션 타입설정
    //[transit setType:kCATransitionFade];
    //[transit setType:kCATransitionPush];
    //[transit setType:kCATransitionMoveIn];
    //[transit setType:kCATransitionReveal];
    
    //[transit setSubtype:kCATransitionFromTop];
    //[transit setSubtype:kCATransitionFromBottom];
    //[transit setSubtype:kCATransitionFromLeft];
    [transit setSubtype:kCATransitionFromRight];
    
    //문서에 나오지 않는 애니매이션
    //[transit setType:@"pageCurl"];
    //[transit setType:@"pageUnCurl"];
    //[transit setType:@"suckEffect"];
    //[transit setType:@"cameraIris"];
    //[transit setType:@"cameraIrisHollowOpen"];
    //[transit setType:@"cameraIrisHollowClose"];
    [transit setType:@"rippleEffect"];
    //[transit setType:@"oglFlip"];
    
    
    //애니매이션 가동       
    [[parent layer]addAnimation:transit forKey:@"animation_key"];
       
    //[scanModal dismissModalViewControllerAnimated: YES];
    upload.hidden = NO;
    //NSLog(@"modal dismiss");
    [[self scanningLabel] setHidden:YES];
}
- (void)saveImageToPhotoAlbum 
{
    UIImageWriteToSavedPhotosAlbum([[self captureManager] stillImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else {
        //
        //imageview.image=[[self captureManager] stillImage];
        //[self dismissModalViewControllerAnimated: YES];
        [self StillViewAdd];
        upload.hidden = NO;
        [[self scanningLabel] setHidden:YES];
    }
}

-(void)uploadImage{
    NSString *urlString = @"http://footink.com/user/u";
    [self requestUrl:urlString];
    self.ProgressBar = [[UIProgressView alloc]
                                initWithFrame:CGRectMake(10,350,300,90)];
    [self.ProgressBar setProgressViewStyle:UIProgressViewStyleDefault];
    [self.scanView.view addSubview:self.ProgressBar];
    
}


//라이브러리 사진선택
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    
    [self dismissModalViewControllerAnimated: YES];
    CGRect rect;
    rect = CGRectMake(0.0, 0.0, 300.0, 300.0);
    //imageview.image=[self imageByCropping:img toRect:rect];
    imageview.image=[self generatePhotoThumbnail:img withRatio:300];
    upload.hidden = NO;   
}


- (BOOL)requestUrl:(NSString *)url {
    // URL 접속 초기화
    NSData *imageData = UIImageJPEGRepresentation(self.imageview.image,90);
    NSString *urlString = url;
    
    //NSLog(@"%@",urlString);
    CLLocationManager * locationManager = [[CLLocationManager alloc] init];
    
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDelegate:self];
    CLLocation* location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    [locationManager release];
    //coordinate.latitude;         //위도
    //coordinate.longitude;      //경도
    
     NSDate *currentDate=[NSDate date];
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     
     [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
     //timezone설정
     //NSTimeZone *usTimeZone = [NSTimeZone timeZoneWithName:@"US/Pacific"];
     //NSTimeZone *usTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];
     
     
     NSTimeZone *usTimeZone = [NSTimeZone timeZoneWithName:@"Asia/Seoul"];
     [dateFormatter setTimeZone:usTimeZone];
     
     
    NSDateFormatter *gdateFormatter = [[NSDateFormatter alloc] init];
    [gdateFormatter setDateFormat:@"yyyy-MM-dd"];
   
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] 
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:30.0];

    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    

    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //post append
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"lat\"\r\n\r\n%f",coordinate.latitude] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"lon\"\r\n\r\n%f",coordinate.longitude] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"gdate\"\r\n\r\n%@",[gdateFormatter stringFromDate:currentDate]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    //file attach
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@.jpg\"\r\n",[dateFormatter stringFromDate:currentDate]] dataUsingEncoding:NSUTF8StringEncoding]];
 
	[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
    
    [dateFormatter release];
    [gdateFormatter release];
    
    
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:true];   
    if (self.urlConnection) {
        self.returnData = [[NSMutableData data] retain]; // 수신할 데이터를 받을 공간을 마련
        _thread=[[NSThread alloc] initWithTarget:self selector:@selector(startTheBackgroundJob) object:nil];
        [_thread start];
       
    }
    return YES;
}
- (void)startTheBackgroundJob {  
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  

    while ([[NSThread currentThread] isCancelled] == NO) {
		//NSString *t = [NSString stringWithFormat:@"%i",[_label.text intValue] + 1];
		[self performSelectorOnMainThread:@selector(makeMyProgressBarMoving) withObject:NO waitUntilDone:YES];
		[NSThread sleepForTimeInterval:1.0];
	}
    
    [pool release];  
    
}  
- (void)makeMyProgressBarMoving {  
    
    float actual = [self.ProgressBar progress];  


    if (actual < 1) {  
        self.ProgressBar.progress = actual + 0.01; 
    }  
    else upload.hidden = NO;  
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	//NSLog(@"didReceiveResponse");
    /*
    if(connection != urlConnection) return;
	
    //토탈 바이트 (총용량) : 서버에서 받은 Response를 분석해서 다운로드을 파일의 총 용량을 구해온다.
	Total_FileSize = [[NSNumber numberWithLongLong:[response expectedContentLength]] longValue];

    NSLog(@"content-length: %ld bytes", Total_FileSize);
    //self.progressBar.progress = Total_FileSize;  
    if(self.returnData) 
    {
        NSLog(@"Release");
        [self.returnData release];
    }
    
   
    //[self.returnData setLength: 0]; 
    */
    self.returnData = [[NSMutableData alloc] init];
    CurLength = [response expectedContentLength];
    //NSLog(@"%ld",CurLength);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (data != nil) {
        [self.returnData appendData:[[NSData alloc] initWithData:data]];    
    }
    self.ProgressLabel.text = [NSString stringWithFormat:@"%d Bytes",[self.returnData length]];
    if (CurLength <= 0) {
        return;
    }
    self.ProgressBar.progress = [self.returnData length] / CurLength;
    
    NSLog(@"didReceiveData");
    /*
    if(connection != self.urlConnection) return;
	
	//data는 서버의 파일을 조각조각 불러온다. 로컬에서 조각조각 불러온 파일을 붙여서 하나의 파일로 만들어놓는다.
	[self.returnData appendData:data];
	
	//다운받은 파일의 용량을 보여준다. 
	NSNumber* ResponeLength = [NSNumber numberWithUnsignedInteger:[self.returnData length]];
	NSLog(@"Uploading... size : %ld", [ResponeLength longValue]);
    
    
	//총용량
	float FileSize = (float)Total_FileSize;
	
	//다운로드된 데이터 용량
	float Down_Filesize = [ResponeLength floatValue];
	
	NSLog(@"Upload : %f", Down_Filesize / FileSize);
    
	self.progressBar.progress = Down_Filesize / FileSize;
	
	//ProgressLabel.text = [NSString stringWithFormat:@"%ld / %ld", [ResponeLength longValue], Total_FileSize];
     */
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[GlobalStn sharedSingleton] setPickerChk:1];
    [scanModal dismissModalViewControllerAnimated: YES];          
    if(connection != urlConnection) return;
	
    [_thread cancel];
    
    [connection release];
	[self.returnData release];
    self.urlConnection=nil;
    [captureManager release];
    captureManager=nil;
    [imageview release];
    imageview=nil;
    [scanModal release];
    scanModal=nil;
    [scanningLabel release];
 
	//도큐멘트 폴더로 파일저장
	/*NSFileManager* FM = [NSFileManager defaultManager];
	
	//[iPhone] 파일 시스템 (Document Directory 경로찾기)
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];        
	NSString *downloadPath = [documentsDirectory stringByAppendingPathComponent:@"FileName"];
	//downloadPath를 콘솔에서 확인 후 그 위치에서 파일을 확인하세요~~~
	
	if([FM createFileAtPath:downloadPath contents:returnData attributes:nil])
	{
		NSLog(@"데이터저장성공");
	}
	
	//데이터삭제
	if(returnData) 
	{
		NSLog(@"Release");
		[returnData release];
	}*/
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //에러에 관해서 처리..
    [connection release];
    [returnData release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

@implementation photoPickerViewController (InternalMethods)


- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates 
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    if ([[[self captureManager] previewLayer] isMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }    
    
    if ( [[[[self captureManager] previewLayer] videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[[[self captureManager] previewLayer] videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[[[self captureManager] previewLayer] videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported]) {
        CGPoint tapPoint = [gestureRecognizer locationInView:[self videoPreviewView]];
        CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
        [captureManager autoFocusAtPoint:convertedFocusPoint];
    }
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported])
        [captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

// Update button states based on the number of available cameras and mics
- (void)updateButtonStates
{
	NSUInteger cameraCount = [[self captureManager] cameraCount];
	NSUInteger micCount = [[self captureManager] micCount];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        if (cameraCount < 2) {
            [[self cameraToggleButton] setEnabled:NO]; 
            
            if (cameraCount < 1) {
                //[[self stillButton] setEnabled:NO];
                
                if (micCount < 1)
                    [[self recordButton] setEnabled:NO];
                else
                    [[self recordButton] setEnabled:YES];
            } else {
                //[[self stillButton] setEnabled:YES];
                [[self recordButton] setEnabled:YES];
            }
        } else {
            [[self cameraToggleButton] setEnabled:YES];
            //[[self stillButton] setEnabled:YES];
            [[self recordButton] setEnabled:YES];
        }
    });
}

@end

@implementation photoPickerViewController (AVCamCaptureManagerDelegate)

- (void)captureManager:(AvCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });
}

- (void)captureManagerRecordingBegan:(AvCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self recordButton] setTitle:NSLocalizedString(@"Stop", @"Toggle recording button stop title")];
        [[self recordButton] setEnabled:YES];
    });
}

- (void)captureManagerRecordingFinished:(AvCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self recordButton] setTitle:NSLocalizedString(@"Record", @"Toggle recording button record title")];
        [[self recordButton] setEnabled:YES];
    });
}
/*
- (void)captureManagerStillImageCaptured:(AvCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self stillButton] setEnabled:YES];
    });
}
*/
- (void)captureManagerDeviceConfigurationChanged:(AvCaptureManager *)captureManager
{
	[self updateButtonStates];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end


