//
//  Login.h
//  photoPicker
//
//  Created by yongsik on 11. 4. 30..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "footinkAppDelegate.h"

@interface LoginView : UIViewController <UINavigationControllerDelegate,UIScrollViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>{

    UITextField *NameInput;
    UITextField *EmailInput;
    UITextField *PwdInput;
    UITextField *ProfileInput;
    UIImageView *imageview;
    UIScrollView *scrollView;
    BOOL keyboardVisible;
    NSDictionary *jsonArray;
    UITextField *activeField;
    
    
    NSURLConnection *connection;
    NSData *imageData;
    NSHTTPURLResponse *response;
    NSMutableData *responseData;
    
    int retryCounter;

    IBOutlet UIProgressView *uploadProgress;
    IBOutlet UILabel *uploadProgressMessage;
    
    UIImagePickerController *cameraController;
}
@property (nonatomic,retain) UITextField *NameInput;
@property (nonatomic,retain) UITextField *EmailInput;
@property (nonatomic,retain) UITextField *PwdInput;
@property (nonatomic,retain) UITextField *ProfileInput;
@property (nonatomic,retain) UIImageView *imageview;
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) NSDictionary *jsonArray;
@property (nonatomic,retain) UITextField *activeField;
@property (nonatomic,retain) NSURLConnection *connection;
@property (nonatomic,retain) NSData *imageData;
@property (nonatomic,retain) NSHTTPURLResponse *response;
@property (nonatomic,retain) NSMutableData *responseData;
@property (nonatomic, retain) UIImagePickerController *cameraController;


-(void)AddAuthRecord;
-(BOOL)HttpAuth:(NSMutableArray *)regValue;
-(BOOL) IsValidEmail:(NSString *)checkString;
-(void) registerForKeyboardNotifications;
-(void)CameraOpen;
-(void)LibraryPhoto;
-(void)sendLogin;
@end
