//
//  DetailsViewController.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 22..
//  Copyright 2011 ag. All rights reserved.
//

#import "DetailsViewController.h"


@implementation DetailsViewController

@synthesize url = _url;


- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
	_webView = [[UIWebView alloc] initWithFrame:self.view.bounds]; 
	// load the contents of the url
	[_webView loadRequest:[NSURLRequest requestWithURL:_url]];
	UIApplication* app = [UIApplication sharedApplication]; 
    app.networkActivityIndicatorVisible = YES; //로딩애니메이션이 동작한다 .
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [_activityIndicator setCenter:CGPointMake(160.0f, 208.0f)];
    [_activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.tag = 100;
    [_webView addSubview:_activityIndicator];
    [_activityIndicator release];
    
    _webView.delegate = self; 
    [self.view addSubview:_webView];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(IBAction) donePressed:(id)sender
{
	[self.view removeFromSuperview];
}

#pragma mark UIWebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[_activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[_activityIndicator stopAnimating];
	
	NSLog(@"Error Loading web page");
}

- (void)dealloc {
    
	[_webView    release];
	[_url        release];
	
	[super dealloc];
}


@end
