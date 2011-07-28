//
//  ProfileViewController.m
//  photoPicker
//
//  Created by yongsik on 11. 7. 10..
//  Copyright 2011 ag. All rights reserved.
//

#import "ProfileViewController.h"
#import "Reachability.h"
#import "JSON.h"
#import "EGOImageView.h"
#import "GlobalStn.h"
#import "ProfileImageCell.h"
#import "PicViewController.h"

#define FOLLOWCHK_URL @"http://footink.com/user/followchk"
#define USERPROFILE_URL @"http://footink.com/user/userDetail"
#define USER_PHOTO_URL @"http://footink.com/user/personal"
#define FOLLOW_SUBMIT_URL @"http://footink.com/user/followsubmit"

@implementation ProfileViewController
@synthesize profileTable;
@synthesize jsonArray,uidx;

@synthesize connection;
@synthesize imageData;
@synthesize response;
@synthesize responseData;
@synthesize follow;
@synthesize uname;
@synthesize follower;
@synthesize header;
@synthesize followBtn;
@synthesize indicator;
@synthesize progressBack;

@synthesize scrollView;
@synthesize viewControllers;

- (void)viewDidLoad
{
    header=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 100.0)];
    header.backgroundColor=[UIColor grayColor];
    [self.view addSubview:header];
    [header release];
    
    profileView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
    profileView.frame = CGRectMake(10.0, 10.0, 80.0, 80.0);
    [profileView setUserInteractionEnabled:YES];
    [header addSubview:profileView];

    uname=[[UITextField alloc] initWithFrame:CGRectMake(100.0,10.0,100.0, 30.0)];
    uname.text=@"";
    uname.textColor=[UIColor whiteColor];
    uname.font=[UIFont fontWithName:@"verdana" size:11.0f];
    
    [header addSubview:uname];
    
    UILabel *flabel=[[UILabel alloc] initWithFrame:CGRectMake(100.0, 30.0, 60.0, 30.0)];
    flabel.textColor=[UIColor whiteColor];
    flabel.backgroundColor=[UIColor clearColor];
    flabel.font=[UIFont fontWithName:@"verdana" size:11.0f];
    flabel.text=@"follow";
    [header addSubview:flabel];
    
    follow=[[UITextField alloc] initWithFrame:CGRectMake(140.0,38.0,100.0, 30.0)];
    follow.text=@"0";
    follow.textColor=[UIColor whiteColor];
    follow.font=[UIFont fontWithName:@"verdana" size:11.0f];
    [header addSubview:follow];
    
    UILabel *ferlabel=[[UILabel alloc] initWithFrame:CGRectMake(190.0, 30.0, 60.0, 30.0)];
    ferlabel.textColor=[UIColor whiteColor];
    ferlabel.backgroundColor=[UIColor clearColor];
    ferlabel.font=[UIFont fontWithName:@"verdana" size:11.0f];
    ferlabel.text=@"follower";
    [header addSubview:ferlabel];
    
    follower=[[UITextField alloc] initWithFrame:CGRectMake(240.0,38.0,100.0, 30.0)];
    follower.text=@"0";
    follower.textColor=[UIColor whiteColor];
    follower.font=[UIFont fontWithName:@"verdana" size:11.0f];
    [header addSubview:follower];
    
    followBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    followBtn.frame = CGRectMake(200, 60, 80, 30);
    followBtn.tag=(int)self.uidx;
    followBtn.backgroundColor = [UIColor clearColor];
    [followBtn setTitle:@"follow" forState:UIControlStateNormal];
    [followBtn addTarget:self action:@selector(followSubmit:)
        forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:followBtn];
    
    NSMutableArray *regVal = [[NSMutableArray alloc] init];
    //[regVal addObject:(NSInteger *)self.uidx];
    [regVal addObject:[[GlobalStn sharedSingleton] ukey]];
    
    [self HttpAuth:regVal];
    [regVal release];

    
        //[self loadPage:0];
    //[self loadPage:1];
     
       
    //[self getPersonalList];
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
    
}
-(void)getPersonalList:(NSMutableArray *)personalValue{
    NSDictionary *dic;
    dic = [[NSDictionary alloc] initWithObjectsAndKeys:[[GlobalStn sharedSingleton] uname],@"uname" , @"이메일이다.", @"email", nil];
    NSMutableArray *valueData=[NSMutableArray array];
    [valueData addObject:dic];
    
    CGRect progressframe=CGRectMake(10.0, 5.0, 200.0, 20.0);
    NSString *geturl=[NSString stringWithFormat:@"%@",USER_PHOTO_URL];
    progressbar=[[HttpWrapper alloc] requestUrl:geturl values:valueData progressBarFrame:(CGRect)progressframe image:nil loc:nil delegate:self];
    NSLog(@"---%@",geturl);
    [self.progressBack addSubview:progressbar];
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFinishWithData:(NSData *)fileData{
    id stringReply;
    stringReply = (NSString *)[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    self.jsonArray=[stringReply JSONValue];
    [self.profileTable reloadData];
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFailWithError:(NSError *)error{
    NSLog(@"error %@",error);
}
- (void)httpBarUpdated:(HttpWrapper *)httpProgBar{
    
}
-(void)followAsync{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FOLLOWCHK_URL] 
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [NSString stringWithString:@"-----------14737809831466499882746641449"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //post append
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uname\"\r\n\r\n%@",[[GlobalStn sharedSingleton] uname]] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"fname\"\r\n\r\n%@",[[self.jsonArray objectAtIndex:0] objectForKey:@"name"]] dataUsingEncoding:NSUTF8StringEncoding] ];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    [request setHTTPBody:body];
    
    NSURLResponse *iresponse;
    NSHTTPURLResponse *httpResponse;
    NSError *error;
    
    id stringReply;
    
    NSData *datareply=[NSURLConnection sendSynchronousRequest:request returningResponse:&iresponse error:&error];
    stringReply = (NSString *)[[NSString alloc] initWithData:datareply encoding:NSUTF8StringEncoding];

    httpResponse = (NSHTTPURLResponse *)response;
    int statusCode = [httpResponse statusCode];  
    //NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]); 
    NSLog(@"HTTP Status code: %d", statusCode);
    
    if(statusCode==200) {
        NSLog(@"followchk %@",stringReply);
       
        if( [[[GlobalStn sharedSingleton] ukey] isEqualToString:[[self.jsonArray objectAtIndex:0] objectForKey:@"ukey"]] ){
        }else{
            int chk;
            chk=[stringReply intValue];
            
            if(chk>0){
                [followBtn setTitle:@"unfollow" forState:UIControlStateNormal];
                followBtn.tag=0;
            }
        }

    }else{
        NSLog(@"http 오류.");
    }
}
-(void)followSubmit:(id)sender{
    NSLog(@"followsubmit %@",[sender tag]);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FOLLOW_SUBMIT_URL] 
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [NSString stringWithString:@"-----------14737809831466499882746641449"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //post append
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"action\"\r\n\r\n%d",[sender tag]] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uname\"\r\n\r\n%@",[[GlobalStn sharedSingleton] uname]] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"fname\"\r\n\r\n%@",[[self.jsonArray objectAtIndex:0] objectForKey:@"name"]] dataUsingEncoding:NSUTF8StringEncoding] ];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    
    [request setHTTPBody:body];
    
    NSURLResponse *iresponse;
    NSHTTPURLResponse *httpResponse;
    NSError *error;
    
    id stringReply;
    
    NSData *datareply=[NSURLConnection sendSynchronousRequest:request returningResponse:&iresponse error:&error];
    stringReply = (NSString *)[[NSString alloc] initWithData:datareply encoding:NSUTF8StringEncoding];
    
    httpResponse = (NSHTTPURLResponse *)iresponse;
    int statusCode = [httpResponse statusCode];  

    
    NSLog(@"submit %@ %@ %d",[[GlobalStn sharedSingleton] uname],[[self.jsonArray objectAtIndex:0] objectForKey:@"name"],[sender tag]);
    if(statusCode==200) {
        if( [[[GlobalStn sharedSingleton] ukey] isEqualToString:[[self.jsonArray objectAtIndex:0] objectForKey:@"ukey"]] ){
       
        }else{
            int c;
            if([sender tag]==0){
                c=[follower.text intValue] - 1;
                [followBtn setTitle:@"follow" forState:UIControlStateNormal];
            }else{
                c=[follower.text intValue] + 1;
                [followBtn setTitle:@"unfollow" forState:UIControlStateNormal];
            }
            follower.text=[NSString stringWithFormat:@"%d",c];
        }
    }else{
        NSLog(@"http 오류.");
    }

}
-(void)profilerewrite{
    profileView.imageURL = [NSURL URLWithString:[[self.jsonArray objectAtIndex:0] objectForKey:@"pimg"]];
    uname.text=[[self.jsonArray objectAtIndex:0] objectForKey:@"name"];
    follow.text=[[self.jsonArray objectAtIndex:0] objectForKey:@"follow"];
    follower.text=[[self.jsonArray objectAtIndex:0] objectForKey:@"follower"];
    
    NSLog(@"%@ == %@",[[GlobalStn sharedSingleton] ukey],[[self.jsonArray objectAtIndex:0] objectForKey:@"ukey"]);
    NSLog(@"%@",self.jsonArray);
    if( [[[GlobalStn sharedSingleton] ukey] isEqualToString:[[self.jsonArray objectAtIndex:0] objectForKey:@"ukey"]] )
        followBtn.hidden = true;
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [self.jsonArray count]; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    [controllers release];
	
    scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(13.0,105.0, 320.0, 300.0)];
    scrollView.backgroundColor=[UIColor whiteColor];
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
	
    [self.view addSubview:scrollView];
    
    float h=0;
    float pos=0;
    int sn=0;
    int cn=1;
    int gap=10;
    for(int x=0;x<[[self.jsonArray objectAtIndex:1] count];x++){
        
        imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
        imageView.frame = CGRectMake(pos, h, 50.0, 50.0);
        [imageView setUserInteractionEnabled:YES];
        [scrollView addSubview:imageView];
        
        imageView.imageURL = [NSURL URLWithString:[[[self.jsonArray objectAtIndex:1] objectAtIndex:x] objectForKey:@"img"]];
        sn = x + 1;
        if(sn%5==0){
            pos=0;
            h=(50.0 + gap) * cn;
            cn++;
        }else{
            pos=(50.0 + gap) * (sn%5);
        }
        
        NSLog(@"-- %d",sn%5);
       

    }
   
    [self followAsync];
    //[self.profileTable reloadData];
}
-(BOOL)HttpAuth:(NSMutableArray *)regValue{
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    if (netStatus==NotReachable) {
        UIAlertView *uAlert=[[UIAlertView alloc] initWithTitle:@"네트워크 오류" message:@"인터넷이 연결되어 있지 않습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [uAlert show];
        return FALSE;
    }else{
        uploadProgress.progress = 0.0f;
        uploadProgressMessage.text = @"uploading";
        
        NSArray *recvData=regValue;

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        //timezone설정
        //NSTimeZone *usTimeZone = [NSTimeZone timeZoneWithName:@"US/Pacific"];
        //NSTimeZone *usTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        
        NSTimeZone *usTimeZone = [NSTimeZone timeZoneWithName:@"Asia/Seoul"];
        [dateFormatter setTimeZone:usTimeZone];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:USERPROFILE_URL] 
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:30.0];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = [NSString stringWithString:@"-----------14737809831466499882746641449"];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //post append
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uidx\"\r\n\r\n%@",self.uidx] dataUsingEncoding:NSUTF8StringEncoding] ];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"ownerkey\"\r\n\r\n%@",[recvData objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding] ];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
        
        [request setHTTPBody:body];
   
        self.responseData = [NSMutableData data];
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        
        
        //if(stringReply==nil) return FALSE;
        
        //if(stringReply!=nil && statusCode==200) {
        //    self.jsonArray=[stringReply JSONValue];
        //     NSLog(@"%@",self.jsonArray);
        // }else{
        //    NSLog(@"http 오류.");
        //}
    }
    return TRUE;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	return [[self.jsonArray objectAtIndex:1] count];
}
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%@",[self.jsonArray objectAtIndex:1]);
        return [[self.jsonArray objectAtIndex:1] count];
   
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
 
     title = @"test";
 
	return title;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section] != nil) {
        return 80;
    } else {
        return 0;
    }
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (indexPath.section == 0 && indexPath.row == 0) {     
      return 300;
   }
   return 300;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor whiteColor];
    
    static NSString *CellID = @"CIdentifier";
    
    ProfileImageCell *cell = (ProfileImageCell *)[tableView dequeueReusableCellWithIdentifier:CellID]; // changed this
	
	if (cell == nil) {
		cell = [[[ProfileImageCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellID] autorelease]; // changed this
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

    /*if(cell == nil) {
        cell =  [[[UITableViewCell alloc] 
                  initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
        imageView.frame = CGRectMake(10.0, 10.0, 200.0, 200.0);
        [imageView setUserInteractionEnabled:YES];
        [cell addSubview:imageView];
    }
    //cell.textLabel.text=[[self.jsonArray objectAtIndex:indexPath.row] objectForKey:@"name"];
   
     imageView.imageURL = [NSURL URLWithString:[[[self.jsonArray objectAtIndex:1] objectAtIndex:indexPath.row] objectForKey:@"img"]];
     */
    
    NSDictionary *itemAtIndex = (NSDictionary *)[self.jsonArray objectAtIndex:indexPath.row];
	[cell setData:itemAtIndex];
    
    NSLog(@"--%d - %@",indexPath.section,[[[self.jsonArray objectAtIndex:1] objectAtIndex:indexPath.row]objectForKey:@"img"]);
    return cell;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%d",indexPath.row);
    //id rowObject = [myArray objectAtIndex:indexPath.row];
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
    
    NSLog(@"profile reply from server: %@", stringReply);
    //NSURLResponse *lresponse;
    NSHTTPURLResponse *httpResponse;
    httpResponse = (NSHTTPURLResponse *)self.response;
    
    NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]); 
    NSLog(@"HTTP Status code: %d", [self.response statusCode]);
    
    if ([self.response statusCode] == 200) {
        uploadProgress.progress = 1.0f;
        
        self.jsonArray=[stringReply JSONValue];
        
        [self profilerewrite];
        //[self dismissModalViewControllerAnimated:YES];
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
        //[self sendLogin];
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
    [indicator release];
    [uname release];
    [follow release];
    [follower release];
    [profileView release];
    [jsonArray release],jsonArray=nil;
    [followBtn release];
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
