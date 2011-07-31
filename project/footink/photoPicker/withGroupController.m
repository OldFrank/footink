//
//  friendsViewcontroller.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import "withGroupController.h"
#import "JSON.h"
#import "GlobalStn.h"
#import "Reachability.h"
#import "pagingViewController.h"
#import "withRootView.h"

#define NEARBY_GROUP_URL @"http://footink.com/user/nearby/group"

@implementation withGroupController

const CGFloat pLaceFriendsRadius= 20;
const CGFloat bigImgScrollObjHeight	= 300.0;
const CGFloat bigImgkScrollObjWidth	= 300.0;
const NSUInteger kFNumImages		= 1;

@synthesize jsonArray,uidx;
@synthesize scrollView,fscrollView,pageControl,viewControllers,bodyScrollView;

- (id) init{
    self=[super init];
    if(self!=nil){
        self.title=@"With";
    }
    return self;
}
- (void)viewDidLoad {
	[super viewDidLoad];
    
    scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(10.0, 0.0, [UIScreen mainScreen].bounds.size.width - 20.0, [UIScreen mainScreen].bounds.size.width - 20.0)];
    [scrollView setBackgroundColor:[UIColor lightGrayColor]];
    [scrollView setCanCancelContentTouches:NO];
    
    scrollView.showsVerticalScrollIndicator=NO;
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.alwaysBounceVertical=NO;             
    scrollView.alwaysBounceHorizontal=NO;         
    scrollView.pagingEnabled=YES;
    scrollView.delegate=self;
    
    [self.view addSubview:scrollView];
    
    /*fscrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width, 100.0)];
    fscrollView.backgroundColor=[UIColor grayColor];
    [self.view addSubview:fscrollView];*/
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"group viewWillAppear");
    if((int)[[GlobalStn sharedSingleton] pickerChk]==1){
        [[GlobalStn sharedSingleton] setPickerChk:0];
    }
    self.tabBarController.tabBar.hidden = YES; 
    
    
    [self withGroupTabBar];
    [self jsonLoad];
}
-(void)viewWillDisappear:(BOOL)animated{
    [self hideTabBar];
}
-(void)hidePrevTabBar{
    //[[self.tabBarController.view viewWithTag:3000] removeFromSuperview];
    for(UIView *subview in [self.tabBarController.view subviews]){
        if(subview.tag==3000){
            [subview removeFromSuperview];
        }
    }
}
-(void)hideTabBar{
    //[[self.tabBarController.view viewWithTag:3000] removeFromSuperview];
    for(UIView *subview in [self.tabBarController.view subviews]){
        if(subview.tag==4000){
            [subview removeFromSuperview];
        }
    }
}
-(void)withGroupTabBar{
    [self hidePrevTabBar];
    UIView *newTabBar=[[UIView alloc] initWithFrame:CGRectMake(0.0, 430.0, 320.0, 50.0)];
    newTabBar.backgroundColor=[UIColor whiteColor];
    newTabBar.tag=4000;
    [self.tabBarController.view addSubview:newTabBar]; 
    
    UIButton *cameraButton=[[UIButton alloc] initWithFrame:CGRectMake(140.0, 0.0, 40.0, 40.0)];
    UIImage *img = [UIImage imageNamed:@"btn_swipe.png"];
    [cameraButton setImage:img forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(onCamera) forControlEvents:UIControlEventTouchUpInside];
    [img release];
    [newTabBar addSubview:cameraButton];
    [newTabBar release];
    [cameraButton release];
    
     UIButton *backButton=[[UIButton alloc] initWithFrame:CGRectMake(10.0, 10.0, 40.0, 30.0)];
     UIImage *simg = [UIImage imageNamed:@"btn_back.png"];
     [backButton setImage:simg forState:UIControlStateNormal];
     [backButton addTarget:self action:@selector(backPopAct) forControlEvents:UIControlEventTouchUpInside];
     [simg release];
     [newTabBar addSubview:backButton];
     
}
-(void)onCamera{
    NSLog(@"camera");
    [self hideTabBar];
    [[GlobalStn sharedSingleton] setCamPosition:1];
    self.tabBarController.selectedIndex = 2;
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)backPopAct{
    [self hideTabBar];
    
    //withRootView *cont=[[withRootView alloc] init];
    [self.navigationController popViewControllerAnimated:YES];
    //self.tabBarController.tabBar.hidden = NO; 
    self.tabBarController.selectedIndex = 1;
}
-(void)jsonLoad{

    NSMutableArray *valueData=[NSMutableArray array];
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",uidx],@"uidx", nil]];
    if(uidx==0){
        [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",[[GlobalStn sharedSingleton] ukey]],@"ukey", nil]];
    }

    CGRect frame=CGRectMake(220.0, 10.0, 80.0, 20.0);
    
    progressbar=[[HttpWrapper alloc] requestUrl:NEARBY_GROUP_URL values:valueData progressBarFrame:(CGRect)frame image:nil loc:nil delegate:self];
    [self.scrollView addSubview:progressbar];
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFinishWithData:(NSData *)fileData{
    id stringReply;
    stringReply = (NSString *)[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    progressbar.hidden=YES;
    self.jsonArray=[stringReply JSONValue];
    [self initImageView];
    NSLog(@"wi ---- %@",stringReply);
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}
- (void)httpBarUpdated:(HttpWrapper *)httpProgBar{
    
}
-(void)initImageView{
    pageCnt = [self.jsonArray count];
    
    pageControl=[[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(10.0,scrollView.frame.size.height - 15.0, scrollView.frame.size.width, 15.0 );
    [pageControl addTarget:self
                    action:@selector(changePage:)
          forControlEvents:UIControlEventValueChanged];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.numberOfPages = pageCnt;
    
    [self.view addSubview:pageControl];
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < pageCnt; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    [controllers release];
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * pageCnt, scrollView.frame.size.height);
    //[scrollView addSubview:pageControl];
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
        [controller setImage:[[self.jsonArray objectAtIndex:page] objectForKey:@"thumb"]];
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

- (void)changePage:(id)sender
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
    [profileView release];
    [jsonArray release];
    //[bigImageView release];
    [scrollView release];
    [super dealloc];
}
@end
