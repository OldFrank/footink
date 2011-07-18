//
//  Filters.m
//  footink
//
//  Created by yongsik on 11. 7. 18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Filters.h"

#define HSB(h, s, b) [UIColor colorWithHue:h/360.0 saturation:s/100.0 brightness:b/100.0 alpha:1]
#define HSBA(h, s, b, a) [UIColor colorWithHue:h/360.0 saturation:s/100.0 brightness:b/100.0 alpha:a]

#define DEG2RAD (M_PI/180.0f)

@implementation Filters




- (void)dealloc {
    [frontImage_ release];  
    [backImage_ release];  
    [fxImage_ release];  
    [super dealloc];
}

- (id)init {
    if ( (self = [super init]) ) {
        backImage_ = [UIImage imageNamed:@"test.png"];
        frontImage_ = [UIImage imageNamed:@"grablur.png"];
        fxImage_ = [UIImage imageNamed:@"fx-film-filmgrain.jpg"];
        CGRect newFrame = self.frame;
        newFrame.size = frontImage_.size;
        self.frame = newFrame;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //CGContextRef context = UIGraphicsGetCurrentContext();
    // CGContextSetFillColor(context, CGColorGetComponents([UIColor colorWithHue:0.5 saturation:0.5 brightness:0 alpha:1].CGColor));
    //CGContextFillRect(context, rect); 
    
    //CGRect bounds = [self bounds];
    //[[UIColor blueColor] set];
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextClipToMask(context, bounds, [backImage_ CGImage]);
    //CGContextFillRect(context, bounds);
    
    UIImage *backgroundImage = [UIImage imageNamed:@"test.png"];
    CGSize size = backgroundImage.size;
    CGRect mrect = CGRectMake(0.0, 0.0, size.width, size.height);
    UIColor *color = [UIColor colorWithHue:0.24 saturation:0.61 brightness:1 alpha:1];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, mrect, backgroundImage.CGImage);
    CGContextSetBlendMode (context, kCGBlendModeColor);
    CGContextClipToMask(context, mrect, backgroundImage.CGImage);
    CGContextSetFillColor(context, CGColorGetComponents(color.CGColor));
    CGContextFillRect (context, mrect);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRestoreGState(context);
    UIImage *image = [UIImage imageWithCGImage:imageMasked];
    [image drawInRect:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height)];
    
    [backImage_ drawInRect:rect];
    [fxImage_ drawInRect:rect blendMode:kCGBlendModeSoftLight alpha:1.0];
    //[context blendMode:blendMode_ alpha:1.0];
    //[image drawInRect:rect];
    
    [frontImage_ drawInRect:rect blendMode:kCGBlendModeOverlay alpha:1.0];
    
}

- (void)changeMode {
    if ( kCGBlendModeLuminosity < ++blendMode_ ) {
        
        blendMode_ = kCGBlendModeNormal;
        
    } 
}


/*
 case kCGBlendModeMultiply: label_.text = @"kCGBlendModeMultiply"; break;
 case kCGBlendModeScreen: label_.text = @"kCGBlendModeScreen"; break;
 case kCGBlendModeOverlay: label_.text = @"kCGBlendModeOverlay"; break;
 case kCGBlendModeDarken: label_.text = @"kCGBlendModeDarken"; break;
 case kCGBlendModeLighten: label_.text = @"kCGBlendModeLighten"; break;
 case kCGBlendModeColorDodge: label_.text = @"kCGBlendModeColorDodge"; break;
 case kCGBlendModeColorBurn: label_.text = @"kCGBlendModeColorBurn"; break;
 case kCGBlendModeSoftLight: label_.text = @"kCGBlendModeSoftLight"; break;
 case kCGBlendModeHardLight: label_.text = @"kCGBlendModeHardLight"; break;
 case kCGBlendModeDifference: label_.text = @"kCGBlendModeDifference"; break;
 case kCGBlendModeExclusion: label_.text = @"kCGBlendModeExclusion"; break;
 case kCGBlendModeHue: label_.text = @"kCGBlendModeHue"; break;
 case kCGBlendModeSaturation: label_.text = @"kCGBlendModeSaturation"; break;
 case kCGBlendModeColor: label_.text = @"kCGBlendModeColor"; break;
 case kCGBlendModeLuminosity: label_.text = @"kCGBlendModeLuminosity"; break;
 case kCGBlendModeClear: label_.text = @"kCGBlendModeClear"; break;
 case kCGBlendModeCopy: label_.text = @"kCGBlendModeCopy"; break;
 case kCGBlendModeSourceIn: label_.text = @"kCGBlendModeSourceIn"; break;
 case kCGBlendModeSourceOut: label_.text = @"kCGBlendModeSourceOut"; break;
 case kCGBlendModeSourceAtop: label_.text = @"kCGBlendModeSourceAtop"; break;
 case kCGBlendModeDestinationOver: label_.text = @"kCGBlendModeDestinationOver"; break;
 case kCGBlendModeDestinationIn: label_.text = @"kCGBlendModeDestinationIn"; break;
 case kCGBlendModeDestinationOut: label_.text = @"kCGBlendModeDestinationOut"; break;
 case kCGBlendModeDestinationAtop: label_.text = @"kCGBlendModeDestinationAtop"; break;
 case kCGBlendModeXOR: label_.text = @"kCGBlendModeXOR"; break;
 case kCGBlendModePlusDarker: label_.text = @"kCGBlendModePlusDarker"; break;
 case kCGBlendModePlusLighter: label_.text = @"kCGBlendModePlusLighter"; break;
 default: label_.text = @"kCGBlendModeNormal"; break;
 */

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    
    [self setNeedsDisplay];
}



@end
