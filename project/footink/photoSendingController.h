//
//  photoSendingController.h
//  footink
//
//  Created by yongsik on 11. 7. 21..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "HttpWrapper.h"
#import "Filters.h"
@interface photoSendingController : UIViewController <UINavigationControllerDelegate,FiltersDelegate,HttpWrapperDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,CLLocationManagerDelegate>{
    UITableView *spotTable;
    NSMutableArray *fList;
    UITextView *caption;
    int selectedFilterTag;
    HttpWrapper *progressbar;
    UIView *progressBack;
    NSDictionary *postValue;
    float lat;
    float lng;
    
    NSString *spotLat;
    NSString *spotLng;
    UILabel *spotName;
    NSString *pushSpotName;
    NSString *pushCaption;
    
    NSMutableArray *spotArray;

 
}
@property (nonatomic, retain) UIView *progressBack;
@property (nonatomic, retain) NSDictionary *postValue;
@property (nonatomic, retain) UITableView *spotTable;
@property (nonatomic, retain) NSMutableArray *fList;
@property (nonatomic, retain) NSMutableArray *spotArray;
@property (nonatomic, retain) UITextView *caption;
@property (nonatomic,assign) int selectedFilterTag;
@property (nonatomic,assign) float lat;
@property (nonatomic, assign) float lng;

@property (nonatomic,retain) NSString *spotLat;
@property (nonatomic,retain) NSString *spotLng;
@property (nonatomic,retain) UILabel *spotName;
@property (nonatomic,retain) NSString *pushSpotName;
@property (nonatomic,retain) NSString *pushCaption;


- (UIImage*)loadImage:(NSString*)imageName;
-(id)savefilmFxEffect:(int)selTag;
- (void)save;

@end
