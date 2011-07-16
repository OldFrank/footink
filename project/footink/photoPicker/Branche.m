//
//  Branche.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import "Branche.h"


@implementation Branche

@synthesize coordinate, name, address, addressDtail, phoneNo, latitude, longitude;

// 이 메소드를 구현하여(카-값 옵저버) 좌표가 변경되었을 때 사용.
+ (NSSet *)keyPathsForValuesAffectingCoordinate {
    return [NSSet setWithObjects:@"latitude", @"longitude", nil];
}


// 좌표.
- (CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D brancheCoordinate;
	
    brancheCoordinate.latitude = [self.latitude doubleValue];
    brancheCoordinate.longitude = [self.longitude doubleValue];
	
    return brancheCoordinate;
}


+ (Branche*)createAnnotation:(CLLocationCoordinate2D)coordinate {
	Branche *brancheAnnotation = [Branche alloc];
	brancheAnnotation.coordinate = coordinate;
	return [brancheAnnotation autorelease];
}


@end
