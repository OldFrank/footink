//
//  SearchBrancheViewController.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import "SearchBrancheViewController.h"
#import "SpotListViewController.h"
#import "FindMeViewController.h"


@implementation SearchBrancheViewController

@synthesize searchField;


#pragma mark -
#pragma mark 검색

// 지점찾기.
- (IBAction)search:(id)sender {
	NSLog(@"Search keyword: %@", searchField.text);
	
	SpotListViewController *searchListViewController = [[SpotListViewController alloc] init];
	searchListViewController.searchKeyword = searchField.text;
	[self.navigationController pushViewController:searchListViewController animated:YES];
	[searchListViewController release];
}


// 현재위치에서 주변 검색.
- (IBAction)findSurroundings:(id)sender {
	// FindMe 테스트 용.
	FindMeViewController *findMeViewController = [[FindMeViewController alloc] initWithNibName:@"FindMeViewController" bundle:nil];
	[self.navigationController pushViewController:findMeViewController animated:YES];
	[findMeViewController release];
}



#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[searchField release];
    [super dealloc];
}


@end
