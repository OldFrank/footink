//
//  PhotoRoot.h
//  photoPicker
//
//  Created by yj on 11. 4. 16..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "photoViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "SlidingTabView.h"

@class EGOImageView;

@interface PhotoRoot : UIViewController <UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,SlidingTabViewDelegate,EGORefreshTableHeaderDelegate>{

    EGOImageView* calImageView;
    EGOImageView *profileView;
    
    NSInteger nindex; ///클릭된 indexpath.row 
    BOOL onOffCell; // 셀 클릭시 True
    BOOL prevTrueCell; //이전 True cell

    
    NSMutableArray *jsonArray;
    NSArray *lovedArray;
    NSMutableArray *jsonCalArray;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    IBOutlet UIScrollView *scrollView1;
    IBOutlet UIView *cellContentView;

    NSTimer *timer;
    UIAlertView *alert;
    
    UITableView *photoTable;
    NSUInteger sort_no;
    

    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    UIImage *downImage;
    
    UIActivityIndicatorView *indicatior;
    UIView *lView;
}
@property (nonatomic,retain) NSMutableArray *jsonArray;
@property (nonatomic,retain) NSMutableArray *jsonCalArray;
@property (nonatomic, retain) UIView *scrollView1;
@property (nonatomic, retain) UIView *cellContentView;

@property (nonatomic, retain) UITableView *photoTable;


@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) UIImage *downImage;
@property (nonatomic, retain) UIActivityIndicatorView *indicatior;
@property (nonatomic, retain) UIView *lView;
@property (nonatomic, retain) NSArray *lovedArray;

-(void)layoutScrollImages;
-(void)setData:(NSDictionary *)dict sect:(int)row;
- (void)showAlert:(NSString *)msg;
- (void) hideAlert;
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
-(UIImage *)resizeImage:(UIImage *)image width:(float)resizeWidth height:(float)resizeHeight;
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
-(void)ProfileDetail:(id)sender;

- (void)startDownload:(NSString *)urlString;
- (void)cancelDownload;

+ (void)cacheCleanTest;
-(void)viewWillLoading;
-(void)commentSubmit:(id)sender;
-(BOOL)lovedSubmit:(id)sender;
-(BOOL)chkLoved:(int)cnt;
@end

