
//
//  gradientView.m
//  photoPicker
//
//  Created by yongsik on 11. 7. 16..
//  Copyright 2011 ag. All rights reserved.
//

#import "gradientView.h"

 
@implementation gradientView
 
@synthesize mirrored;
 
- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
     
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t numLocations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };

    CGFloat components[8] = { startRed, startGreen, startBlue, 1.0, endRed, endGreen, endBlue, 1.0 };
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, numLocations);
    
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds)/2.0);
    CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));

   if (!mirrored)
   {
          CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);
   }
   else
   {

    	  CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
          CGFloat components2[8] = { endRed, endGreen, endBlue, 1.0, startRed, startGreen, startBlue, 1.0 };
          CGGradientRelease(glossGradient);
           glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components2, locations, numLocations);
          CGContextDrawLinearGradient(currentContext, glossGradient, midCenter, bottomCenter, 0);
    }

    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
}

- (void) setColours:(float) _startRed:(float) _startGreen:(float) _startBlue:(float) _endRed:(float) _endGreen:(float)_endBlue
{
	    startRed = _startRed;
	    startGreen = _startGreen;
	    startBlue = _startBlue;
	 
	    endRed = _endRed;
	    endGreen = _endGreen;
    endBlue = _endBlue;
}

- (void) setColoursWithCGColors:(CGColorRef)color1:(CGColorRef)color2
{
    const CGFloat *startComponents = CGColorGetComponents(color1);
    const CGFloat *endComponents = CGColorGetComponents(color2);
 
    [self setColours:startComponents[0]:startComponents[1]:startComponents[2]:endComponents[0]:endComponents[1]:endComponents[2]];
}
 
- (void)dealloc
{
	    [super dealloc];
}
 
@end