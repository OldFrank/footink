//
//  Branche.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface Branche : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	
	NSString *name;
	NSString *address;
	NSString *addressDtail;
	NSString *phoneNo;
	NSNumber *latitude;
	NSNumber *longitude;
}

// 좌표는 프라퍼티인 latitude와 longitude로 부터 가져옴.
//@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *addressDtail;
@property (nonatomic, retain) NSString *phoneNo;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;

#pragma mark -
#pragma mark MapKit Annotation Protocol

+ (Branche *)createAnnotation:(CLLocationCoordinate2D)coordinate;

@end
