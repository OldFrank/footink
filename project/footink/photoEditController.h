//
//  photoEditController.h
//  footink
//
//  Created by yongsik on 11. 7. 18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface photoEditController : UIViewController <UINavigationControllerDelegate,UIScrollViewDelegate,CLLocationManagerDelegate>{
     UIImageView *imageview;
    UIImageView *filterImageView;
    
    
    NSURLConnection *connection;
    NSHTTPURLResponse *response;
    NSMutableData *responseData;
    
    int retryCounter;
    
    IBOutlet UIProgressView *uploadProgress;
    IBOutlet UILabel *uploadProgressMessage;

}
@property (nonatomic, retain) UIImageView *filterImageView;
@property (nonatomic, retain) UIImageView *imageview;

@property (nonatomic,retain) NSURLConnection *connection;
@property (nonatomic,retain) NSHTTPURLResponse *response;
@property (nonatomic,retain) NSMutableData *responseData;

-(UIImage *)generatePhotoThumbnail:(UIImage *)image withRatio:(float)ratio;
-(UIImage *)resizeImage:(UIImage *)image width:(float)resizeWidth height:(float)resizeHeight;
-(UIImage *)maskingImage:(UIImage *)image maskImage:(NSString *)_maskImage;
-(void) uploadImage;
-(BOOL)requestUrl:(NSString *)url;
-(void)setImageData:(UIImage *)img;

@end
