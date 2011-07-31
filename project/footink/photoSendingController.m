//
//  photoSendingController.m
//  footink
//
//  Created by yongsik on 11. 7. 21..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "photoSendingController.h"
#import "photoSendingCell.h"
#import "GlobalStn.h"
#import "photoSpotView.h"
#import "photoEditController.h"
#import "photoPickerViewController.h"

#define DATA_SEND_URL @"http://footink.com/user/u"

@implementation photoSendingController
const CGFloat CROP_IMAGE_RECT_WIDTH	= 300.0;
const CGFloat CROP_IMAGE_RECT_HEIGHT	= 300.0;

@synthesize spotTable,postValue,spotLat,spotLng,spotName,spotArray,pushSpotName,pushCaption;
@synthesize fList,caption,selectedFilterTag,progressBack,lat,lng;

- (void)viewDidLoad{
    NSLog(@"viewdidload");
    self.tabBarController.tabBar.hidden = YES;
    
    UIImageView *logoimage=[[[UIImageView alloc]initWithFrame:CGRectMake(0,0,85,22)] autorelease] ;
    [logoimage setImage:[UIImage imageNamed:@"footink_logo.png"]];
    [self.navigationController.navigationBar.topItem setTitleView:logoimage];
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(cmdPrev)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)] autorelease];
 
    self.spotTable=[[[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds  style:UITableViewStyleGrouped] autorelease];
    //self.spotTable.editing = YES;
    self.spotTable.dataSource=self;
    self.spotTable.delegate=self;
    [self.view addSubview:self.spotTable];
    
    //[self.fList removeAllObjects];
    
    self.fList = [[NSMutableArray alloc] init];
    [self.fList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"캡션",@"text", nil]];
    [self.fList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"위치",@"text", nil]];
    [self.fList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"공유",@"text", nil]];
    
    self.spotArray = [[NSMutableArray alloc] init];
    NSString *spotnamechk;
    if(pushSpotName==nil){
        spotnamechk=@"스팟선택";
    }else{
        spotnamechk=pushSpotName;
    }
    [self.spotArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",spotnamechk],@"spotname", nil]];
    [self.spotArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",spotLat],@"lat", nil]];
    [self.spotArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",spotLng],@"lng", nil]];
        
    progressBack=[[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 200, [UIScreen mainScreen].bounds.size.width, 30)];
    [self.view addSubview:progressBack];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
    NSLog(@"sel %d",[[GlobalStn sharedSingleton] selectedFilterInt]);
   
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisAppear");
}

-(void)backgroundTap:(id)sender{
    
    [caption resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)note { 
    UIView *kbtop=[[UIView alloc] initWithFrame:CGRectMake(0.0, -30.0, [UIScreen mainScreen].bounds.size.width, 30)];
    kbtop.backgroundColor=[UIColor grayColor];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 90, 3, 70, 26);
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.adjustsImageWhenHighlighted = NO;
    //[doneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
    //[doneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(backgroundTap:) forControlEvents:UIControlEventTouchUpInside];
    [kbtop addSubview:doneButton];
    
    //3.1.x 와 4.0 호환 키보드 붙이기
    for( UIWindow *keyboardWindow in [[UIApplication sharedApplication] windows] ){
        for( UIView *keyboard in [keyboardWindow subviews] ){
            NSString *desc = [keyboard description];
            if( [desc hasPrefix:@"<UIKeyboard"]==YES ||
               [desc hasPrefix:@"<UIPeripheralHostView"] == YES ||
               [desc hasPrefix:@"<UISnap"] == YES )
            {
                [keyboard addSubview:kbtop];
            }
        }
    }
    
}

- (void)keyboardWillHide:(NSNotification *)note { 
    
    for( UIWindow *keyboardWindow in [[UIApplication sharedApplication] windows] ){
        for( UIView *keyboard in [keyboardWindow subviews] ){
            NSString *desc = [keyboard description];
            if( [desc hasPrefix:@"<UIKeyboard"]==YES ||
               [desc hasPrefix:@"<UIPeripheralHostView"] == YES ||
               [desc hasPrefix:@"<UISnap"] == YES )
            {
                for(UIView *subview in [keyboard subviews])
                {
                    [subview removeFromSuperview];
                }
                
            }
        }
    }
}


-(void)cmdPrev{
    photoEditController *cont=[[photoEditController alloc] init];
    cont.selectedTag=selectedFilterTag;
    selectedFilterTag=0;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    //transitioning = YES;
    transition.delegate = self;
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:cont animated:NO];
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.spotTable.layer addAnimation:transition forKey:nil];
    
    [cont release];
}
- (void)save{
    
    UIImage *imageData=[self savefilmFxEffect:[[GlobalStn sharedSingleton] selectedFilterInt]];
    

    NSMutableArray *valueData=[NSMutableArray array];
    NSString *withchk;
    if([[GlobalStn sharedSingleton] camPosition]==1){
        withchk=@"YES";
    }else{
        withchk=@"NO";
    }
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:withchk,@"with", nil]];
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[GlobalStn sharedSingleton] uname],@"uid", nil]];
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[GlobalStn sharedSingleton] ukey],@"privatekey", nil]];
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:caption.text,@"caption", nil]];
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:spotName.text,@"spotname", nil]];
    
    if(spotLat!=nil || spotLng!=nil){
        [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:spotLat,@"lat", nil]];
        [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:spotLng,@"lng", nil]];
    }
    
    CGRect progressframe=CGRectMake(10.0, 5.0, 200.0, 20.0);
    progressbar=[[HttpWrapper alloc] requestUrl:DATA_SEND_URL values:valueData progressBarFrame:(CGRect)progressframe image:imageData loc:nil delegate:self];
    [self.progressBack addSubview:progressbar];

   /* NSString *string = self.caption.text;
    NSLog(@"save %d",[string length]);
    
    if([string length] > 0){
    }else{
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"입력오류"];
        [alert setMessage:@"장소명이 입력되지 않았습니다."];
        [alert setDelegate:self];
        [alert addButtonWithTitle:@"확인"];
        //[alert addButtonWithTitle:@"No"];
        [alert show];
        [alert release];
    }*/
}
-(id)savefilmFxEffect:(int)selTag{
    UIImage *img=[self loadImage:@"temp"];
    CGRect cframe=CGRectMake(0.0, 0.0, CROP_IMAGE_RECT_WIDTH,CROP_IMAGE_RECT_HEIGHT);
    Filters *filterUIView=[[Filters alloc] initWithImage:img drawFrame:cframe fxfilm:selTag delegate:self];

    UIGraphicsBeginImageContext(filterUIView.bounds.size);
    [filterUIView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (UIImage*)loadImage:(NSString*)imageName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dirPath = [documentsDirectory stringByAppendingPathComponent:@"ImageCache"];
    NSString *fullPath = [dirPath stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@.png", imageName]];
    
    return [UIImage imageWithContentsOfFile:fullPath];
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFinishWithData:(NSData *)fileData{
    NSLog(@"%@",fileData);
    
    //NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
    //[nc postNotificationName:@"modalViewCloseObserver" object:self userInfo:nil];
    if([[GlobalStn sharedSingleton] camPosition]==1){
        [[GlobalStn sharedSingleton] setPickerChk:4];
    }else{
        [[GlobalStn sharedSingleton] setPickerChk:3];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
    
   
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFailWithError:(NSError *)error{
    
}
- (void)httpBarUpdated:(HttpWrapper *)httpProgBar{
    
}
- (void)dealloc
{

    [spotArray release];
    [caption release];

    [spotName release];
    [pushSpotName release];
    [pushCaption release];   
    [progressBack release];
    [spotLat release];
    [spotLng release];
    [fList release];
    [super dealloc];
    
    
}
#pragma - Textview delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if([text isEqualToString:@"\n"]) {

        [textView resignFirstResponder];

        return FALSE;
    }
 
    return TRUE;
}

- (void)textViewDidChange:(UITextView *)textView {
   // countLabel.text = [NSString stringWithFormat:@"%d", [textView.text length]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0){
        return 80;
    }else{
        return 40;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%d",[self.fList count]);
    
    
    return [self.fList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];

    if(cell == nil) {
        cell =  [[[UITableViewCell alloc] 
                  initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if(indexPath.row==0){
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.caption=[[[UITextView alloc] initWithFrame:CGRectMake(10.0, 12.0, 280.0, 60.0)] autorelease];
        //input.userInteractionEnabled = FALSE;
        self.caption.text=pushCaption;
        self.caption.layer.cornerRadius = 5;
        self.caption.layer.masksToBounds = YES;
        [cell.contentView addSubview:self.caption];
    }
    if(indexPath.row==1){
        self.spotName=[[[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 230.0, 30.0)] autorelease];
 
    
        [self.spotName setText:[[self.spotArray objectAtIndex:0] objectForKey:@"spotname"]];
        [cell.contentView addSubview:self.spotName];
    }
    if(indexPath.row==2){
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.textLabel setText:[[self.fList objectAtIndex:indexPath.row] objectForKey:@"text"]];
        NSArray *str=[[self.fList objectAtIndex:indexPath.row] allKeys];
        NSLog(@"%@",[str objectAtIndex:0]);
    }


    //[cell.textLabel setText:[[self.fList objectAtIndex:indexPath.row] objectForKey:@"text"]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//id AppID = [[UIApplication sharedApplication] delegate];
	//[AppID cmdOpenDetail:[fList objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row == 1 ){
        NSLog(@"modal");
        photoSpotView *category=[[photoSpotView alloc] init];
        category.prevCaption=caption.text;
       [self.navigationController pushViewController:category animated:YES];
        [category release];
        
    }else if(indexPath.row == 2 ){
        NSLog(@"%d",indexPath.row);
    }else{
        NSLog(@"%d",indexPath.row);
        //[self cmdEdit];
        [self.caption becomeFirstResponder];
        //self.spotName.text=@"dddd";
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row % 2 == 0);
}    

/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleNone) {
 id AppID = [[UIApplication sharedApplication] delegate];
 [AppID RemoveRecordWithNo:[[[self.fList objectAtIndex:indexPath.row] objectForKey:@"text"] intValue]];
 [self.fList removeObjectAtIndex:indexPath.row];
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } 
 }
 */
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
