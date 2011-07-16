//
//  MapLocation.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface MapLocation : NSObject <MKAnnotation, NSCoding> {
	NSString *streetAddress;
    NSString *city;
    NSString *state;
    NSString *zip;
    
	// 지도 위에서 어노테이션의 위치를 추적하는데 사용함.
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, copy) NSString *streetAddress;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@end
