//
//  HttpUploadWrapper.h
//  footink
//
//  Created by yongsik on 11. 7. 21..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class UIProgressView;
@protocol HttpUploadWrapperDelegate;

@interface HttpUploadWrapper : UIProgressView <CLLocationManagerDelegate>{
    NSURLConnection *httpconnection;
    NSHTTPURLResponse *hresponse;
    NSMutableData *receivedData;
    
    long long bytesReceived;
    long long expectedBytes;
    float percentComplete;
    
    int retryCounter;
    
    id<HttpUploadWrapperDelegate> delegate;
    
}

@property (nonatomic,readonly,retain) NSURLConnection *httpconnection;
@property (nonatomic,retain) NSHTTPURLResponse *hresponse;
@property (nonatomic,readonly,retain) NSMutableData *receivedData;
@property (nonatomic, assign) id<HttpUploadWrapperDelegate> delegate;

@property (nonatomic, readonly) float percentComplete;

-(id)requestUrl:(NSString *)url values:(NSMutableArray *)wrapData progressBarFrame:(CGRect)frame image:(UIImage *)imageAttach loc:(BOOL)coord datezone:(BOOL)date delegate:(id <HttpUploadWrapperDelegate>)wrappercontrol;
//- (BOOL)iUrl:(NSString *)url ivalues:(NSMutableArray *)wrapData iimage:(UIImage *)imageAttach iloc:(BOOL)coord idatezone:(BOOL)idate;

@end

@protocol HttpUploadWrapperDelegate<NSObject>
@optional
- (void)httpProgBar:(HttpUploadWrapper *)httpProgBar didFinishWithData:(NSData *)fileData;
- (void)httpProgBar:(HttpUploadWrapper *)httpProgBar didFailWithError:(NSError *)error;
- (void)httpBarUpdated:(HttpUploadWrapper *)httpProgBar;
@end