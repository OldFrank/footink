//
//  PicViewController.m
//  footink
//
//  Created by yongsik on 11. 7. 28..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "PicViewController.h"

@implementation PicViewController

@synthesize img;

- (id)initWithImage:(NSString *)url {
	
	// loading the nib here
    if (self = [super initWithNibName:@"PicViewController" bundle:nil]) {
		// grabbing the image and setting it to our imageview
		img = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: url]]];
    }
    return self;
}


- (void)viewDidLoad {
	image.image = img;
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
	[super dealloc];
}

@end
