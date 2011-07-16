//
//  ImageAnnotation.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 22..
//  Copyright 2011 ag. All rights reserved.
//

#import "ImageAnnotation.h"
#import "MapAnnotation.h"

#define kHeight 100
#define kWidth  100
#define kBorder 2

@implementation ImageAnnotation
@synthesize imageView = _imageView;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	self.frame = CGRectMake(0, 0, kWidth, kHeight);
	self.backgroundColor = [UIColor whiteColor];
	
	MapAnnotation* csAnnotation = (MapAnnotation*)annotation;
	
	UIImage* image = [UIImage imageNamed:csAnnotation.userData];
	_imageView = [[UIImageView alloc] initWithImage:image];
	
	_imageView.frame = CGRectMake(kBorder, kBorder, kWidth - 2 * kBorder, kWidth - 2 * kBorder);
	[self addSubview:_imageView];
	
	return self;
	
}


-(void) dealloc
{
	[_imageView release];
	[super dealloc];
}


@end
