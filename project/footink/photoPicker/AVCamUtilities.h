//
//  AVCamUtility.h
//  photoPicker
//
//  Created by yongsik on 11. 6. 1..
//  Copyright 2011 ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVCaptureConnection;

@interface AVCamUtilities : NSObject {
    
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

@end
