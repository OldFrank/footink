//
//  photoPickerViewController.h
//  photoPicker
//
//  Created by Yongsik Cho on 11. 4. 11..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import <ImageIO/ImageIO.h>
#import "AvCaptureManager.h"
#import "footinkAppDelegate.h"


@class AvCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;

@interface photoPickerViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate>{
    UIButton *chbutton;

    UIButton *takebutton;

    UIImage *resizedImage;
    
    UIImagePickerController *imgPicker;
    UIViewController *scanModal;
    
    
    
    NSInteger chkClose;

}
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;



@property (nonatomic,retain) UIImagePickerController *imgPicker;
@property (nonatomic,retain) UIViewController *scanModal;


@property (nonatomic,retain) IBOutlet UIView *videoPreviewView;

@property (retain) AvCaptureManager *captureManager;
@property (nonatomic, retain) UILabel *scanningLabel;


@property (nonatomic,retain) IBOutlet UIBarButtonItem *cameraToggleButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *recordButton;
@property (nonatomic,retain) IBOutlet UILabel *focusModeLabel;





-(void) getPhoto;
-(void)print_free_memory;


#pragma mark Toolbar Actions
- (IBAction)toggleRecording:(id)sender;
- (IBAction)toggleCamera:(id)sender;



-(void)AVModal;



@end


