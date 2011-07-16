//
//  SpotInkletSubmit.m
//  photoPicker
//
//  Created by yongsik on 11. 7. 1..
//  Copyright 2011 ag. All rights reserved.
//

#import "SpotInkletSubmit.h"


@implementation SpotInkletSubmit
@synthesize progressBar,ProgressLabel,returnData,pickerView,arrayColors;

- (void)viewDidLoad{
    UIView *inkletFrm=[[[UIView alloc] init] autorelease];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(20.0, 50.0, 60.0,40.0)];
    titleLabel.text=@"제목";
    [inkletFrm addSubview:titleLabel];
    
    UITextField *tInput = [[UITextField alloc] initWithFrame:CGRectMake(70.0, 55.0, 220.0, 30.0)];
    [tInput setBorderStyle:UITextBorderStyleRoundedRect];
    [inkletFrm addSubview:tInput];
    
    UILabel *commentLabel=[[UILabel alloc] initWithFrame:CGRectMake(20.0, 95.0, 60.0,40.0)];
    commentLabel.text=@"내용";
    [inkletFrm addSubview:commentLabel];

    UITextField *commentInput = [[UITextField alloc] initWithFrame:CGRectMake(70.0, 95.0, 220.0, 150.0)];
    [commentInput setBorderStyle:UITextBorderStyleRoundedRect];
    [inkletFrm addSubview:commentInput];
    
    [self.view addSubview:inkletFrm];
    
    arrayColors = [[NSMutableArray alloc] init];
    [arrayColors addObject:@"Red"];
    [arrayColors addObject:@"Orange"];
    [arrayColors addObject:@"Yellow"];
    [arrayColors addObject:@"Green"];
    [arrayColors addObject:@"Blue"];
    [arrayColors addObject:@"Indigo"];
    [arrayColors addObject:@"Violet"];

    pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 480, 320, 0)];  
    //일부러 뷰밖에서 생성한다.
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    [self.view addSubview:pickerView];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    pickerView.transform = CGAffineTransformMakeTranslation(0, -275); //위로 쭈욱하고 올라온다.
    [UIView commitAnimations];
    [self pickerView:pickerView didSelectRow:4 inComponent:0];//자동으로 처음값을 설정

}

- (void)dealloc
{
    [pickerView release];
    [arrayColors release];
    [super dealloc];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [arrayColors count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [arrayColors objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //[UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:0.5];
    //pickerView.transform = CGAffineTransformMakeTranslation(0, 275); //그냥 아래로 다시 내려주자
   // [UIView commitAnimations];
    
    NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayColors objectAtIndex:row], row);
}
- (BOOL)requestUrl:(NSString *)url {
    // URL 접속 초기화
    //NSData *imageData = UIImageJPEGRepresentation(self.imageview.image,90);
    NSString *urlString = url;
    
    //NSLog(@"%@",urlString);
    CLLocationManager * locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
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
    
    
    
    NSLog(@"date %@",[dateFormatter stringFromDate:currentDate]);
    NSLog(@"gdate %@",[gdateFormatter stringFromDate:currentDate]);
    
    NSLog(@"coordinate %f",coordinate.longitude);
    NSLog(@"did %@",[[UIDevice currentDevice] uniqueIdentifier]);
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
    //                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
    //                                                   timeoutInterval:60.0];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    [request setURL:[NSURL URLWithString:urlString]];
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
	//[body appendData:[NSData dataWithData:imageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
    
    [dateFormatter release];
    [gdateFormatter release];
    
    urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];   
    if (urlConnection) {
        //self.returnData = [[NSMutableData data] retain]; // 수신할 데이터를 받을 공간을 마련
        
        [NSThread detachNewThreadSelector:@selector(startTheBackgroundJob) toTarget:self withObject:nil];
        
        
    }
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
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
    
    self.returnData = [[NSMutableData alloc] init];
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(connection != urlConnection) return;
	
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
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //imageview.image = nil;
    //[scanModal dismissModalViewControllerAnimated: YES];          
    if(connection != urlConnection) return;
	NSLog(@"complete");
    
    if([[UIApplication sharedApplication] respondsToSelector:@selector(setStatusBarHidden: withAnimation:)])
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    else 
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
    
    self.tabBarController.selectedIndex = 0;
	
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
