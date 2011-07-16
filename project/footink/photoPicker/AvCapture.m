//
//  AvCapture.m
//  photoPicker
//
//  Created by yj on 11. 4. 17..
//  Copyright 2011 ag. All rights reserved.
//

#import "AvCapture.h"


@implementation AvCapture

// Create and configure a capture session and start it running

- (void)setupCaptureSession 

{
    
    NSError *error = nil;
    
    
    
    // Create the session
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    
    
    // Configure the session to produce lower resolution video frames, if your 
    
    // processing algorithm can cope. We'll specify medium quality for the
    
    // chosen device.
    
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    
    
    // Find a suitable AVCaptureDevice
    
    AVCaptureDevice *device = [AVCaptureDevice
                               
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    
    
    // Create a device input with the device and add it to the session.
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device 
                                   
                                                                        error:&error];
    
    if (!input) {
        
        // Handling the error appropriately.
        
    }
    
    [session addInput:input];
    
    
    
    // Create a VideoDataOutput and add it to the session
    
    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    
    [session addOutput:output];
    
    
    
    // Configure your output.
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    
    [output setSampleBufferDelegate:self queue:queue];
    
    dispatch_release(queue);
    
    
    
    // Specify the pixel format
    
    output.videoSettings = 
    
    [NSDictionary dictionaryWithObject:
     
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
     
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    
    
    
    
    // If you wish to cap the frame rate to a known value, such as 15 fps, set 
    
    // minFrameDuration.
    
    output.minFrameDuration = CMTimeMake(1, 15);
    
    
    
    // Start the session running to start the flow of data
    
    [session startRunning];
    
    
    
    // Assign session to an ivar.
    
    [self setSession:session];
    
}



// Delegate routine that is called when a sample buffer was written

- (void)captureOutput:(AVCaptureOutput *)captureOutput 

didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 

       fromConnection:(AVCaptureConnection *)connection

{ 
    
    // Create a UIImage from the sample buffer data
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    
    
    
    
}



// Create a UIImage from sample buffer data

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 

{
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // Lock the base address of the pixel buffer
    
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    
    
    // Get the number of bytes per row for the pixel buffer
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    
    // Get the pixel buffer width and height
    
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
    
    
    
    // Create a device-dependent RGB color space
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    
    if (!colorSpace) 
        
    {
        
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        
        return nil;
        
    }
    
    
    
    // Get the base address of the pixel buffer
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the data size for contiguous planes of the pixel buffer.
    
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer); 
    
    
    
    // Create a Quartz direct-access data provider that uses data we supply
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, 
                                                              
                                                              NULL);
    
    // Create a bitmap image from data supplied by our data provider
    
    CGImageRef cgImage = 
    
    CGImageCreate(width,
                  
                  height,
                  
                  8,
                  
                  32,
                  
                  bytesPerRow,
                  
                  colorSpace,
                  
                  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  
                  provider,
                  
                  NULL,
                  
                  true,
                  
                  kCGRenderingIntentDefault);
    
    CGDataProviderRelease(provider);
    
    CGColorSpaceRelease(colorSpace);
    
    
    
    // Create and return an image object representing the specified Quartz image
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    
    
    return image;}



/*
 
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 
 // Custom initialization
 
 }
 
 return self;
 
 }
 
 */



/*
 
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 
 - (void)loadView {
 
 }
 
 */





/*
 
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 
 - (void)viewDidLoad {
 
 [super viewDidLoad];
 
 }
 
 */





/*
 
 // Override to allow orientations other than the default portrait orientation.
 
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 
 // Return YES for supported orientations
 
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 
 }
 
 */



- (void)didReceiveMemoryWarning {
    
    // Releases the view if it doesn't have a superview.
    
    [super didReceiveMemoryWarning];
    
    
    
    // Release any cached data, images, etc that aren't in use.
    
}



- (void)viewDidUnload {
    
    // Release any retained subviews of the main view.
    
    // e.g. self.myOutlet = nil;
    
}





- (void)dealloc {
    
    [super dealloc];
    
}



@end

