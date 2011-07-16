//
//  BrancheAnnotation.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface BrancheAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
}

@property (copy) NSString *title;
@property (copy) NSString *subtitle;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

+ (BrancheAnnotation *)createAnnotation:(CLLocationCoordinate2D)theCoordinate;

@end
