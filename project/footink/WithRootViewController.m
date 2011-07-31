//
//  WithRootViewController.m
//  footink
//
//  Created by yongsik on 11. 7. 26..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "WithRootViewController.h"
#import "withRootView.h"
#import "GlobalStn.h"
#import "withGroupController.h"

@implementation WithRootViewController

- (id) init{
    self=[super init];
    if(self!=nil){
        self.title=@"With";
        
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
          
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
     NSLog(@"with viewdidload");
    [super viewDidLoad];
    
    //self.tabBarController.tabBar.hidden = YES; 
    withRootView *cont=[[withRootView alloc] init];
    //cont.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:cont animated:NO];
}
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"with viewWillAppear");
    
}
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
