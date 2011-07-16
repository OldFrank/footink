//
//  MKMapView-CoordsDisplay.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface MKMapView(CoordsDisplay)

- (BOOL)coordinatesInRegion:(CLLocationCoordinate2D)coords;

@end
