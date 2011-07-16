//
//  SlidingTab.m
//  photoPicker
//
//  Created by yongsik on 11. 6. 24..
//  Copyright 2011 ag. All rights reserved.
//

#import "SlidingTab.h"


@implementation SlidingTab

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:108.0/255.0f green:108.0/255.0f blue:108.0/255.0f alpha:1.0].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:108.0/255.0f green:108.0/255.0f blue:108.0/255.0f alpha:1.0].CGColor);
    CGContextSetShadow(context, CGSizeMake (0, 0), 5.0);
    
    CGContextSaveGState(context);
    
    CGRect rrect = self.bounds;
    
    CGFloat radius = 5.0;
    CGFloat width = CGRectGetWidth(rrect);
    CGFloat height = CGRectGetHeight(rrect);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddArcToPoint(context, 5, 0, 5, 5, radius);
    CGContextAddLineToPoint(context, 5, height);
    CGContextAddLineToPoint(context, width-5, height);
    CGContextAddLineToPoint(context, width-5, radius);
    CGContextAddArcToPoint(context, width-radius, 0, width, 0, radius);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);
    
    CGContextRestoreGState(context);
}


- (void)dealloc
{
    [super dealloc];
}

@end
