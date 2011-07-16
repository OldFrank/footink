//
//  gradientView.h
//  photoPicker
//
//  Created by yongsik on 11. 7. 16..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface gradientView : UIView {
        float startRed;
        float startGreen;
        float startBlue;
    	 
        float endRed;
   	    float endGreen;
        float endBlue;
   	 
        BOOL mirrored;
}


@property (nonatomic) BOOL mirrored;
	 
- (void) setColoursWithCGColors:(CGColorRef)color1:(CGColorRef)color2;
- (void) setColours:(float) startRed:(float) startGreen:(float) startBlue:(float) endRed:(float) endGreen:(float)endBlue;
 
@end