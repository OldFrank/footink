//
//  CommentView.m
//  footink
//
//  Created by yongsik on 11. 7. 25..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "CommentView.h"
#import "GlobalStn.h"
#import "JSON.h"
#import "CommentCell.h"

#define PHOTO_COMMENT_GET_URL @"http://footink.com/user/comment"
#define PHOTO_COMMENT_POST_URL @"http://footink.com/user/comment/post"
@implementation CommentView

@synthesize commentView;
@synthesize jsonArray,progressBack,catList,pidx,commentInput,commentback;

- (id) init{
    self=[super init];
    if(self!=nil){
        self.title=@"Comment";
    }
    return self;
}
-(void)viewDidLoad{
    [super viewDidLoad];
   // self.tabBarController.tabBar.hidden = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"pidx %@",pidx);
    self.commentView = [[[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 105.0) style:UITableViewStylePlain] autorelease];
    self.commentView.delegate=self;
    self.commentView.dataSource=self;
    
    UIControl *control = [[UIControl alloc] initWithFrame:self.commentView.frame];
	[control setBackgroundColor:[UIColor clearColor]];
	[control addTarget:self action:@selector(keyboardDown:) forControlEvents:UIControlEventTouchUpInside];
	[self.commentView setBackgroundView:control];
	[control release];
    
    [self.view addSubview:self.commentView];
  
    progressBack=[[UIView alloc] initWithFrame:CGRectMake(190, 10, 120.0, 50.0)];
    [self.view addSubview:progressBack];
    [self getCommentList];
    
    [self registerForKeyboardNotifications];
    keyboardVisible = NO;
    
    commentback=[[UIView alloc] initWithFrame:CGRectMake(0.0,[UIScreen mainScreen].bounds.size.height-104, [UIScreen mainScreen].bounds.size.width, 40.0)];
    commentback.backgroundColor=[UIColor blackColor];
    [self.view addSubview:commentback];
    
    commentInput=[[UITextField alloc] initWithFrame:CGRectMake(10.0, 5.0, 250.0, 26)];
    commentInput.tag = 300;
    commentInput.keyboardType=UIKeyboardTypeDefault;
    commentInput.delegate = self;
    [commentInput setBorderStyle:UITextBorderStyleRoundedRect];
    [commentInput addTarget:self 
                    action:@selector(keyboardDown:)
          forControlEvents:UIControlEventEditingDidEndOnExit];
    [commentback addSubview:commentInput];
    
    UIButton *pButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pButton.frame = CGRectMake(270, 5, 40,25);
    [pButton setImage:[UIImage imageNamed:@"Icon.png"] forState:UIControlStateNormal];
    [pButton addTarget:self action:@selector(keyboardDown:) forControlEvents:UIControlEventTouchUpInside];
    [commentback addSubview:pButton];
    //[commentInput becomeFirstResponder];
}
-(void) viewWillDisappear:(BOOL)animated{
    
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification object:nil];
}
-(BOOL)sendComment{
    //NSLog(@"-------------------sendComment..%@ - %@",[[GlobalStn sharedSingleton] ukey],pidx);
    NSString *str=commentInput.text;
    if([str length]==0)
        return FALSE;
    
    NSMutableArray *valueData=[NSMutableArray array];
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[GlobalStn sharedSingleton] uname],@"uname", nil]];
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:self.pidx,@"pidx", nil]];
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:str,@"comment", nil]];

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:PHOTO_COMMENT_POST_URL] 
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [NSString stringWithString:@"-----------14737809831466499882746641449"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //post append
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uname\"\r\n\r\n%@",[[GlobalStn sharedSingleton] uname]] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"wkey\"\r\n\r\n%@",[[GlobalStn sharedSingleton] ukey]] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"pidx\"\r\n\r\n%@",pidx] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"comment\"\r\n\r\n%@",str] dataUsingEncoding:NSUTF8StringEncoding] ];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
    [request setHTTPBody:body];
    
    NSURLResponse *iresponse;
    NSHTTPURLResponse *httpResponse;
    NSError *error;
    
    id stringReply;
    
    NSData *datareply=[NSURLConnection sendSynchronousRequest:request returningResponse:&iresponse error:&error];
    stringReply = (NSString *)[[NSString alloc] initWithData:datareply encoding:NSUTF8StringEncoding];
    
    httpResponse = (NSHTTPURLResponse *)iresponse;
    int statusCode = [httpResponse statusCode];  
    //NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]); 
    //NSLog(@"HTTP Status code: %d", statusCode);
    
    if(statusCode==200) {
        NSLog(@"submit %@",stringReply);

            int chk;
            chk=[stringReply intValue];
            
            if(chk==0){
               commentInput.text=@"";
                //[commentInput resignFirstResponder];
                
            }
  
    }else{
        NSLog(@"http 오류.");
    }
    
    [self getCommentList];
    [self.commentView reloadData];
    
    return TRUE;
}
-(void)getCommentList{
    
    NSMutableArray *valueData=[NSMutableArray array];
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[GlobalStn sharedSingleton] uname],@"uname", nil]];
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:self.pidx,@"pidx", nil]];
 
    CGRect progressframe=CGRectMake(10.0, 5.0, 100.0, 20.0);
    NSString *geturl=[NSString stringWithFormat:@"%@",PHOTO_COMMENT_GET_URL];
    progressbar=[[HttpWrapper alloc] requestUrl:geturl values:valueData progressBarFrame:(CGRect)progressframe image:nil loc:nil delegate:self];

    [self.progressBack addSubview:progressbar];
}
- (void)registerForKeyboardNotifications
{
    /*[[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(keyboardWasShown:)
     name:UIKeyboardDidShowNotification object:nil];
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    NSLog(@"touches Ended");
    // If not dragging, send event to next responder
        
    //[self resignAllFirstResponder];
}
-(float)keyboardDeltaFromNotification:(NSNotification*)notification {
    CGRect startrect,endrect;
    [(NSValue*)[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&startrect];
    [(NSValue*)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&endrect];
    float orig;
    //orig=endrect.origin.y – startrect.origin.y;
    return orig;
}
-(void)keyboardDown:(id)sender{
    [self sendComment];
    [commentInput resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animation:finished:context:)];
    [commentback setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width / 2,[UIScreen mainScreen].bounds.size.height-84)];
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)note { 
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animation:finished:context:)];
    [commentback setCenter:CGPointMake(160,184)];
    [UIView commitAnimations];
    
    //3.1.x 와 4.0 호환 키보드 붙이기
    for( UIWindow *keyboardWindow in [[UIApplication sharedApplication] windows] ){
        for( UIView *keyboard in [keyboardWindow subviews] ){
            NSString *desc = [keyboard description];
            if( [desc hasPrefix:@"<UIKeyboard"]==YES ||
               [desc hasPrefix:@"<UIPeripheralHostView"] == YES ||
               [desc hasPrefix:@"<UISnap"] == YES )
            {
                //[keyboard addSubview:kbtop];
            }
        }
    }
}

-(void)keyboardWillHide:(NSNotification*)notification {
    float keyboardDistance = [self keyboardDeltaFromNotification:notification];
    NSLog(@"%f",keyboardDistance);
    //[self moveAddFriendControls:keyboardDistance notification:notification];
}
/*
-(void)moveAddFriendControls:(float)delta
                notification:(NSNotification*)notification {
    UIViewAnimationCurve animationCurve = [(NSNumber*)[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    double animationDuration = [(NSNumber*)[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView beginAnimations:@"shiftFieldsUp" context:nil];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    CGRect scrollingAreaBounds = scrollingArea.bounds;
    scrollingAreaBounds.origin.y += delta;
    [scrollingArea setBounds:scrollingAreaBounds];
    [UIView commitAnimations];
}*/
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //activeField = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [commentInput resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
	NSLog(@"return Key at %@",textField);
	
	return YES;
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFinishWithData:(NSData *)fileData{
    id stringReply;
    stringReply = (NSString *)[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    self.jsonArray=[stringReply JSONValue];
    NSLog(@"%@",self.jsonArray);
    [self.commentView reloadData];
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFailWithError:(NSError *)error{
    NSLog(@"error %@",error);
}
- (void)httpBarUpdated:(HttpWrapper *)httpProgBar{
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"Comment";
	return title;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 0, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    /*label.textColor = [UIColor colorWithHue:(360/360)
     saturation:1.0
     brightness:0.60
     alpha:1.0];
     */
    label.textColor=[UIColor colorWithWhite: 0.333 alpha: 0.5];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 0.0);
    //label.font = [UIFont boldSystemFontOfSize:14];
    [label setFont:[UIFont fontWithName:@"verdana" size:9.f]];
    
    label.text = sectionTitle;
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [view setBackgroundColor:[UIColor colorWithWhite:1.0 alpha: 0.5]];
    
    [view autorelease];
    [view addSubview:label];
    
    return view;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"cat %d",[self.jsonArray count]);
    return [self.jsonArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    static NSString *CellIdentifier = @"Cell";
    CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;   
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *itemAtIndex = (NSDictionary *)[self.jsonArray objectAtIndex:indexPath.row];
    [cell setData:itemAtIndex];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self keyboardDown:nil];
}
- (void)dealloc
{
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
