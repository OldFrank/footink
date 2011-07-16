//
//  AvCaptureManager.h
//  photoPicker
//
//  Created by Yongsik Cho on 11. 4. 18..
//  Copyright 2011 ag. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

@class AVCamRecorder;
@protocol AVCamCaptureManagerDelegate;

@interface AvCaptureManager : NSObject {
    
}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *avsession;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) UIImage *stillImage;
@property (nonatomic,assign) AVCaptureVideoOrientation orientation;
@property (nonatomic,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic,retain) AVCaptureDeviceInput *audioInput;
@property (nonatomic,retain) AVCamRecorder *recorder;
@property (nonatomic,assign) id deviceConnectedObserver;
@property (nonatomic,assign) id deviceDisconnectedObserver;
@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundRecordingID;

@property (nonatomic,assign) id <AVCamCaptureManagerDelegate> delegate;

- (BOOL) setupSession;
- (void) startRecording;
- (void) stopRecording;

- (void)captureStillImage;
- (BOOL) toggleCamera;
- (NSUInteger) cameraCount;
- (NSUInteger) micCount;
- (void) autoFocusAtPoint:(CGPoint)point;
- (void) continuousFocusAtPoint:(CGPoint)point;

//- (AVCaptureDevice *) frontFacingCamera;
//- (AVCaptureDevice *) backFacingCamera;
@end

@protocol AVCamCaptureManagerDelegate <NSObject>
@optional
- (void) captureManager:(AvCaptureManager *)captureManager didFailWithError:(NSError *)error;
- (void) captureManagerRecordingBegan:(AvCaptureManager *)captureManager;
- (void) captureManagerRecordingFinished:(AvCaptureManager *)captureManager;
- (void) captureManagerStillImageCaptured:(AvCaptureManager *)captureManager;
- (void) captureManagerDeviceConfigurationChanged:(AvCaptureManager *)captureManager;
@end