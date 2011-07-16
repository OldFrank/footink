
//
//  friendsViewcontroller.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import "withViewcontroller.h"
#import "JSON.h"
#import "GlobalStn.h"
#import "Reachability.h"
#import "EGOImageView.h"
#import "pagingViewController.h"

@implementation withViewcontroller

const CGFloat pLaceFriendsRadius= 20;
const CGFloat bigImgScrollObjHeight	= 300.0;
const CGFloat bigImgkScrollObjWidth	= 300.0;
const NSUInteger kFNumImages		= 1;

@synthesize jsonArray;
@synthesize scrollView,fscrollView,pageControl,viewControllers;

- (id) init{
    self=[super init];
    if(self!=nil){
        self.title=@"With";
    
    }
    return self;
}
- (void)viewDidLoad {
	[super viewDidLoad];
    
	[self.navigationController setNavigationBarHidden:YES animated:NO];
    
    NSLog(@"%@",[[GlobalStn sharedSingleton] pushToken]);

    header=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
    header.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:header];
    [header release];
    
    profileView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
    profileView.frame = CGRectMake(2.0, 2.0, 40.0, 40.0);
    [profileView setUserInteractionEnabled:YES];
    [header addSubview:profileView];
    
    bodyScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 50.0, 320.0, 400.0)];
    [bodyScrollView setBackgroundColor:[UIColor orangeColor]];
    [bodyScrollView setCanCancelContentTouches:NO];
    
    bodyScrollView.showsVerticalScrollIndicator=NO;
    bodyScrollView.showsHorizontalScrollIndicator=YES;
    bodyScrollView.alwaysBounceVertical=NO;             
    bodyScrollView.alwaysBounceHorizontal=NO;         
    bodyScrollView.pagingEnabled=NO;          //페이징 가능 여부 YES

    [self.view addSubview:bodyScrollView];
    
    
    scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 300.0)];
    [scrollView setBackgroundColor:[UIColor lightGrayColor]];
    [scrollView setCanCancelContentTouches:NO];
    
    scrollView.showsVerticalScrollIndicator=NO;
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.alwaysBounceVertical=NO;             
    scrollView.alwaysBounceHorizontal=NO;         
    scrollView.pagingEnabled=YES;          //페이징 가능 여부 YES
    scrollView.delegate=self;
    
    [bodyScrollView addSubview:scrollView];
    
    [bodyScrollView setContentOffset:CGPointMake(0, -60) animated:YES];
    
    fscrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 360.0, 320.0, 60.0)];
    fscrollView.backgroundColor=[UIColor grayColor];
    [self.view addSubview:fscrollView];
    
    [self jsonDummy];
}
-(void)jsonDummy
{
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
        
        httpResponse = (NSHTTPURLResponse *)response;
        int statusCode = [httpResponse statusCode];  
        //NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]); 
        NSLog(@"HTTP Status code: %d", statusCode);
        
        if(statusCode==200) {
            self.jsonArray=[stringReply JSONValue];
            NSLog(@"%d",[self.jsonArray count]);
            [self initImageView];

            if(self.jsonArray==nil)
                NSLog(@"parsing error");

        }else{
            NSLog(@"http 오류.");
        }
}
- (void)jsonLoad:(NSString *)types{
    CLLocationManager * locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDelegate:self];
    CLLocation* location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    [locationManager release];
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://footink.com/user/friendsloc?lat=%f&lng=%f&radius=%f",coordinate.latitude,coordinate.longitude,pLaceFriendsRadius, nil]];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL];
    
    self.jsonArray=[jsonData JSONValue];
    [jsonData release];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    [self.jsonArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    
    NSLog(@"data total %d",[self.jsonArray count]);
    //NSLog(@"data %@",self.jsonArray);
    
}

-(void)initImageView{
    pageCnt = [self.jsonArray count];
 
    pageControl=[[UIPageControl alloc] init];
    pageControl.frame = CGRectMake( 0, self.view.bounds.size.height - 30, 320, 30 );
    [pageControl addTarget:self
                     action:@selector(pageControlDidChange:)
           forControlEvents:UIControlEventValueChanged];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
 
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor blackColor];
    pageControl.numberOfPages = 5;
    
    
    [scrollView bringSubviewToFront:pageControl];
   

    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < pageCnt; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    [controllers release];
    
       scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * pageCnt, scrollView.frame.size.height);
    [scrollView addSubview:pageControl];
    

    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];

}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    
    if (page >= pageCnt)
        return;
    
    pagingViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[pagingViewController alloc] initWithPageNumber:page];
        [viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }

    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
        
        //NSDictionary *numberItem = [self.jsonArray objectAtIndex:page];
        //controller.imgUrl = [[self.jsonArray objectAtIndex:page] objectForKey:@"img"];
        [controller setImage:[[self.jsonArray objectAtIndex:page] objectForKey:@"img"]];
        controller.numberTitle.text = [self.jsonArray objectAtIndex:page];
    }
}



- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (pageControlUsed)
    {
        return;
    }

    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;

    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender
{
    int page = pageControl.currentPage;

    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    

    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];

    pageControlUsed = YES;
}

/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view data source



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}
- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}
- (void)dealloc {
    [header release];
    [profileView release];
    [jsonArray release];
    [bigImageView release];
    [scrollView release];
    [super dealloc];
}
@end
