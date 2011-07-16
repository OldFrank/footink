//
//  DetailsViewController.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 22..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailsViewController : UIViewController <UIWebViewDelegate>
{
	IBOutlet UIWebView* _webView;
	IBOutlet UIActivityIndicatorView* _activityIndicator;
	
	NSURL* _url;
}

@property(nonatomic, retain) NSURL* url;

-(IBAction) donePressed:(id)sender;

@end
