//
//  MapAnnotation.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 22..
//  Copyright 2011 ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// types of annotations for which we will provide annotation views. 
typedef enum {
	MapAnnotationTypeStart = 0,
	MapAnnotationTypeEnd   = 1,
	MapAnnotationTypeImage = 2
} MapAnnotationType;

@interface MapAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D _coordinate;
	MapAnnotationType    _annotationType;
	NSString*              _title;
	NSString*              _userData;
	NSURL*                 _url;    
    //NSString *subtitle;
}

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate 
		  annotationType:(MapAnnotationType) annotationType
				   title:(NSString*)title;

@property MapAnnotationType annotationType;
@property (nonatomic, retain) NSString* userData;
@property (nonatomic, retain) NSURL* url;
//@property (nonatomic,copy) NSString *subtitle;

@end

