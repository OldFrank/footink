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
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>
#import "AvCaptureManager.h"
#import "footinkAppDelegate.h"

NSTimer *stopWatchTimer;
NSDate *startDate;

@class AvCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;

@interface photoPickerViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,CLLocationManagerDelegate>{
    UIButton *chbutton;
    UIButton *upload;
    UIButton *takebutton;
    UIImageView *imageview;
    UIImage *resizedImage;
    
    UIImagePickerController *imgPicker;
    UIViewController *scanModal;
    UIViewController *scanView;
    UIView *cAlertView;
    NSMutableData *returnData;
    
    NSInteger chkClose;
    
    NSURLConnection*			urlConnection;
    long						Total_FileSize;
	long                        CurLength;
	IBOutlet UIProgressView*	ProgressBar;
	IBOutlet UILabel*			ProgressLabel;

    NSThread *_thread;
}
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) UIImageView * imageview;

@property (nonatomic,retain) UIImagePickerController *imgPicker;
@property (nonatomic,retain) UIViewController *scanModal;
@property (nonatomic, retain) UIViewController *scanView;
@property (nonatomic, retain) UIView *cAlertView;
@property (nonatomic,retain) IBOutlet UIView *videoPreviewView;

@property (nonatomic,retain) AvCaptureManager *captureManager;
@property (nonatomic, retain) UILabel *scanningLabel;
@property (nonatomic, retain) NSMutableData *returnData;
@property (nonatomic, retain) NSThread *_thread;

@property (nonatomic,retain) IBOutlet UIBarButtonItem *cameraToggleButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *recordButton;
@property (nonatomic,retain) IBOutlet UILabel *focusModeLabel;


@property (nonatomic, retain) UIProgressView*	ProgressBar;
@property (nonatomic, retain) UILabel*			ProgressLabel;


-(void) getPhoto;
-(void)print_free_memory;
-(UIImage *)generatePhotoThumbnail:(UIImage *)image withRatio:(float)ratio;
-(UIImage *)resizeImage:(UIImage *)image width:(float)resizeWidth height:(float)resizeHeight;
-(UIImage *)maskingImage:(UIImage *)image maskImage:(NSString *)_maskImage;

#pragma mark Toolbar Actions
- (IBAction)toggleRecording:(id)sender;
- (IBAction)toggleCamera:(id)sender;

-(IBAction) uploadImage;

-(void)AVModal;
-(BOOL)requestUrl:(NSString *)url;


@end


