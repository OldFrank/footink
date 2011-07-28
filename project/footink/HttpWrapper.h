//
//  HttpWrapper.h
//  footink
//
//  Created by yongsik on 11. 7. 19..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class UIProgressView;
@protocol HttpWrapperDelegate;

@interface HttpWrapper : UIProgressView <CLLocationManagerDelegate>{
    NSURLConnection *httpconnection;
    NSHTTPURLResponse *hresponse;
    NSMutableData *receivedData;
    long long bytesReceived;
    long long expectedBytes;
    float percentComplete;
    int retryCounter;
    id<HttpWrapperDelegate> delegate;


}
@property (nonatomic,readonly,retain) NSURLConnection *httpconnection;
@property (nonatomic,retain) NSHTTPURLResponse *hresponse;
@property (nonatomic,readonly,retain) NSMutableData *receivedData;
@property (nonatomic, assign) id<HttpWrapperDelegate> delegate;
@property (nonatomic, readonly) float percentComplete;


-(id)requestUrl:(NSString *)url values:(NSMutableArray *)wrapData progressBarFrame:(CGRect)frame image:(UIImage *)imageAttach loc:(CLLocation *)coord delegate:(id <HttpWrapperDelegate>)wrappercontrol;
//- (BOOL)iUrl:(NSString *)url ivalues:(NSMutableArray *)wrapData iimage:(UIImage *)imageAttach iloc:(BOOL)coord idatezone:(BOOL)idate;

@end

@protocol HttpWrapperDelegate<NSObject>
@optional
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFinishWithData:(NSData *)fileData;
- (void)httpProgBar:(HttpWrapper *)httpProgBar didFailWithError:(NSError *)error;
- (void)httpBarUpdated:(HttpWrapper *)httpProgBar;

@end