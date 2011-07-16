//
//  ImageAnnotation.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 22..
//  Copyright 2011 ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ImageAnnotation : MKAnnotationView
{
	UIImageView* _imageView;
}

@property (nonatomic, retain) UIImageView* imageView;
@end
