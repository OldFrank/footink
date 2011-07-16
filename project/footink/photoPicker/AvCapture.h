//
//  AvCapture.h
//  photoPicker
//
//  Created by yj on 11. 4. 17..
//  Copyright 2011 ag. All rights reserved.
//


#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

#import <QuartzCore/QuartzCore.h>

#import <CoreMedia/CoreMedia.h>



@interface AvCapture : UIViewController {
    
    AVCaptureSession*            session;
    
    AVCaptureDevice*             device;
    
    NSError*                     error;
    
    AVCaptureInput*              input;
    
    AVCaptureStillImageOutput*   output;
    
}



@end
