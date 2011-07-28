//
//  PhotoRoot.m
//  photoPicker
//
//  Created by yj on 11. 4. 15..
//  Copyright 2011 ag. All rights reserved.
//

#import "PhotoRoot.h"
#import "footinkAppDelegate.h"

#import "photoDetailView.h"
#import "JSON.h"
#import "GlobalStn.h"
#include <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "UIImageView+AsyncAndCache.h"
#import "PopAlertView.h"
#import "Reachability.h"

#import "PhotoCalCell.h"
#import "PhotoRootCellBtn.h"
#import "PhotoLargeCell.h"
#import "EGOImageView.h"

#import <mach/mach.h>
#import <mach/mach_host.h>
#import "ProfileViewController.h"

#import "CommentView.h"

#define PHOTO_LOVED_POST_URL @"http://footink.com/user/loved"

@implementation UINavigationBar (pCustomImage)

- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed: @"barbackground.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end

@implementation PhotoRoot

const CGFloat kScrollObjHeight2	= 80.0;
const CGFloat kScrollObjWidth2	= 80.0;
const NSUInteger kNumImages2		= 5;
const CGFloat SectionHeaderHeight = 26.0;

@synthesize jsonArray,scrollView1,cellContentView;
@synthesize photoTable,jsonCalArray,activeDownload,imageConnection,downImage;
@synthesize indicatior,lView,lovedArray;

- (id) init{
    
    self=[super init];
    if(self!=nil){
        self.title=@"Foot Ink";
    }
    return self;
}
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

-(void)viewDidLoad{

        [super viewDidLoad];
       
    //if([[UIScreen mainScreen] respondsToSelector:@selector(applicationFrame)]){
        
    //}
    
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        UIImageView *logoimage=[[UIImageView alloc]initWithFrame:CGRectMake(0,0,85,22)] ;
        [logoimage setImage:[UIImage imageNamed:@"footink_logo.png"]];
        [self.navigationController.navigationBar.topItem setTitleView:logoimage];
        [logoimage release];
        /*UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
         [button setImage:[UIImage imageNamed:@"list_thumb.png"] forState:UIControlStateNormal];
         [button addTarget:self action:@selector(blah) forControlEvents:UIControlEventTouchUpInside];
         [button setFrame:CGRectMake(0, 0, 40, 40)];
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
         */
        
        UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,80.0, 40.0)];
        
        UIButton *button =  [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:@"list_normal.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(sortingList:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:0];
        [button setFrame:CGRectMake(0, 0, 50, 40)];
        
        [container addSubview:button];
        [button release];
        
        UIButton *button2 =  [[UIButton alloc] init];
        [button2 setImage:[UIImage imageNamed:@"list_thumb.png"] forState:UIControlStateNormal];
        [button2 addTarget:self action:@selector(sortingList:) forControlEvents:UIControlEventTouchUpInside];
        [button2 setTag:1];
        [button2 setFrame:CGRectMake(40, 0, 50, 40)];
        
        [container addSubview:button2];
        [button2 release];
        
        UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:container];
        
        self.navigationItem.rightBarButtonItem = item;
        [item release];
        
        
        //[self loadingAlert];
        nindex=0; ///클릭된 indexpath.row 
        onOffCell=FALSE; // 셀 클릭시 True
        prevTrueCell=FALSE;
        
        self.photoTable=[[[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 360.0) style:UITableViewStylePlain] autorelease];
        self.photoTable.dataSource=self;
        self.photoTable.delegate=self;
        [self.view addSubview:self.photoTable];
        

        if (_refreshHeaderView == nil) {
            
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.photoTable.bounds.size.height, self.view.frame.size.width, self.photoTable.bounds.size.height)];
            view.delegate = self;
            [self.photoTable addSubview:view];
            _refreshHeaderView = view;
            [view release];
            
        }else{
            
        }
        sort_no=0;
        
        timer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(OnTimer:) userInfo:nil repeats:NO]retain];   
   
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"%d",[[GlobalStn sharedSingleton] pickerChk]);
    
    
    [self print_free_memory];
    if((int)[[GlobalStn sharedSingleton] pickerChk]==1){
        [self viewWillLoading];
    }
}
-(void)viewWillLoading{
    
    [self.photoTable setContentOffset:CGPointMake(0, -60) animated:YES];
    lView=[[UIView alloc] initWithFrame:CGRectMake(0.0, -60.0, 320.0, 60.0)];
    lView.backgroundColor=[UIColor blackColor];
    lView.tag=333;
    [self.photoTable addSubview:lView];
    
    indicatior = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(150.0, 5.0, 30, 30)];
    [indicatior setBackgroundColor:[UIColor clearColor]];
    [indicatior setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [lView addSubview:indicatior];
    [indicatior startAnimating];

    
    [self performSelector:@selector(OnTimer:) withObject:nil afterDelay :2.0f];
    
  
}
- (int)checkNetwork{
    // 네트워크의 상태를 체크.
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    int status= 0;
    
    // 상태에 맞는 메세지
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
- (void)loadingAlert{
    UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(50.0, 90, 30, 30)];
    progressView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    progressView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin);
    
    [self showAlert:@"Loading"];                 
    [alert addSubview:progressView];
    [progressView startAnimating];
    
}
-(void)jsonLoad
{
    if ([self checkNetwork]==0) {
        [self hideAlert];
        [self showAlert:@"네트워크오류."];
    }else{
       
       
       NSString *url;
            
       url=@"http://footink.com/user/t";
            
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] 
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:30.0];
            
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = [NSString stringWithString:@"-----------14737809831466499882746641449"];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //post append
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"privatekey\"\r\n\r\n%@",[[GlobalStn sharedSingleton] ukey]] dataUsingEncoding:NSUTF8StringEncoding] ];

       NSURLResponse *response;
       NSHTTPURLResponse *httpResponse;
       NSError *error;
        NSLog(@"%@",[[GlobalStn sharedSingleton] ukey]);
       id stringReply;
            
       NSData *datareply=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
       stringReply = (NSString *)[[NSString alloc] initWithData:datareply encoding:NSUTF8StringEncoding];
            
            // Some debug code, etc.
       //NSLog(@"reply from server: %@", stringReply);
       httpResponse = (NSHTTPURLResponse *)response;
       int statusCode = [httpResponse statusCode];  
            //NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]); 
       NSLog(@"HTTP Status code: %d", statusCode);
            
       if(statusCode==200) {
            self.jsonArray=[stringReply JSONValue];
           NSLog(@"%@",self.jsonArray);
            if(self.jsonArray==nil)
                 NSLog(@"parsing error");
                
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }else{
                NSLog(@"http 오류.");
        }
        //timer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(jsonBackground) userInfo:nil repeats:NO]retain];
    }
}
- (void)OnTimer:(NSString *)type
{
    if(timer != nil){
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self jsonLoad];

    [self.photoTable reloadData];
}
- (void)showAlert:(NSString *)msg{
	UIImage *backgroundImage = [UIImage imageNamed:@"alertBack.png"];
	alert = [[PopAlertView alloc] initWithImage:backgroundImage text:NSLocalizedString(msg, nil)];
	[alert show];

}

