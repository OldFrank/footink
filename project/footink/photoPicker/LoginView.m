//
//  Login.m
//  photoPicker
//
//  Created by yongsik on 11. 4. 30..
//  Copyright 2011 ag. All rights reserved.
//

#import "LoginView.h"
#include <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Reachability.h"
#import <ImageIO/ImageIO.h>
#import "JSON.h"

#define AUTH_URL @"http://footink.com/user/AppAuth"

@implementation LoginView


@synthesize NameInput;
@synthesize EmailInput;
@synthesize PwdInput;
@synthesize ProfileInput;
@synthesize imageview;
@synthesize scrollView;
@synthesize jsonArray;
@synthesize activeField;

@synthesize imageData;

@synthesize cameraController,progressBack,viewCont;

- (id) init{
    
    self=[super init];
    if(self!=nil){
        self.title=@"Log IN";
    }
    return self;
}
-(void)viewDidLoad{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    self.scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
    
    self.scrollView.contentSize = self.view.frame.size;
    [self.scrollView setBackgroundColor:[UIColor grayColor]];
     self.scrollView.scrollEnabled = YES;
     [self.view addSubview:self.scrollView];
    
    UILabel *Ltitle = [[UILabel alloc] initWithFrame:CGRectMake(90.0,20.0,70.0,30.0)];
    Ltitle.textAlignment = UITextAlignmentLeft;
    Ltitle.text=@"FOOT INK --";
    Ltitle.font=[UIFont systemFontOfSize:12.0f];
    Ltitle.backgroundColor=[UIColor clearColor];
    Ltitle.minimumFontSize=0.8;
    [self.scrollView addSubview:Ltitle];
    
    UILabel *ProfileText = [[UILabel alloc] initWithFrame:CGRectMake(30.0,55.0,70.0,30.0)];
    ProfileText.textAlignment = UITextAlignmentLeft;
    ProfileText.text=@"Profile";
    ProfileText.font=[UIFont systemFontOfSize:12.0f];
    ProfileText.backgroundColor=[UIColor clearColor];
    [self.scrollView addSubview:ProfileText];
    
    imageview = [[UIImageView alloc] initWithFrame:CGRectMake(90.0, 55.0, 100.0, 100.0)];
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    [imageview setBackgroundColor:[UIColor blueColor]];

    imageview.image=[UIImage imageNamed:@"Icon.png"];
    imageAttachChk=NO;
    [self.scrollView addSubview:imageview];
    
    UIButton *TakePhoto=[[UIButton alloc] initWithFrame:CGRectMake(200.0, 55.0, 100.0, 40.0)];
    TakePhoto.titleLabel.textColor = [UIColor darkGrayColor];
    TakePhoto.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [TakePhoto setTitle:@"프로필 사진 업로드" forState:UIControlStateNormal];
    [TakePhoto addTarget:self action:@selector(actTaken) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:TakePhoto];

    
    UILabel *NameText = [[[UILabel alloc] initWithFrame:CGRectMake(30.0,170.0,50.0,30.0)] autorelease];
    NameText.textAlignment = UITextAlignmentLeft;
    NameText.text=@"Name";
    NameText.font=[UIFont systemFontOfSize:12.0f];
    NameText.backgroundColor=[UIColor clearColor];
    [self.scrollView addSubview:NameText];
    
    NameInput = [[UITextField alloc] initWithFrame:CGRectMake(90.0, 170.0, 200.0, 30.0)];
    NameInput.autocapitalizationType=UITextAutocapitalizationTypeNone;
    NameInput.keyboardType=UIKeyboardTypeDefault;
    NameInput.delegate = self;
    
    [NameInput setBorderStyle:UITextBorderStyleRoundedRect];
    [self.scrollView addSubview:NameInput];
    
    
    UILabel *EmailText = [[[UILabel alloc] initWithFrame:CGRectMake(30.0,210.0,50.0,30.0)] autorelease];
    EmailText.textAlignment = UITextAlignmentLeft;
    EmailText.text=@"Email";
    EmailText.font=[UIFont systemFontOfSize:12.0f];
    EmailText.backgroundColor=[UIColor clearColor];
    [self.scrollView addSubview:EmailText];
    
    EmailInput = [[UITextField alloc] initWithFrame:CGRectMake(90.0, 210.0, 200.0, 30.0)];
    [EmailInput setBorderStyle:UITextBorderStyleRoundedRect];
    EmailInput.autocapitalizationType=UITextAutocapitalizationTypeNone;
    EmailInput.keyboardType = UIKeyboardTypeEmailAddress;
    EmailInput.delegate=self;
    [self.scrollView addSubview:EmailInput];
    
    /*UITextField *SInput = [[UITextField alloc] initWithFrame:CGRectMake(90.0, 250.0, 200.0, 30.0)];
    [SInput setBorderStyle:UITextBorderStyleRoundedRect];
    SInput.delegate=self;
    [self.scrollView addSubview:SInput];
    
    
    UILabel *PwdText = [[[UILabel alloc] initWithFrame:CGRectMake(30.0,255.0,50.0,30.0)] autorelease];
    PwdText.textAlignment = UITextAlignmentLeft;
    PwdText.text=@"Password";
    PwdText.font=[UIFont systemFontOfSize:12.0f];
    [self.view addSubview:PwdText];

    PwdInput = [[UITextField alloc] initWithFrame:CGRectMake(90.0, 255.0, 200.0, 30.0)];
    [PwdInput setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:PwdInput];
     */
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.frame = CGRectMake(90.0, 260.0, 140.0, 40.0);
    sendButton.titleLabel.textColor = [UIColor darkGrayColor];
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [sendButton setTitle:@"Submit" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:sendButton];
    
    progressBack=[[UIView alloc] initWithFrame:CGRectMake(0.0, 310.0, 200.0, 20.0)];
    [self.scrollView addSubview:progressBack];

    [self registerForKeyboardNotifications];
    keyboardVisible = NO;
}
-(void)actTaken{

    NSArray *array = [[NSArray alloc] initWithObjects:
                      [NSString stringWithString:@"카메라촬영"],
                      [NSString stringWithString:@"라이브러리에서 선택"],
                      nil];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"프로필사진 업로드"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (int i = 0; i < 2; i++) {
        
        [actionSheet addButtonWithTitle:[array objectAtIndex:i]];
        
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = 2;
    
    [actionSheet showInView:self.view];

}
-(void) actionSheet: (UIActionSheet *)anActionSheet didDismissWithButtonIndex: (NSInteger) buttonIndex
{
    [anActionSheet dismissWithClickedButtonIndex:buttonIndex animated:NO];
    if (buttonIndex == [anActionSheet cancelButtonIndex]) {
       
    }
    if (buttonIndex == 0) {
        [self CameraOpen];
    } else if (buttonIndex == 1) {
       [self LibraryPhoto];
    }
}
-(void)CameraOpen{
#if !TARGET_IPHONE_SIMULATOR
    [cameraController release];
    cameraController = [[[UIImagePickerController alloc] init] retain];
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraController.cameraViewTransform = CGAffineTransformScale(self.cameraController.cameraViewTransform,1.13f,1.13f);
    cameraController.delegate = self;
    [cameraController setAllowsEditing:YES]; 
    self.cameraController.showsCameraControls = YES;
    self.cameraController.navigationBarHidden = YES;
    [self.view.superview addSubview:cameraController.view];
    [self presentModalViewController:cameraController animated:YES];
#else
    NSLog(@"works divice only. :)");
#endif
}
-(void)LibraryPhoto{
    cameraController = [[UIImagePickerController alloc] init];
    cameraController.allowsEditing = YES;
    cameraController.delegate = self;
    cameraController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.cameraController.navigationBarHidden = YES;
    [self.view.superview addSubview:cameraController.view];
    [self presentModalViewController:cameraController animated:YES];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
   imageview.image = image;
    imageAttachChk=YES;
   //UIImage *originalImage = [editingInfo objectForKey:UIImagePickerControllerOriginalImage];
   [picker dismissModalViewControllerAnimated:YES];
}
/*
- (void)imagePickerController:(UIImagePickerController *)picker   
didFinishPickingMediaWithInfo:(NSDictionary *)info {  
    imageview.image = [info objectForKey:UIImagePickerControllerEditedImage];  
    [picker dismissModalViewControllerAnimated:YES];  
}
*/
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"%@",textField);
    if ([textField isEqual:NameInput]) {
        //2번째로 포커스 이
        
        [EmailInput becomeFirstResponder];
    } else {
        //키보드 감춤 & 로그인!
        [EmailInput resignFirstResponder];
        //[self loginProcess];
    }
    
    return YES;
}
- (void)registerForKeyboardNotifications
{
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}



