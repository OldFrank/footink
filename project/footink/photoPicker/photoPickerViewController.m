//
// photoPickerViewController.m
// photoPicker
//
// Created by Yongsik Cho on 11. 4. 11..
// Copyright 2011 ag. All rights reserved.
//

#import "photoPickerViewController.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "PhotoRoot.h"
#import <CFNetwork/CFNetwork.h>
#import "GlobalStn.h"
#import "Reachability.h"
#import "photoEditController.h"
//#import "withViewcontroller.h"
#import "WithRootViewController.h"
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

@synthesize imgPicker,scanModal,irisModal;
@synthesize captureManager;
@synthesize scanningLabel;

@synthesize cameraToggleButton;
@synthesize recordButton;
@synthesize focusModeLabel;
@synthesize videoPreviewView,captureVideoPreviewLayer;

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
    }else if((int)[[GlobalStn sharedSingleton] pickerChk]==4){ // with 카메라 촬영 이후 진입
        [[GlobalStn sharedSingleton] setPickerChk:1];
        //[[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        //self.tabBarController.tabBar.hidden = NO;
        self.tabBarController.selectedIndex = 1;
        
        //WithRootViewController *control=[[WithRootViewController alloc] init];
        //control.hidesBottomBarWhenPushed=YES;
        //[self.navigationController pushViewController:control animated:NO];
        
    }else if((int)[[GlobalStn sharedSingleton] pickerChk]==3){ // 카메라 촬영 이후 진입
        [[GlobalStn sharedSingleton] setPickerChk:1];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.tabBarController.tabBar.hidden = NO;
        self.tabBarController.selectedIndex = 0;
    }else{ // close버튼
        
        [[GlobalStn sharedSingleton] setPickerChk:0];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.tabBarController.selectedIndex = 0;
    }
}
- (void) viewWillDisappear:(BOOL)animated {
    //if((int)[[GlobalStn sharedSingleton] pickerChk]!=0){
    //NSLog(@"removeObserver");
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    //}
}
- (void)dealloc
{
    NSLog(@"dealloc");
    [captureManager release];
    captureManager=nil;
    
    [scanModal release];
    scanModal=nil;
    [irisModal release];
    irisModal=nil;
    [imgPicker release], imgPicker=nil;
    
    [videoPreviewView release];
    [captureVideoPreviewLayer release];
    [scanningLabel release];

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
    if (self.captureManager == nil) {
        [self setCaptureManager:[[AvCaptureManager alloc] init]];
    }
    [[self captureManager] setDelegate:self];
    
    if ([[self captureManager] setupSession]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] avsession]];
        irisModal = [[UIViewController alloc] init];
        irisModal.view.backgroundColor=[UIColor blackColor];
        scanModal = [[UIViewController alloc] init];
        scanModal.view.backgroundColor=[UIColor clearColor];
        [irisModal.view addSubview:scanModal.view];
        
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
        
        UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic.png"]];
        [overlayImageView setFrame:CGRectMake(0.0, 0.0, 320, 480)];
        [scanModal.view addSubview:overlayImageView];
        [overlayImageView release];
        self.tabBarController.view.backgroundColor=[UIColor clearColor];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 1.2f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromBottom;
        //transitioning = YES;
        transition.delegate = self;

        [self presentModalViewController:irisModal animated:NO];
        [irisModal.view.layer addAnimation:transition forKey:nil];
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[[self captureManager] avsession] startRunning];
        });
        
        //[self updateButtonStates];
        
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
    [irisModal presentModalViewController:self.imgPicker animated:YES];
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
    [irisModal dismissModalViewControllerAnimated: NO];
    [irisModal release];
    irisModal=nil;
    [scanModal release];
    scanModal=nil;
    [captureManager release];
    captureManager=nil;
}
- (void)StillViewAdd
{
    [irisModal dismissModalViewControllerAnimated: NO];
    
    photoEditController *controller=[[photoEditController alloc] init];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.7f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromLeft;
    //transitioning = YES;
    transition.delegate = self;

    self.navigationController.navigationBarHidden = NO;
    controller.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:controller animated:NO];
    [self.navigationController.view.layer addAnimation:transition forKey:nil];

    UIImage *img=[self generatePhotoThumbnail:[[self captureManager] stillImage] withRatio:300];
    [self saveImage:img named:@"temp"];
    
    [controller release];
    [irisModal release];
    irisModal=nil;
    [scanModal release];
    scanModal=nil;
    [captureManager release];
    captureManager=nil;
  

    /*UIView *parent = scanModal.view;
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
     */
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
        
        rat = ((ratio  * 2) / image.size.width) * 4;
    } else {
        
        rat = ((ratio  * 2) / image.size.height) * 4;
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

- (void)saveImage:(UIImage*)image named:(NSString*)imageName {
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dirPath = [documentsDirectory stringByAppendingPathComponent:@"ImageCache"];
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *fullPath = [dirPath stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@.png", imageName]];
    
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
    NSLog(@"image saved %@",fullPath);
}

- (void)saveImageToPhotoAlbum
{
    [self StillViewAdd];
    //UIImageWriteToSavedPhotosAlbum([[self captureManager] stillImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"이미지 저장 실패" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else {
        //
        //imageview.image=[[self captureManager] stillImage];
        //[self dismissModalViewControllerAnimated: YES];
        
        
        //[[self scanningLabel] setHidden:YES];
    }
}



//라이브러리 사진선택
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    
    [self dismissModalViewControllerAnimated: YES];
    CGRect rect;
    rect = CGRectMake(0.0, 0.0, 300.0, 300.0);
    //imageview.image=[self imageByCropping:img toRect:rect];
    //imageview.image=[self generatePhotoThumbnail:img withRatio:300];
    
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

