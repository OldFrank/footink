//
//  overlayView.h
//  footink
//
//  Created by yongsik on 11. 7. 18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@protocol overlayViewDelegate;

@interface overlayView : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
     id <overlayViewDelegate> delegate;
    
     UIImagePickerController *imagePickerController;
        
    @private
        UIBarButtonItem *takePictureButton;
        UIBarButtonItem *startStopButton;
        UIBarButtonItem *timedButton;
        UIBarButtonItem *cancelButton;
        
        NSTimer *tickTimer;
        NSTimer *cameraTimer;
        
        SystemSoundID tickSound;
}    
    
@property (nonatomic, assign) id <overlayViewDelegate> delegate;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *takePictureButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *startStopButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *timedButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;

@property (nonatomic, retain) NSTimer *tickTimer;
@property (nonatomic, retain) NSTimer *cameraTimer;

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType;

// camera page (overlay view)
- (IBAction)done:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)startStop:(id)sender;
- (IBAction)timedTakePhoto:(id)sender;

@end

@protocol overlayViewDelegate
- (void)didTakePicture:(UIImage *)picture;
- (void)didFinishWithCamera;
@end
