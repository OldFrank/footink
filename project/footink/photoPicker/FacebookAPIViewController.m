/*
 
 Copyright (c) 2010, Mobisoft Infotech
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are 
 permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of 
 conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright notice, 
 this list of conditions and the following disclaimer in the documentation and/or 
 other materials provided with the distribution.
 
 Neither the name of Mobisoft Infotech nor the names of its contributors may be used to 
 endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS 
 OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
 AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
 OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
 OF SUCH DAMAGE.
 
 */

#import "FacebookAPIViewController.h"
#import "footinkAppDelegate.h"

#define _APP_KEY @"128709617185037"
#define _SECRET_KEY @"e770922fe60553ad947f439551d49b02"

@implementation FacebookAPIViewController
@synthesize loginButton;
@synthesize usersession;
@synthesize username;
@synthesize post;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	footinkAppDelegate *appDelegate =(footinkAppDelegate *)[[UIApplication sharedApplication]delegate];
	
	if (appDelegate._fsession == nil){
		appDelegate._fsession = [FBSession sessionForApplication:_APP_KEY 
														 secret:_SECRET_KEY delegate:self];
	}
	if(self.loginButton == NULL)
		self.loginButton = [[[FBLoginButton alloc] init] autorelease];
	loginButton.frame = CGRectMake(0, 0, 100, 50);
	
    if (appDelegate._fsession.isConnected) {
        [appDelegate._fsession logout];
    } else {
        FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:appDelegate._fsession] autorelease];
        [dialog show];
    }

    
    
    
    //[self.view addSubview:loginButton];
	//self.view.backgroundColor = [UIColor clearColor];
    [super viewDidLoad];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[username release];
	[usersession release];
	[loginButton release];
    [super dealloc];
}

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	self.usersession =session;
    NSLog(@"User with id %lld logged in.", uid);
	[self getFacebookName];
}

- (void)getFacebookName {
	NSString* fql = [NSString stringWithFormat:
					 @"select uid,name from user where uid == %lld", self.usersession.uid];
	NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
	self.post=YES;
}

- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([request.method isEqualToString:@"facebook.fql.query"]) {
		NSArray* users = result;
		NSDictionary* user = [users objectAtIndex:0];
		NSString* name = [user objectForKey:@"name"];
		self.username = name;		
		
		if (self.post) {
			[self postToWall];
			self.post = NO;
		}
	}
}

- (void)postToWall {
	
	FBStreamDialog *dialog = [[[FBStreamDialog alloc] init] autorelease];
	dialog.userMessagePrompt = @"Enter your message:";
	dialog.attachment = [NSString stringWithFormat:@"{\"name\":\"Facebook Connect for iPhone\",\"href\":\"http://developers.facebook.com/connect.php?tab=iphone\",\"caption\":\"Caption\",\"description\":\"Description\",\"media\":[{\"type\":\"image\",\"src\":\"http://img40.yfrog.com/img40/5914/iphoneconnectbtn.jpg\",\"href\":\"http://developers.facebook.com/connect.php?tab=iphone/\"}],\"properties\":{\"another link\":{\"text\":\"Facebook home page\",\"href\":\"http://www.facebook.com\"}}}"];
	[dialog show];
	
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

@end
