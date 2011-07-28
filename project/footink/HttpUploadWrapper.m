//
//  HttpUploadWrapper.m
//  footink
//
//  Created by yongsik on 11. 7. 21..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HttpUploadWrapper.h"


@implementation HttpUploadWrapper

@synthesize httpconnection;
@synthesize hresponse;
@synthesize delegate;
@synthesize receivedData;
@synthesize percentComplete;

-(id)requestUrl:(NSString *)url values:(NSMutableArray *)wrapData progressBarFrame:(CGRect)frame image:(UIImage *)imageAttach loc:(BOOL)coord datezone:(BOOL)date delegate:(id <HttpUploadWrapperDelegate>)wrappercontrol{
    
    self = [super initWithFrame:frame];
    if(self) {
        self.delegate=wrappercontrol;
        bytesReceived = percentComplete = 0;
        receivedData = [[NSMutableData alloc] initWithLength:0];
        self.progress = 0.0;
        self.backgroundColor = [UIColor clearColor];
        
        NSData *imageData = UIImageJPEGRepresentation(imageAttach,90);
        
        
        CLLocationManager * locationManager = [[CLLocationManager alloc] init];
        
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [locationManager setDelegate:self];
        CLLocation* location = [locationManager location];
        CLLocationCoordinate2D coordinate = [location coordinate];
        
        [locationManager release];
        
        NSDate *currentDate=[NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        //timezone설정
        //NSTimeZone *usTimeZone = [NSTimeZone timeZoneWithName:@"US/Pacific"];
        //NSTimeZone *usTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        
        
        NSTimeZone *usTimeZone = [NSTimeZone timeZoneWithName:@"Asia/Seoul"];
        [dateFormatter setTimeZone:usTimeZone];
        
        
        NSDateFormatter *gdateFormatter = [[NSDateFormatter alloc] init];
        [gdateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] 
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:30.0];
        
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        
        
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        //post append
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"lat\"\r\n\r\n%f",coordinate.latitude] dataUsingEncoding:NSUTF8StringEncoding] ];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"lon\"\r\n\r\n%f",coordinate.longitude] dataUsingEncoding:NSUTF8StringEncoding] ];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"gdate\"\r\n\r\n%@",[gdateFormatter stringFromDate:currentDate]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding] ];
        //file attach
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@.jpg\"\r\n",[dateFormatter stringFromDate:currentDate]] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];
        
        [dateFormatter release];
        [gdateFormatter release];
        
        
        httpconnection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        if(httpconnection == nil) {
            [self.delegate httpProgBar:self didFailWithError:[NSError errorWithDomain:@"http Error" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"NSURLConnection Failed", NSLocalizedDescriptionKey, nil]]];
        }
    }
    return self;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
    
    NSInteger receivedLen = [data length];
    bytesReceived = (bytesReceived + receivedLen);
    
    if(expectedBytes != NSURLResponseUnknownLength) {
        self.progress = ((bytesReceived/(float)expectedBytes)*100)/100;
        percentComplete = self.progress*100;
    }
    
    
}
- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    self.progress = (float) totalBytesWritten / totalBytesExpectedToWrite;
    [delegate httpBarUpdated:self];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate httpProgBar:self didFailWithError:error];
    httpconnection = nil;
    
    
    //uploadProgress.progress = 0.0f;
    //uploadProgressMessage.text = @"An error occurred, retrying in 10 seconds...";
    
    retryCounter = 10;
    [self performSelector:@selector(retry) withObject:nil afterDelay:1.0f];
    [self.delegate httpProgBar:self didFailWithError:error];
    //[connection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    expectedBytes = [response expectedContentLength];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    httpconnection = nil;
    
    id stringReply;
    stringReply = (NSString *)[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    NSLog(@"reply from server: %@", stringReply);
    //NSURLResponse *lresponse;
    NSHTTPURLResponse *httpResponse;
    httpResponse = (NSHTTPURLResponse *)self.hresponse;
    
    NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]); 
    NSLog(@"HTTP Status code: %d", [self.hresponse statusCode]);
    
    if ([self.hresponse statusCode] == 200) {
        //uploadProgress.progress = 1.0f;
        [self.delegate httpProgBar:self didFinishWithData:self.receivedData];
        
    } else {
        //uploadProgress.progress = 0.0f;
        //uploadProgressMessage.text = @"10초 동안 재시도";
        
        retryCounter = 10;
        [self performSelector:@selector(retry) withObject:nil afterDelay:1.0f];
    }
    
    self.hresponse = nil;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}
/*
 - (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
 
 self.progress = (float) totalBytesWritten / totalBytesExpectedToWrite;
 
 NSLog(@"wrapper--- %f",(float) totalBytesWritten / totalBytesExpectedToWrite);
 
 }*/
- (void)retry {
    retryCounter--;
    
    if (retryCounter <= 0) {
        
    } else {
        //uploadProgressMessage.text =
        [NSString stringWithFormat:@"An error occurred, retrying in %d second%@...",
         retryCounter,
         retryCounter != 1 ? @"s" : @""];
        
        [self performSelector:@selector(retry) withObject:nil afterDelay:1.0f];
    }
}

- (void)dealloc {
    [httpconnection release];
    //httpconnection=nil;
    [hresponse release];
    hresponse=nil;
    [receivedData release];
    receivedData=nil;
    
    [super dealloc];
}

@end