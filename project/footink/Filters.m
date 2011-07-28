//
//  Filters.m
//  filterTest
//
//  Created by yongsik on 11. 7. 20..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Filters.h"
#import <QuartzCore/QuartzCore.h>

@implementation Filters
@synthesize originalImage_,delegate;

-(id)initWithImage:(UIImage *)image drawFrame:(CGRect)frame fxfilm:(int)fx delegate:(id<FiltersDelegate>)isDelegate{
    if ((self = [super init])) {
        self.delegate=isDelegate;
        self.frame = frame;
        originalImage_=image;
        fxFilmKind=fx;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}
- (void)dealloc {
    [originalImage_ release];
    [super dealloc];
}
-(void)drawRect:(CGRect)rect {
    [self fxMode:rect fxfilm:fxFilmKind];
}
-(void)fxMode:(CGRect)rect fxfilm:(int)sender{
    UIImage *orgImage = self.originalImage_;
    
    
    switch (sender) {
        case 1:
            [orgImage drawInRect:rect];
            [[UIImage imageNamed:@"fx-film-filmgrain.jpg"] drawInRect:rect blendMode:kCGBlendModeSoftLight alpha:1.0];
            [[UIImage imageNamed:@"fx-film-mask.png"] drawInRect:rect blendMode:kCGBlendModeOverlay alpha:1.0];
            break;
        case 2:
            [orgImage drawInRect:rect];
            [[UIImage imageNamed:@"fx-film-nostalgia-brown.jpg"] drawInRect:rect blendMode:kCGBlendModeSoftLight alpha:1.0];
            [[UIImage imageNamed:@"fx-film-mask.png"] drawInRect:rect blendMode:kCGBlendModeOverlay alpha:1.0];
            break;
        case 3:
            [orgImage drawInRect:rect];
            [[UIImage imageNamed:@"fx-film-nostalgia-stone.jpg"] drawInRect:rect blendMode:kCGBlendModeSoftLight alpha:1.0];
            [[UIImage imageNamed:@"fx-film-mask.png"] drawInRect:rect blendMode:kCGBlendModeOverlay alpha:1.0];
            break;
        case 4:
            [self colorBlend:orgImage red:199.0 green:178.0 blue:153.0 alpha:1];               
            break;
        default:
            [orgImage drawInRect:rect];
            break;
    }
    
}
-(void)colorBlend:(UIImage *)orgImage red:(float)fr green:(float)fg blue:(float)fb alpha:(float)fa{
    CGSize size = self.frame.size;
    CGRect mrect = CGRectMake(0.0, 0.0, size.width, size.height);
    UIColor *selColor = UIColorFromPhotoshopRGBA(fr,fg,fb,fa);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, mrect, orgImage.CGImage);
    CGContextSetBlendMode (context, kCGBlendModeColor);
    CGContextClipToMask(context, mrect, orgImage.CGImage);
    CGContextSetFillColor(context, CGColorGetComponents(selColor.CGColor));
    CGContextFillRect (context, mrect);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRestoreGState(context);
    
    UIImage *image = [UIImage imageWithCGImage:imageMasked];
    [image drawInRect:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height)];   
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    [self setNeedsDisplay];
}

@end
