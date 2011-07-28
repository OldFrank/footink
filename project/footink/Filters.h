//
//  Filters.h
//  footink
//
//  Created by yongsik on 11. 7. 18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define PhotoshopColorValue(x) (x / 255.0)
#define UIColorFromPhotoshopRGBA(r,g,b,a) [UIColor colorWithRed:PhotoshopColorValue(r) green:PhotoshopColorValue(g) blue:PhotoshopColorValue(b) alpha:a]
#define UIColorFromPhotoshopHSBA(h,s,b,a) [UIColor colorWithHue:PhotoshopColorValue(h) saturation:PhotoshopColorValue(s) brightness:PhotoshopColorValue(b) alpha:a]
#define UIColorFromHexValue(hex) UIColorFromPhotoshopRGBA(((hex & 0xFF0000) >> 16), ((hex & 0xFF00) >> 8), (hex & 0xFF), 1.0)


@class UIView;
@protocol FiltersDelegate;

@interface Filters : UIView {
    UIImage* originalImage_;
    id<FiltersDelegate> delegate;
    int fxFilmKind;
}

@property (nonatomic,retain) UIImage *originalImage_;

@property (nonatomic,assign) id<FiltersDelegate> delegate;

-(id)initWithImage:(UIImage *)image drawFrame:(CGRect)frame fxfilm:(int)fx delegate:(id <FiltersDelegate>)isDelegate;
-(void)fxMode:(CGRect)rect fxfilm:(int)sender;
-(void)colorBlend:(UIImage *)orgImage red:(float)fr green:(float)fg blue:(float)fb alpha:(float)fa;
@end
@protocol FiltersDelegate <NSObject>

@optional
-(void)filterAddImage:(UIImage *)blendedImage;

@end
