//
//  splashViewController.m
//  footink
//
//  Created by yongsik on 11. 7. 23..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "splashViewController.h"


@implementation splashViewController
@synthesize modalViewController,modalView;

-(void)viewDidLoad{
    modalView=[[UIView alloc] init];
    [self.view addSubview:modalView];
    
    UIImageView *dimg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
    [modalView addSubview:dimg];
}
- (void)showSplash
{
    modalViewController = [[UIViewController alloc] init];
    modalViewController.view = modalView;
    modalViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:modalViewController animated:NO];
    [self performSelector:@selector(hideSplash) withObject:nil afterDelay:3.0];
}
-(void)hideSplash{
    [self.modalViewController dismissModalViewControllerAnimated:YES];
}
- (void)dealloc
{   
    [modalViewController release];
    modalViewController=nil;
    [modalView release];
    modalView=nil;
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