// Called when the UIKeyboardDidShowNotification is sent.

- (void)keyboardWasShown:(NSNotification*)aNotification
{
   
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"--%f",kbSize.height);
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    
    aRect.size.height -= kbSize.height;
    NSLog(@"--%f",aRect.size.height);
    if (CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        NSLog(@"--%f",activeField.frame.origin.y-kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}
/*
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect bkgndRect = activeField.superview.frame;
    
    bkgndRect.size.height += kbSize.height;
    
    [activeField.superview setFrame:bkgndRect];
    [scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y-kbSize.height) animated:YES];
    
}
 */
// Called when the UIKeyboardWillHideNotification is sent

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
 
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;

}

- (void) viewWillDisappear:(BOOL)animated {
    
    NSLog(@"Unregistering for keyboard events");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (int)checkNetwork{
    // 네트워크의 상태를 체크.
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    int status= 0;
    
    // 상태에 맞는 메세지
    switch (netStatus)
    {
        case NotReachable:
        {
            status = 0; //연결실패
            break;
        }
        case ReachableViaWWAN:
        {
            status = 1; //GRPS/3G
            break;
        }
        case ReachableViaWiFi:
        {
            status= 2; //wifi
            break;
        }
    }
    return status;
}
-(BOOL)HttpAuth:(NSMutableArray *)regValue{
    if ([self checkNetwork]==0) {
        UIAlertView *uAlert=[[UIAlertView alloc] initWithTitle:@"네트워크 오류" message:@"인터넷이 연결되어 있지 않습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [uAlert show];
        return FALSE;
    }
    NSArray *recvData=regValue;
    NSMutableArray *valueData=[NSMutableArray array];
    NSLog(@"name input %@",[recvData objectAtIndex:0]);
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[recvData objectAtIndex:0],@"username", nil]];
    [valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[recvData objectAtIndex:1],@"uemail", nil]];
    //[valueData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[recvData objectAtIndex:2],@"passwdcfm", nil]];
    
    CGRect progressframe=CGRectMake(10.0, 5.0, 200.0, 20.0);
    progressbar=[[HttpWrapper alloc] requestUrl:AUTH_URL values:valueData progressBarFrame:(CGRect)progressframe image:imageview.image loc:nil delegate:self];
    [self.progressBack addSubview:progressbar];
    
    return TRUE;
}
#pragma mark URL Connection Event Handlers

