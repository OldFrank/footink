//
//  withRadius.m
//  photoPicker
//
//  Created by yongsik on 11. 7. 13..
//  Copyright 2011 ag. All rights reserved.
//

#import "withCircle.h"


@implementation withCircle

- (void) _commonInit {
	greenColor = [[UIColor alloc] initWithRed:0.56f green:0.86f blue:0.30f alpha:1.0f];
	blackColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
	
	multiSquare = CGPathCreateMutable();
	CGPathMoveToPoint(multiSquare, NULL, 0.0f, 0.0f);
	CGPathAddLineToPoint(multiSquare, NULL, 1.0f, 0.0f);
	CGPathAddLineToPoint(multiSquare, NULL, 1.0f, 1.0f);
	CGPathAddLineToPoint(multiSquare, NULL, 0.0f, 1.0f);
	CGPathAddLineToPoint(multiSquare, NULL, 0.0f, 0.0f);
	
	CGPathMoveToPoint(multiSquare, NULL, 0.5f, 0.0f);
	CGPathAddLineToPoint(multiSquare, NULL, 1.0f, 0.5f);
	CGPathAddLineToPoint(multiSquare, NULL, 0.5f, 1.0f);
	CGPathAddLineToPoint(multiSquare, NULL, 0.0f, 0.5f);
	CGPathAddLineToPoint(multiSquare, NULL, 0.5f, 0.0f);
	
	CGPathMoveToPoint(multiSquare, NULL, 0.25f, 0.25f);
	CGPathAddLineToPoint(multiSquare, NULL, 0.75f, 0.25f);
	CGPathAddLineToPoint(multiSquare, NULL, 0.75f, 0.75f);
	CGPathAddLineToPoint(multiSquare, NULL, 0.25f, 0.75f);
	CGPathAddLineToPoint(multiSquare, NULL, 0.25f, 0.25f);
	
	CGPathCloseSubpath(multiSquare);
	
}
- (id)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self _commonInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self == [super initWithCoder:aDecoder]) {
		[self _commonInit];
	}
	return self;
}
- (void) drawPathWithContext: (CGContextRef) c atPoint: (CGPoint) point andScale: (CGFloat) scale andRotation: (CGFloat) rotate {
	CGContextSaveGState(c);
	CGContextSetShadowWithColor(c, CGSizeZero, scale/2.0f, greenColor.CGColor);
	CGContextTranslateCTM(c, point.x, point.y);
	CGContextRotateCTM(c, rotate);
	CGContextScaleCTM(c, scale, scale);
	
	CGContextSetLineWidth(c, 2.0f/scale);
	CGContextAddPath(c, multiSquare);
	CGContextStrokePath(c);
    
	CGContextRestoreGState(c);
}
- (void)drawRect:(CGRect)rect {
    float radius = 80;

	/*CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, greenColor.CGColor);
	//CGContextSetFillColorWithColor(context, blackColor.CGColor);
	
	CGContextAddRect(context, self.bounds);
	CGContextFillPath(context);
	
	// draw some squares
	[self drawPathWithContext:context 
					  atPoint:CGPointMake(25.0f, 50.0f) 
					 andScale: 25.0f 
				  andRotation: 0.1f ];
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
     */

    
 
        
    
    CGContextRef context2 = UIGraphicsGetCurrentContext();
    CGRect drawRect = CGRectMake(rect.origin.x, rect.origin.y,rect.size.width, rect.size.height);
    CGContextSetRGBFillColor(context2, 100.0f/255.0f, 100.0f/255.0f, 100.0f/255.0f, 1.0f);
    CGContextFillRect(context2, drawRect);
    
    //CGColorRef shadowColor = [UIColor colorWithRed:0.56f green:0.86f blue:0.30f alpha:1.0f].CGColor;
    //CGContextSetShadowWithColor(context2, CGSizeMake(0, 1), 10.0, shadowColor);
    
    CGContextTranslateCTM(context2, 20.0f, 20.0f);
  
    CGContextSetStrokeColorWithColor(context2, greenColor.CGColor);
	CGContextSetFillColorWithColor(context2, greenColor.CGColor);
	CGContextSetLineWidth(context2, 10.0);
    CGContextMoveToPoint(context2, 30.5 , 30.5);
    CGContextBeginPath(context2);
    
    CGContextAddArc(context2, radius, radius, radius, M_PI , 3 * M_PI , NO);
    CGContextRotateCTM(context2, 0.1f);
    CGContextClosePath(context2);
    //CGContextFillPath(context2);
    CGContextStrokePath(context2);
    
 
}

- (void)dealloc {
	CGPathRelease(multiSquare);
	[greenColor release];
	[blackColor release];
    [super dealloc];
}
@end