//
//  photoEditController.h
//  footink
//
//  Created by yongsik on 11. 7. 18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>
#import "Filters.h"


@interface photoEditController : UIViewController <FiltersDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,CLLocationManagerDelegate>{
    
    UIImageView *originalImageview;
    UIImageView *blendedImageview;
    UIScrollView *filterScrollView;

    NSArray *arrImage;
    NSTimer *timer; 
    int selectedTag;
}
@property (nonatomic, retain) UIImageView *blendedImageview;
@property (nonatomic, retain) UIImageView *originalImageview;
@property (nonatomic, retain) UIScrollView *filterScrollView;
@property (nonatomic, retain) NSArray *arrImage;
@property (nonatomic, assign) int selectedTag;

-(UIImage *)generatePhotoThumbnail:(UIImage *)image withRatio:(float)ratio;
-(UIImage *)resizeImage:(UIImage *)image width:(float)resizeWidth height:(float)resizeHeight;
-(UIImage *)maskingImage:(UIImage *)image maskImage:(NSString *)_maskImage;
- (UIImage*)loadImage:(NSString*)imageName;
- (void)removeImage:(NSString*)fileName;

-(void)setImageData;
-(void)filmFxEffect:(id)sender;
- (void)layoutScrollImages;
-(void)selectedFilter:(int)fint;
-(void)popfilmFxEffect:(int)selTag;
-(void)initLayout;
@end
