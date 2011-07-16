//
//  photoViewController.m
//  photoPicker
//
//  Created by Yongsik Cho on 11. 4. 12..
//  Copyright 2011 ag. All rights reserved.
//

#import "photoViewController.h"
#import "JSON.h"

@implementation photoViewController

@synthesize jsonLabel, jsonImage, jsonItem, itemID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
	if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		self.itemID = 0;
	}
    NSLog(@"----initWithNibName %i",(int)self.itemID);
	return self;
}

-(void)setID:(NSInteger)val {
	self.itemID = (NSInteger *)val;
}


/*
 Implement loadView if you want to create a view hierarchy programmatically
 - (void)loadView {
 }
 */

- (void)viewDidLoad {
	// init the url
    UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    button.frame = CGRectMake(0.0f, 0.0f, 49.0f, 30.0f);
    [button setBackgroundImage:[UIImage imageNamed:@"btn-before.png"] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageNamed:@"btn-before.png"] forState:UIControlStateNormal];        
    [button addTarget:self action:@selector(btnBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:button];
    [temporaryBarButtonItem setStyle:UIBarButtonItemStyleBordered];
    self.navigationItem.leftBarButtonItem =temporaryBarButtonItem;
    [button release];
    [temporaryBarButtonItem release];

    self.navigationController.navigationBar.tintColor = [UIColor   
                                                         colorWithRed:102.0/255   
                                                         green:52.0/255   
                                                         blue:133.0/255   
                                                         alpha:1]; 
    
	NSLog(@"view---didload");
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://footink.com/user/gv?id=%@", self.itemID, nil]];
	 
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL];
	NSLog(@"%@",jsonData);
	if (jsonData == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Webservice Down" message:@"The webservice you are accessing is down. Please try again later."  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
	else {
		self.jsonItem = [jsonData JSONValue]; 
		
		// setting up the title
		self.jsonLabel.text = [self.jsonItem objectForKey:@"title"];
        
		// setting up the image now
		self.jsonImage.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: [self.jsonItem objectForKey:@"img"]]]];
        
     
	}
    [jsonURL release];
    [jsonData release];
}

-(IBAction)btnBack:(id)sender{
    NSLog(@"back");
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[jsonLabel dealloc];
	[jsonImage dealloc];
    [self.jsonItem dealloc];
	//[self.itemID dealloc];
	//[self.jsonItem dealloc];
	[super dealloc];
}


@end
