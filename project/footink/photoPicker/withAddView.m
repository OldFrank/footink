//
//  withAddView.m
//  photoPicker
//
//  Created by yongsik on 11. 7. 13..
//  Copyright 2011 ag. All rights reserved.
//

#import "withAddView.h"


@implementation withAddView

@synthesize delegate;

- (id)init {
	self = [super init];
	if (self != nil) {
		[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
		txtMemo = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 30.0)];
		[txtMemo setBorderStyle:UITextBorderStyleRoundedRect];
		[self.view addSubview:txtMemo];
		
		slider = [[UISlider alloc] initWithFrame:CGRectMake(10.0, 50.0, 250.0, 30.0)];
		[slider addTarget:self action:@selector(SlideChanged:) forControlEvents:UIControlEventValueChanged];
		[slider setMinimumValue:0];
		[slider setMaximumValue:10];
		[self.view addSubview:slider];
		
		lblSlider = [[UILabel alloc] initWithFrame:CGRectMake(270.0, 50.0, 40.0, 30.0)];
		lblSlider.textAlignment = UITextAlignmentCenter;
		lblSlider.text = @"0";
		[self.view addSubview:lblSlider];
		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(cmdSave)] autorelease];
	}
	return self;
}
- (void)dealloc {
	[txtMemo release];
	[slider release];
	[lblSlider release];
    [super dealloc];
}
- (void)SlideChanged:(id)sender {
	lblSlider.text = [NSString stringWithFormat:@"%i",(int)slider.value];
}
- (void)cmdSave {
    NSLog(@"%@",txtMemo.text);
	if ([self.delegate respondsToSelector:@selector(AddviewSubmitWithMemo:Priority:)]) {
		[self.delegate AddviewSubmitWithMemo:txtMemo.text Priority:(int)slider.value];
	}
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}



@end