- (void) hideAlert {
	[alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[alertView release];
}

#pragma mark -
#pragma mark SlidingTabsControl Delegate
- (UILabel*) labelFor:(SlidingTabView*)slidingTabsControl atIndex:(NSUInteger)tabIndex atLabel:(NSString *)ltext;
{
    UILabel* label = [[[UILabel alloc] init] autorelease];
    label.text = ltext;
    return label;
}
- (void)sortingList:(id)sender
{
    NSLog(@"%d",[sender tag]);
    switch ([sender tag]) {
        case 0: 
            sort_no=0;
            [self OnTimer:@"today"];
            break;
        case 1: 
            sort_no=1;
            [self OnTimer:@"daily"];
            break;
        default:
            //[self.tableView reloadData];
            break;
    }
}
+ (void)cacheCleanTest {
  
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [userDefaults objectForKey:@"cachePath"];
    NSMutableArray *imageNamesArray = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"imageNames"]];
    for(NSString* name in imageNamesArray) {
        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", path, name] error:nil];
    }
    [fileManager release];
    
    for(NSString* name in imageNamesArray) {  
        NSString* fileName = [NSString stringWithFormat:@"%@%@",path, name];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:fileName]];
        if(image == nil)NSLog(@"캐쉬 이미지 제거됨");
        else NSLog(@"캐쉬 이미지 제거 안됨");
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
    return [self.jsonArray count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    title = [[self.jsonArray objectAtIndex:section] valueForKey:@"date"];
	return title;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section] != nil) {
        return SectionHeaderHeight;
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
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, SectionHeaderHeight)];
    [view setBackgroundColor:[UIColor colorWithWhite:1.0 alpha: 0.5]];
    
    [view autorelease];
    [view addSubview:label];
    
    return view;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(sort_no==1){
        if (indexPath.section == 0 && indexPath.row == 0) {
            
            return 80;
        }
        return 80;
    }else{
        if (onOffCell) {
            if(nindex == indexPath.section){
                return 250;
            }
        }
        return 300;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //tableView.style = UITableViewStylePlain;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor whiteColor];
    
    //NSLog(@"====%d",(int)[[self.jsonArray objectAtIndex:indexPath.section] count]);
    
    static NSString *CellID = @"Identifier";
    PhotoLargeCell *cell = (PhotoLargeCell *)[tableView dequeueReusableCellWithIdentifier:CellID];
    if(cell == nil) {
        cell =  [[[PhotoLargeCell alloc] 
                  initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //for(int y=0;y < [[self.jsonArray objectAtIndex:indexPath.section] count];y++){
            NSLog(@"%d",indexPath.section);
        // }

    }
    profileView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
    profileView.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    [profileView setUserInteractionEnabled:YES];
    
    [cell.rightView addSubview:profileView];
    cell.imageView.image=nil;
    [cell setPhoto:[[self.jsonArray objectAtIndex:indexPath.section] objectForKey:@"img"] profile:[[self.jsonArray objectAtIndex:indexPath.section] objectForKey:@"icon"]];
    
    profileView.imageURL = [NSURL URLWithString:[[self.jsonArray objectAtIndex:indexPath.section] objectForKey:@"icon"]];
    
       
    UIButton *button = [[[UIButton alloc]init] autorelease];
    CGRect rect = profileView.frame;
    button.frame = rect;
    button.tag = (int)[[self.jsonArray objectAtIndex:indexPath.section] objectForKey:@"uidx"];
    [button setImage:[UIImage imageNamed:@"blank_80.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ProfileDetail:) forControlEvents:UIControlEventTouchUpInside];
    
    [profileView addSubview:button];
    
    UIButton *lovebutton = [[[UIButton alloc] initWithFrame:CGRectMake(5.0,60.0, 31, 30)] autorelease];
    lovebutton.tag = (int)[[self.jsonArray objectAtIndex:indexPath.section] objectForKey:@"idx"];

    int cnt=[[[self.jsonArray objectAtIndex:indexPath.section] objectForKey:@"loved"] count];
    
    if(cnt>0){
        for(int x=0;x<cnt;x++){
            if([[[GlobalStn sharedSingleton] ukey]  isEqualToString:[[[self.jsonArray objectAtIndex:indexPath.section] objectForKey:@"loved"] objectAtIndex:x]]){
                [lovebutton setImage:[UIImage imageNamed:@"ico_loved_on.png"] forState:UIControlStateNormal];
             }
        }       
    }else{
        [lovebutton setImage:[UIImage imageNamed:@"ico_loved.png"] forState:UIControlStateNormal];
        [lovebutton addTarget:self action:@selector(lovedSubmit:) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell.rightView addSubview:lovebutton];
 
    
    cell.lovedlabel.text=[NSString stringWithFormat:@"Loved %d",cnt];
    cell.comlabel.text=[NSString stringWithFormat:@"Comment %@",[[self.jsonArray objectAtIndex:indexPath.section] objectForKey:@"comment"]];
    
    UIButton *commentbutton = [[[UIButton alloc] initWithFrame:CGRectMake(5.0,100.0, 29, 45)] autorelease];
    commentbutton.tag = (int)[[self.jsonArray objectAtIndex:indexPath.section] objectForKey:@"idx"];
    
    [commentbutton setImage:[UIImage imageNamed:@"ico_comment.png"] forState:UIControlStateNormal];
    [commentbutton addTarget:self action:@selector(commentSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [cell.rightView addSubview:commentbutton];
    
    UIButton *spotbutton = [[[UIButton alloc] initWithFrame:CGRectMake(5.0,160.0, 30, 42)] autorelease];
    spotbutton.tag = (int)[[self.jsonArray objectAtIndex:indexPath.section] objectForKey:@"idx"];
    [spotbutton setImage:[UIImage imageNamed:@"ico_spot.png"] forState:UIControlStateNormal];
    [spotbutton addTarget:self action:@selector(lovedSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [cell.rightView addSubview:spotbutton];
    
    if((int)[[GlobalStn sharedSingleton] pickerChk]==1){
        [indicatior stopAnimating];
        [self.photoTable setContentOffset:CGPointMake(0, 0) animated:YES];
        [lView removeFromSuperview];
        [[GlobalStn sharedSingleton] setPickerChk:0];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"====%@",indexPath.row);
}
-(void)ProfileDetail:(id)sender{
    ProfileViewController *controller=[[ProfileViewController alloc] init];
    controller.uidx=(NSInteger)[sender tag];
    controller.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}
-(void)commentSubmit:(id)sender{
    CommentView *controller=[[CommentView alloc] init];
    controller.pidx=[NSString stringWithFormat:@"%@",[sender tag]];
    controller.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}
-(BOOL)lovedSubmit:(id)sender{
   //[NSString stringWithFormat:@"%@",[sender tag]];
    NSLog(@"sender %@",[sender tag]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:PHOTO_LOVED_POST_URL] 
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
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"lkey\"\r\n\r\n%@",[[GlobalStn sharedSingleton] ukey]] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"pidx\"\r\n\r\n%@",[sender tag]] dataUsingEncoding:NSUTF8StringEncoding] ];
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
    //NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]); 
    //NSLog(@"HTTP Status code: %d", statusCode);
    
    if(statusCode==200) {
        NSLog(@"submit %@",stringReply);
     
 
            UIImage *unselectedImage=[UIImage imageNamed:@"ico_loved.png"];
            UIImage *selectedImage=[UIImage imageNamed:@"ico_loved_on.png"];
            
            if ([sender isSelected]) {
                [sender setImage:unselectedImage forState:UIControlStateNormal];
                [sender setSelected:NO];
            }else {
                [sender setImage:selectedImage forState:UIControlStateSelected];
                [sender setSelected:YES];
            }
  
        
    }else{
        NSLog(@"http 오류.");
    }

    
    return TRUE;
}


- (void)selectCellImage:(id)sender{
    
    if(onOffCell)
        onOffCell=FALSE;
    else
        onOffCell=TRUE;

    nindex=[sender tag] / 10;
    [self.photoTable reloadData];
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
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
	CGImageRef maskRef = maskImage.CGImage; 
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	return [UIImage imageWithCGImage:masked];
}

- (void)BtnHttpSend:(id)sender{
    NSLog(@"send %@",sender);
}
- (void)layoutScrollImages
{
	UIImageView *view = nil;
	NSArray *subviews = [scrollView1 subviews];
    
	CGFloat curXLoc = 0;
    CGFloat imgcnt = [[GlobalStn sharedSingleton] celltot];
    
	for (view in subviews)
	{
		if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += (kScrollObjWidth2 + 1);
            
		}
	}
    NSUInteger timg;
	if(imgcnt < kNumImages2){
        timg = kNumImages2;
    }else{
        timg = imgcnt;
    }
	[scrollView1 setContentSize:CGSizeMake(( timg * kScrollObjWidth2), [scrollView1 bounds].size.height)];
}
-(void)btnSetting{
    
}
-(void)setData:(NSDictionary *)dict sect:(int)row{
    if(sort_no==0){
       
        //[self.imageView setImageURLString:[dict objectForKey:@"img"]];
        
    }else{
        NSArray *path=[dict valueForKey:@"img"];
        NSArray *uniq=[dict valueForKey:@"idx"];
        for(int i=0;i<[path count];i++)
        {
            int c;
            c = i + 1;
            
            NSString *tempidx=[NSString stringWithFormat:@"%@",[uniq objectAtIndex:i]];
            int idx=[tempidx intValue];
            //calImageView.imageURL:[NSURL URLWithString:[path objectAtIndex:i]];
            [(UIImageView*)[scrollView1 viewWithTag:idx] setImageURLString:[path objectAtIndex:i]];
        }
    }
}
- (void)detailPush:(id)sender {
    //NSLog(@"path = %d", [sender tag]);
    photoDetailView *controller = [[photoDetailView alloc] init];
    controller.itemID=(NSInteger *)[sender tag];
    controller.view.backgroundColor=[UIColor whiteColor];
    
    
    [self.navigationController pushViewController:controller animated:YES];
    
    [controller release];
}




/*
 Override if you support editing the list
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }	
 if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }	
 }
 */


/*
 Override if you support conditional editing of the list
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 Override if you support rearranging the list
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 Override if you support conditional rearranging of the list
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */ 

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    //[self jsonLoad];
    //[self.tableView reloadData];
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
    
	_reloading = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.photoTable];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    
    //CGFloat pageHeight = scrollView.frame.size.height;
    //NSLog(@"%f // %f",self.photoTable.contentOffset.y, pageHeight);
    
    
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"end %f",self.photoTable.contentOffset.y);
    //pageControlUsed = NO;
}
- (void)startDownload:(NSString *)urlString
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:urlString]] delegate:self];
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
    NSLog(@"data size %u",data.length);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
 
    self.downImage=[self resizeImage:image width:200 height:100];
    self.activeDownload = nil;
    [image release];
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
 
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
 
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}
- (void)viewDidUnload {
	_refreshHeaderView=nil;
}
- (void)dealloc {

    [scrollView1 release];
    [cellContentView release];
	[self.jsonArray release],self.jsonArray=nil;
    [activeDownload release];
    [profileView release];
    [imageConnection cancel];
    [imageConnection release];
    [indicatior release];
    indicatior=nil;
    [lView release];
	[super dealloc];
}
@end
