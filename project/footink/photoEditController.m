//
//  photoEditController.m
//  footink
//
//  Created by yongsik on 11. 7. 18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "photoEditController.h"
#import "GlobalStn.h"

@implementation photoEditController


@synthesize filterImageView;
@synthesize imageview;
@synthesize  connection;
@synthesize response;
@synthesize responseData;

- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"viewdid");
    NSLog(@"t %d",[self.imageview retainCount]);
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.tabBarController.tabBar.hidden = YES; 
    
    self.imageview=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mask.png"]];
    self.imageview.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageview setFrame:CGRectMake(10.0, 10.0, 300.0, 300.0)];
    [self.imageview setBackgroundColor:[UIColor blueColor]];
    
    [self.view addSubview:self.imageview];
    
    //imageview.image=[[self captureManager] stillImage];
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setImage:[UIImage imageNamed:@"scanbutton.png"] forState:UIControlStateNormal];
    [saveButton setFrame:CGRectMake(130, 400, 80, 50)];
    [saveButton addTarget:self action:@selector(uploadImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];

    
    UIScrollView *filterView=[[UIScrollView alloc] initWithFrame:CGRectMake(10.0, 320.0, 300.0, 50.0)];
    [filterView setBackgroundColor:[UIColor lightGrayColor]];
    [filterView setCanCancelContentTouches:NO];
    
    filterView.showsVerticalScrollIndicator=NO;
    filterView.showsHorizontalScrollIndicator=NO;
    filterView.alwaysBounceVertical=NO;             
    filterView.alwaysBounceHorizontal=NO;         
    filterView.pagingEnabled=YES;          //페이징 가능 여부 YES
    filterView.delegate=self;
    
    [self.view addSubview:filterView];
    

    for (int i = 0; i <= 5; i++)
    {
        
        
        filterImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_80.png"]];
        
        CGRect rect =  filterImageView.frame;
        rect.size.height = 50;
        rect.size.width = 50;
        filterImageView.frame = rect;
        [filterImageView setUserInteractionEnabled:YES];
        filterImageView.tag = i;
        
        UIButton *button = [[UIButton alloc]init];
        
        button.frame = rect;
        button.tag = i;
        [button setImage:[UIImage imageNamed:@"blank_80.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(filterWrap:) forControlEvents:UIControlEventTouchUpInside];
        
        [filterImageView addSubview:button];
        
        [button release];
        
        [filterView addSubview:filterImageView];
    }
    [filterView release];
    
    uploadProgress=[[UIProgressView alloc] initWithFrame:CGRectMake(90.0, 300.0, 200.0, 20.0)];
    [self.view addSubview:uploadProgress];
    
    uploadProgressMessage=[[UILabel alloc] initWithFrame:CGRectMake(90.0, 320.0, 150.0, 30.0)];
    uploadProgressMessage.textAlignment = UITextAlignmentLeft;
    uploadProgressMessage.text=@"ready";
    uploadProgressMessage.font=[UIFont systemFontOfSize:12.0f];
    [self.view addSubview:uploadProgressMessage];

    
}
-(void)setImageData:(UIImage *)img{
    NSLog(@"setImageData");
    self.imageview.image=[self generatePhotoThumbnail:img withRatio:300.0];
}
-(void)filterWrap:(id)sender{
    NSLog(@"filterWrap");
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
        
        rat = (self.imageview.frame.size.width / image.size.width) * 4;
    } else {
        
        rat = (self.imageview.frame.size.width / image.size.height) * 4;
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
-(void)uploadImage{
    NSLog(@"uploadImage");
    NSString *urlString = @"http://footink.com/user/u";
    [self requestUrl:urlString];
    
}
- (BOOL)requestUrl:(NSString *)url {
    // URL 접속 초기화
    NSLog(@"requestUrl");
    uploadProgress.progress = 0.0f;
    uploadProgressMessage.text = @"uploading";
    
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
    
    self.responseData = [NSMutableData data];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];

    return YES;
}


// Final event, memory is cleaned up at the end of this.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.connection = nil;
    self.response = nil;
    
    uploadProgress.progress = 0.0f;
    uploadProgressMessage.text = @"An error occurred, retrying in 10 seconds...";
    
    retryCounter = 10;
    [self performSelector:@selector(retry) withObject:nil afterDelay:1.0f];
}


// Final event, memory is cleaned up at the end of this.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.connection = nil;
    
    id stringReply;
    stringReply = (NSString *)[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"reply from server: %@", stringReply);
    //NSURLResponse *lresponse;
    NSHTTPURLResponse *httpResponse;
    httpResponse = (NSHTTPURLResponse *)self.response;
    
    NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]); 
    NSLog(@"HTTP Status code: %d", [self.response statusCode]);
    
    if ([self.response statusCode] == 200) {
        uploadProgress.progress = 1.0f;
        
        /*NSString *responseString = [[[NSString alloc] initWithBytes:[self.responseData bytes]
         length:[self.responseData length]
         encoding:NSUTF8StringEncoding] autorelease];
         responseString =
         [responseString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         
         NSString *successContinueUrl = CONTINUE_URL;
         
         successContinueUrl =
         [successContinueUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         
         BOOL hasQuestionMark = [successContinueUrl rangeOfString:@"?"].location != NSNotFound;
         
         successContinueUrl =
         [successContinueUrl stringByAppendingString:hasQuestionMark ? @"&" : @"?"];
         successContinueUrl = [successContinueUrl stringByAppendingFormat:@"success=1&response=%@",
         responseString];
         
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:successContinueUrl]];
         */
        //self.jsonArray=[stringReply JSONValue];
       // [self AddAuthRecord];
        //[self.navigationController popViewControllerAnimated:YES];
        NSLog(@"s %d",[self.imageview retainCount]);
        [self.imageview release];
        self.imageview=nil;
         NSLog(@"e %d",[self.imageview retainCount]);
        [[GlobalStn sharedSingleton] setPickerChk:3];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        uploadProgress.progress = 0.0f;
        uploadProgressMessage.text = @"An error occurred, retrying in 10 seconds...";
        
        retryCounter = 10;
        [self performSelector:@selector(retry) withObject:nil afterDelay:1.0f];
    }
    
    self.response = nil;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)newData {
    [responseData appendData:newData];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)newResponse {
    self.response = (NSHTTPURLResponse *) newResponse;
}
- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    uploadProgress.progress = (float) totalBytesWritten / totalBytesExpectedToWrite;
}
- (void)retry {
    retryCounter--;
    
    if (retryCounter <= 0) {
        [self uploadImage];
    } else {
        uploadProgressMessage.text =
        [NSString stringWithFormat:@"An error occurred, retrying in %d second%@...",
         retryCounter,
         retryCounter != 1 ? @"s" : @""];
        
        [self performSelector:@selector(retry) withObject:nil afterDelay:1.0f];
    }
}

- (void)dealloc
{

    [connection release];
    connection=nil;
    [response release];
    response=nil;
    [responseData release];
    responseData=nil;
    
    [imageview release];
    imageview=nil;
    [filterImageView release];
    filterImageView=nil;
    
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
