//
//  Login.h
//  photoPicker
//
//  Created by yongsik on 11. 4. 30..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "footinkAppDelegate.h"
#import "HttpWrapper.h"

@interface LoginView : UIViewController <HttpWrapperDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>{

    UITextField *NameInput;
    UITextField *EmailInput;
    UITextField *PwdInput;
    UITextField *ProfileInput;
    UIImageView *imageview;
    UIScrollView *scrollView;
    BOOL keyboardVisible;
    NSDictionary *jsonArray;
    UITextField *activeField;
    

    NSData *imageData;

    

    UIView *viewCont;
    UIImagePickerController *cameraController;
    HttpWrapper *progressbar;
    UIView *progressBack;
    
    BOOL imageAttachChk;
}
@property (nonatomic,retain) UITextField *NameInput;
@property (nonatomic,retain) UITextField *EmailInput;
@property (nonatomic,retain) UITextField *PwdInput;
@property (nonatomic,retain) UITextField *ProfileInput;
@property (nonatomic,retain) UIImageView *imageview;
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) NSDictionary *jsonArray;
@property (nonatomic,retain) UITextField *activeField;

@property (nonatomic,retain) NSData *imageData;


@property (nonatomic, retain) UIImagePickerController *cameraController;
@property (nonatomic, retain) UIView *progressBack;
@property (nonatomic, retain) UIView *viewCont;

-(void)AddAuthRecord;
-(BOOL)HttpAuth:(NSMutableArray *)regValue;
-(BOOL) IsValidEmail:(NSString *)checkString;
-(void) registerForKeyboardNotifications;
-(void)CameraOpen;
-(void)LibraryPhoto;
-(BOOL)sendLogin;
@end