- (void)httpProgBar:(HttpWrapper *)httpProgBar didFinishWithData:(NSData *)fileData{
    
    id stringReply;
    stringReply = (NSString *)[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    self.jsonArray=[stringReply JSONValue];
    NSLog(@"%@",self.jsonArray);
    [self AddAuthRecord];
    
   
    PhotoRoot *cont=[[PhotoRoot alloc] init];
    [self.navigationController popToViewController:cont animated:YES];
    //self.tabBarController.selectedIndex=0;
}
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFailWithError:(NSError *)error{
    
}
- (void)httpBarUpdated:(HttpWrapper *)httpProgBar{
    
}
- (BOOL)sendLogin{

    if ([self checkNetwork]==0) {
        UIAlertView *uAlert=[[UIAlertView alloc] initWithTitle:@"네트워크 오류" message:@"인터넷이 연결되어 있지 않습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [uAlert show];
        NSLog(@"네트워크오류.");
    }else{
        NSLog(@"%@",NameInput.text);
        
        NSMutableArray *regVal = [[NSMutableArray alloc] init];
        [regVal addObject:NameInput.text];
        [regVal addObject:EmailInput.text];
        //[regVal addObject:PwdInput.text];
        
        if(imageAttachChk==NO){
            UIAlertView *imgAlert=[[UIAlertView alloc] initWithTitle:@"입력 오류" message:@"프로필 이미지가 첨부되지 않았습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
            [imgAlert show];
            return FALSE;
        }
        if(NameInput.text==nil){
            UIAlertView *nicAlert=[[UIAlertView alloc] initWithTitle:@"입력 오류" message:@"닉네임이 입력되지 않았습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
            [nicAlert show];
            return FALSE;
        }
        BOOL e=[self IsValidEmail:EmailInput.text];
        if(e==FALSE){
            UIAlertView *uAlert=[[UIAlertView alloc] initWithTitle:@"입력 오류" message:@"이메일 형식이 옳지 않습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
            [uAlert show];
            return FALSE;
        }else{
            BOOL f=[self HttpAuth:regVal];
            
            if(f==TRUE){

            }else{
                UIAlertView *uAlert=[[UIAlertView alloc] initWithTitle:@"가입 오류" message:@"등록에 실패하였습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
                [uAlert show];
                NSLog(@"가입오류.");
                return FALSE;
            }
        }
    }
    return TRUE;
}

-(BOOL)IsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; 
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(void)alertView:(UIAlertView *)alert_view didDismissWithButtonIndex:(NSInteger)button_index{
    if(button_index == 0){
        //
    }
    if(button_index ==1){
        //
    }
}
-(void)AddAuthRecord{
    sqlite3 *db;
    NSString *Dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [Dir stringByAppendingPathComponent:@"setting.sqlite"];
    
    if(sqlite3_open([filePath UTF8String],&db) != SQLITE_OK){
        sqlite3_close(db);
        NSLog(@"Error");
        return;
    }
    sqlite3_stmt *statement;
    NSString *Name=[self.jsonArray objectForKey:@"name"];
    NSString *Email=[self.jsonArray objectForKey:@"email"];
    NSString *Privatekey=[self.jsonArray objectForKey:@"private"];
    NSString *Profile=[self.jsonArray objectForKey:@"profile"];
    NSLog(@"sqlite %@",Profile);
    char *sql = "INSERT or REPLACE INTO setting (name,email,privatekey,profile,share,gps) VALUES(?,?,?,?,?,?)";
    //NSLog(@"%@",sql);
    
    if(sqlite3_prepare_v2(db,sql,-1,&statement,NULL)==SQLITE_OK){
        
        sqlite3_bind_text(statement,1,[Name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement,2,[Email UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3,[Privatekey UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4,[Profile UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 5, 1);
        sqlite3_bind_int(statement, 6, 1);
        
        NSLog(@"exec");
        if(sqlite3_step(statement) != SQLITE_DONE){
            NSLog(@"Error");
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
}

- (void)dealloc
{
    [NameInput release];
    [EmailInput release];
    [PwdInput release];
    [ProfileInput release];
    [imageview release];
    [scrollView release];
    [jsonArray release];
    [activeField release];
    [cameraController release];
    //[imageData release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

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
